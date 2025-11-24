# Lab5 -- Cryptography and Security

## Author: Burduja Adrian

## Theory

## Task:
### Conditions
Create an internal PKI using the OpenSSL tool. The generation of the root private key
and the initialization of a Certificate Authority (CA) are required. A self-signed certificate must be
created for the CA.
The system must be able to issue and revoke private keys for users so that they can subsequently generate a digital signature. Each user or entity that obtains a signature must be able to
sign a document or file and verify this signature.
For the realization of this laboratory, the use of any programming language is allowed, including scripting languages such as Bash, PowerShell, or zsh.
### Requirements
* Use the RSA algorithm for generating private keys.
* Users’ private keys must have a validity period of 365 days, and their key length must
be at least 2048 bits.
* The private key of the Certificate Authority (CA) must be 4096 bits long, and the
expiration period for its self-signed certificate must be 10 years (3650 days).

## Implementation:
The implementation is a simple json script that is a cli tool:
```py
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
   Creates private key and certificate.
   
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
   Checks both signature validity and certificate revocation status.
   
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
        self.new_certs_dir = self.ca_dir / "newcerts"
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
            self.new_certs_dir,
            self.crl_dir,
            self.users_dir,
            self.docs_dir
        ]
        for directory in directories: directory.mkdir(parents=True, exist_ok=True)
        if not self.serial_file.exists(): self.serial_file.write_text("01")
        if not self.index_file.exists(): self.index_file.write_text("")
    
    def create_openssl_config(self):
        config_content = f"""[ ca ]
default_ca = CA_default

[ CA_default ]
dir = {self.ca_dir.as_posix()}
database = {self.index_file.as_posix()}
new_certs_dir = {self.new_certs_dir.as_posix()}
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
        if not crlnumber_file.exists(): crlnumber_file.write_text("01")
    
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
        if not self.ca_cert.exists() or not self.ca_key.exists():
            print("Error: CA not set up. Please run 'setup-ca' first.")
            return
        user_dir = self.users_dir / user_name
        user_cert = user_dir / f"{user_name}.crt"
        if user_cert.exists():
            print(f"Error: Certificate for {user_name} already exists. Revoke it first if you want to reissue.")
            return
        print(f"Issuing certificate for user: {user_name}")
        user_dir.mkdir(exist_ok=True)
        user_key = user_dir / f"{user_name}.key"
        user_csr = user_dir / f"{user_name}.csr"
        print("Generating user private key (2048 bits)...")
        cmd = f"openssl genrsa -out {user_key} 2048"
        self.run_openssl_command(cmd)
        print("Generating certificate signing request...")
        subject = f"/C=US/ST=State/L=City/O=Organization/CN={user_name}"
        cmd = f'openssl req -new -key {user_key} -out {user_csr} -subj "{subject}"'
        self.run_openssl_command(cmd)
        print("Signing user certificate (365 days)...")
        cmd = f"openssl ca -config {self.config_file} -in {user_csr} -out {user_cert} -batch"
        self.run_openssl_command(cmd)
        print(f"User certificate issued successfully!")
        print(f"User private key: {user_key}")
        print(f"User certificate: {user_cert}")
    
    def revoke_user_certificate(self, user_name):
        if not self.ca_cert.exists() or not self.ca_key.exists():
            print("Error: CA not set up. Please run 'setup-ca' first.")
            return False
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
        if self.crl_file.exists():
            cmd = f"openssl verify -crl_check -CRLfile {self.crl_file} -CAfile {self.ca_cert} {user_cert}"
            result = self.run_openssl_command(cmd, check=False)
            if result.returncode != 0:
                print("✗ Certificate has been REVOKED")
                return False
        pubkey_file = self.users_dir / user_name / f"{user_name}.pub"
        cmd = f"openssl x509 -pubkey -noout -in {user_cert} -out {pubkey_file}"
        self.run_openssl_command(cmd)
        cmd = f"openssl dgst -sha256 -verify {pubkey_file} -signature {signature_path} {document_path}"
        result = self.run_openssl_command(cmd, check=False)
        pubkey_file.unlink(missing_ok=True)
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
                        subject = parts[5]
                        cn = subject.split('CN=')[-1] if 'CN=' in subject else subject
                        print(f"User: {cn}, Status: {status}, Serial: {parts[3]}")


def main():
    pki = PKISystem()

    args = sys.argv

    if len(args) < 2:
        print("Please specify a command")
        print_help()
        return
    arg = args[1]
    if arg == 'setup-ca': pki.setup_ca()
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
    elif arg == 'ca-info': pki.display_ca_info()
    elif arg == 'list-users': pki.list_users()

    elif arg == "help": print_help()

    else:
        print("Unknown command")
        print_help()

if __name__ == "__main__": main()
```

