import sys
import subprocess
from pathlib import Path

def print_help():
    print('''
0. help
    Prints the message below

1. setup-ca
   Setup Certificate Authority with 4096-bit RSA key and self-signed certificate
   valid for 3650 days (10 years).
   
   Example: python main.py setup-ca

2. issue-cert <username>
   Issue a new user certificate with 2048-bit RSA private key valid for 365 days.
   Creates private key, certificate, and PKCS#12 bundle.
   
   Example: python main.py issue-cert alice

3. revoke-cert <username>
   Revoke a user certificate and update the Certificate Revocation List (CRL).
   
   Example: python main.py revoke-cert bob

4. sign <username> <document>
   Sign a document using the specified user's private key. Generates a digital
   signature file using SHA-256 with RSA.
   
   Example: python main.py sign alice document.txt

5. verify <username> <document> <signature>
   Verify a document signature using the user's certificate.
   
   Example: python main.py verify alice document.txt signature.sig

6. ca-info
   Display detailed information about the Certificate Authority certificate.
   
   Example: python main.py ca-info

7. list-users
   List all issued user certificates with their current status (VALID/REVOKED).
   
   Example: python main.py list-users
    ''')

class PKISystem:
    def __init__(self, base_dir="./pki"):
        self.base_dir = Path(base_dir)
        self.ca_dir = self.base_dir / "ca"
        self.users_dir = self.base_dir / "users"
        self.docs_dir = self.base_dir / "documents"
        
        self.private_dir = self.ca_dir / "private"
        self.certs_dir = self.ca_dir / "certs"
        self.crl_dir = self.ca_dir / "crl"
        
        self.ca_key = self.private_dir / "ca.key"
        self.ca_cert = self.certs_dir / "ca.crt"
        self.serial_file = self.ca_dir / "serial"
        self.index_file = self.ca_dir / "index.txt"
        self.crl_file = self.crl_dir / "crl.pem"
        self.config_file = self.ca_dir / "openssl.cnf"
        
        self.setup_directories()
        self.create_openssl_config()
    
    def setup_directories(self):
        directories = [
            self.base_dir,
            self.ca_dir,
            self.private_dir,
            self.certs_dir,
            self.crl_dir,
            self.users_dir,
            self.docs_dir
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
        
        if not self.serial_file.exists():
            self.serial_file.write_text("01")
        
        if not self.index_file.exists():
            self.index_file.write_text("")
    
    def create_openssl_config(self):
        config_content = f"""[ ca ]
default_ca = CA_default

[ CA_default ]
dir = {self.ca_dir.as_posix()}
database = {self.index_file.as_posix()}
certificate = {self.ca_cert.as_posix()}
serial = {self.serial_file.as_posix()}
private_key = {self.ca_key.as_posix()}
default_days = 365
default_md = sha256
policy = policy_any
crl = {self.crl_file.as_posix()}
crlnumber = {(self.ca_dir / 'crlnumber').as_posix()}
default_crl_days = 30

[ policy_any ]
countryName = optional
stateOrProvinceName = optional
localityName = optional
organizationName = optional
organizationalUnitName = optional
commonName = supplied
emailAddress = optional
"""
        self.config_file.write_text(config_content)
        
        crlnumber_file = self.ca_dir / "crlnumber"
        if not crlnumber_file.exists():
            crlnumber_file.write_text("01")
    
    def run_openssl_command(self, cmd, check=True):
        try:
            result = subprocess.run(cmd, shell=True, check=check, 
                                  capture_output=True, text=True)
            return result
        except subprocess.CalledProcessError as e:
            print(f"OpenSSL command failed: {e}")
            print(f"Error output: {e.stderr}")
            raise
    
    def setup_ca(self):
        print("Setting up Certificate Authority...")
        
        print("Generating CA private key (4096 bits)...")
        cmd = f"openssl genrsa -out {self.ca_key} 4096"
        self.run_openssl_command(cmd)
        
        print("Generating self-signed CA certificate (3650 days)...")
        cmd = f'openssl req -new -x509 -days 3650 -key {self.ca_key} -out {self.ca_cert} -subj "/C=US/ST=State/L=City/O=Organization/CN=Root CA"'
        self.run_openssl_command(cmd)
        
        print(f"CA setup complete!")
        print(f"CA private key: {self.ca_key}")
        print(f"CA certificate: {self.ca_cert}")
    
    def issue_user_certificate(self, user_name):
        print(f"Issuing certificate for user: {user_name}")
        
        user_dir = self.users_dir / user_name
        user_dir.mkdir(exist_ok=True)
        
        user_key = user_dir / f"{user_name}.key"
        user_csr = user_dir / f"{user_name}.csr"
        user_cert = user_dir / f"{user_name}.crt"
        user_p12 = user_dir / f"{user_name}.p12"
        
        print("Generating user private key (2048 bits)...")
        cmd = f"openssl genrsa -out {user_key} 2048"
        self.run_openssl_command(cmd)
        
        print("Generating certificate signing request...")
        subject = f"/C=US/ST=State/L=City/O=Organization/CN={user_name}"
        cmd = f'openssl req -new -key {user_key} -out {user_csr} -subj "{subject}"'
        self.run_openssl_command(cmd)
        
        print("Signing user certificate (365 days)...")
        cmd = f"openssl x509 -req -days 365 -in {user_csr} -CA {self.ca_cert} -CAkey {self.ca_key} -CAserial {self.serial_file} -out {user_cert}"
        self.run_openssl_command(cmd)
        
        print("Creating PKCS#12 bundle...")
        cmd = f'openssl pkcs12 -export -out {user_p12} -inkey {user_key} -in {user_cert} -certfile {self.ca_cert} -password pass:'
        self.run_openssl_command(cmd)
        
        print(f"User certificate issued successfully!")
        print(f"User private key: {user_key}")
        print(f"User certificate: {user_cert}")
        print(f"PKCS#12 bundle: {user_p12}")
    
    def revoke_user_certificate(self, user_name):
        print(f"Revoking certificate for user: {user_name}")
        
        user_cert = self.users_dir / user_name / f"{user_name}.crt"
        
        if not user_cert.exists():
            print(f"Error: Certificate for user {user_name} not found!")
            return False
        
        cmd = f"openssl ca -config {self.config_file} -revoke {user_cert}"
        self.run_openssl_command(cmd)
        
        print("Generating Certificate Revocation List...")
        cmd = f"openssl ca -config {self.config_file} -gencrl -out {self.crl_file}"
        self.run_openssl_command(cmd)
        
        print(f"Certificate for user {user_name} revoked successfully!")
        print(f"CRL updated: {self.crl_file}")
        return True
    
    def sign_document(self, user_name, document_path):
        print(f"Signing document with user: {user_name}")
        
        user_key = self.users_dir / user_name / f"{user_name}.key"
        user_cert = self.users_dir / user_name / f"{user_name}.crt"
        
        if not user_key.exists() or not user_cert.exists():
            print(f"Error: User {user_name} credentials not found!")
            return None
        
        document_path = Path(document_path)
        if not document_path.exists():
            print(f"Error: Document {document_path} not found!")
            return None
        
        signature_file = self.docs_dir / f"{document_path.stem}_{user_name}.sig"
        
        cmd = f"openssl dgst -sha256 -sign {user_key} -out {signature_file} {document_path}"
        self.run_openssl_command(cmd)
        
        print(f"Document signed successfully!")
        print(f"Signature file: {signature_file}")
        return signature_file
    
    def verify_signature(self, user_name, document_path, signature_path):
        print(f"Verifying signature for user: {user_name}")
        
        user_cert = self.users_dir / user_name / f"{user_name}.crt"
        
        if not user_cert.exists():
            print(f"Error: User {user_name} certificate not found!")
            return False
        
        pubkey_file = self.users_dir / user_name / f"{user_name}.pub"
        cmd = f"openssl x509 -pubkey -noout -in {user_cert} -out {pubkey_file}"
        self.run_openssl_command(cmd)
        
        cmd = f"openssl dgst -sha256 -verify {pubkey_file} -signature {signature_path} {document_path}"
        result = self.run_openssl_command(cmd, check=False)
        
        if result.returncode == 0:
            print("✓ Signature is VALID")
            return True
        else:
            print("✗ Signature is INVALID")
            return False
    
    def display_ca_info(self):
        if not self.ca_cert.exists():
            print("CA certificate not found. Please setup CA first.")
            return
        
        print("CA Certificate Information:")
        cmd = f"openssl x509 -in {self.ca_cert} -text -noout"
        result = self.run_openssl_command(cmd)
        print(result.stdout)
    
    def list_users(self):
        print("Issued User Certificates:")
        if not self.index_file.exists():
            print("No certificates issued yet.")
            return
        
        with open(self.index_file, "r") as f:
            for line in f:
                if line.strip():
                    status = "VALID" if line.startswith("V") else "REVOKED" if line.startswith("R") else "UNKNOWN"
                    parts = line.strip().split('\t')
                    if len(parts) >= 6:
                        print(f"User: {parts[5]}, Status: {status}, Serial: {parts[3]}")


def main():
    pki = PKISystem()

    args = sys.argv

    if len(args) < 2:
        print("Please specify a command")
        print_help()
        return
    
    arg = args[1]
    
    if arg == 'setup-ca':
        pki.setup_ca()
    
    elif arg == 'issue-cert':
        if len(args) != 3:
            print("Incorrect use of issue-cert command; must specify a username only")
            return
        username = args[2]
        pki.issue_user_certificate(username)
    
    elif arg == 'revoke-cert':
        if len(args) != 3:
            print("Incorrect use of revoke-cert command; must specify a username only")
            return
        username = args[2]
        pki.revoke_user_certificate(username)
    
    elif arg == 'sign':
        if len(args) != 4:
            print("Incorrect use of sign command; must specify a username and document only")
            return
        username = args[2]
        document = args[3]
        pki.sign_document(username, document)
    
    elif arg == 'verify':
        if len(args) != 5:
            print("Incorrect use of verify command; must specify username, document and signature")
            return
        username = args[2]
        document = args[3]
        signature = args[4]
        pki.verify_signature(username, document, signature)
    
    elif arg == 'ca-info':
        pki.display_ca_info()
    
    elif arg == 'list-users':
        pki.list_users()

    elif arg == "help":
        print_help()

    else:
        print("Unknown command")
        print_help()
    

if __name__ == "__main__":
    main()