## Demo output:
```bash
====================================
PKI System Test Script
====================================

[TEST 1] Setting up Certificate Authority...
Setting up Certificate Authority...
Generating CA private key (4096 bits)...
Generating self-signed CA certificate (3650 days)...
CA setup complete!
CA private key: pki\ca\private\ca.key
CA certificate: pki\ca\certs\ca.crt
PASSED

[TEST 2] Displaying CA information...
CA Certificate Information:
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            05:b1:43:57:e6:a3:61:b2:fe:40:80:5c:49:69:ad:08:06:52:75:50
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, ST=State, L=City, O=Organization, CN=Root CA
        Validity
            Not Before: Nov 24 10:23:03 2025 GMT
            Not After : Nov 22 10:23:03 2035 GMT
        Subject: C=US, ST=State, L=City, O=Organization, CN=Root CA
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    # Value ommited
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                0E:AC:B6:F5:3C:2C:2F:6B:E8:DF:83:EE:7B:DB:82:3E:DB:99:00:08
            X509v3 Authority Key Identifier: 
                0E:AC:B6:F5:3C:2C:2F:6B:E8:DF:83:EE:7B:DB:82:3E:DB:99:00:08
            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        # Value ommited
PASSED

[TEST 3] Issuing certificate for alice...
Issuing certificate for user: alice
Generating user private key (2048 bits)...
Generating certificate signing request...
Signing user certificate (365 days)...
User certificate issued successfully!
User private key: pki\users\alice\alice.key
User certificate: pki\users\alice\alice.crt
PASSED

[TEST 4] Issuing certificate for bob...
Issuing certificate for user: bob
Generating user private key (2048 bits)...
Generating certificate signing request...
Signing user certificate (365 days)...
User certificate issued successfully!
User private key: pki\users\bob\bob.key
User certificate: pki\users\bob\bob.crt
PASSED

[TEST 5] Listing all users...
Issued User Certificates:
User: alice, Status: VALID, Serial: 01
User: bob, Status: VALID, Serial: 02
PASSED

[TEST 6] Creating test document...
Test document created

[TEST 7] Signing document with alice...
Signing document with user: alice
Document signed successfully!
Signature file: pki\documents\test_document_alice.sig
PASSED

[TEST 8] Verifying alice's signature...
Verifying signature for user: alice
✓ Signature is VALID
PASSED

[TEST 9] Revoking bob's certificate...
Revoking certificate for user: bob
Generating Certificate Revocation List...
Certificate for user bob revoked successfully!
CRL updated: pki\ca\crl\crl.pem
PASSED

[TEST 10] Signing document with bob (should work, signature is independent)...
Signing document with user: bob
Document signed successfully!
Signature file: pki\documents\test_document_bob.sig
PASSED

[TEST 11] Verifying bob's signature (should fail - cert revoked)...
Verifying signature for user: bob
✗ Certificate has been REVOKED
PASSED - Correctly rejected revoked certificate

[TEST 12] Listing users after revocation...
Issued User Certificates:
User: alice, Status: VALID, Serial: 01
User: bob, Status: REVOKED, Serial: 02
PASSED

====================================
All tests completed successfully!
====================================

Cleanup test document...

Test artifacts location: .\pki\
- CA certificates: .\pki\ca\certs\
- User certificates: .\pki\users\
- Signatures: .\pki\documents\
- CRL: .\pki\ca\crl\crl.pem
```

## Conclusion
This laboratory successfully implemented a complete Public Key Infrastructure (PKI) system using OpenSSL and Python. The system fulfills all specified requirements through several key components.

The Certificate Authority setup generates a 4096-bit RSA private key for the CA and creates a self-signed certificate valid for 10 years (3650 days). User certificate management implements certificate issuance with 2048-bit RSA keys valid for 365 days, maintaining proper database tracking in index.txt through the openssl ca command. Certificate revocation functionality includes automatic Certificate Revocation List (CRL) generation and updates. Digital signature capabilities allow document signing using SHA-256 with RSA encryption and signature verification using the user's public key extracted from their certificate. Administrative functions provide CA information display and user certificate listing with status tracking for valid and revoked certificates.

The implementation features a directory structure organized with separate folders for CA files, user credentials, and documents. An OpenSSL configuration file is automatically generated for proper CA database management. The command-line interface provides seven operations: setup-ca, issue-cert, revoke-cert, sign, verify, ca-info, and list-users. All cryptographic operations comply with RSA algorithm requirements and specified key lengths and validity periods.

The system provides a functional PKI infrastructure suitable for managing digital certificates and signatures in a controlled environment.

# Source code:
[Github](https://github.com/BurdujaAdrian/CS_lab1.git)


