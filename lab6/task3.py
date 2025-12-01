import random
from math import gcd


# Initial inputs:
input = 0xbd8666bd1bd8ad1f292a7dfa860acad603aba79d83ea20fed62394fe807cac92

p = 32317006071311007300153513477825163362488057133489075174588434139269806834136210002792056362640164685458556357935330816928829023080573472625273554742461245741026202527916572972862706300325263428213145766931414223654220941111348629991657478268034230553086349050635557712219187890332729569696129743856241741236237225197346402691855797767976823014625397933058015226858730761197532436467475855460715043896844940366130497697812854295958659597567051283852132784468522925504568272879113720098931873959143374175837826000278034973198552060607533234122603254684088120031105907484281003994966956119696956248629032338072839127039
g = 2

print(f"Original messege:{input}")
print()

# Key generation:
print("Generating private and public key of reciever:")
print()
priv_key_A = random.randint(2, p-2)
while gcd(priv_key_A,p) != 1: priv_key_A = random.randint(2, p-2) 

pub_key_A = pow(g,priv_key_A,p)

print(f"Obtained priv:{priv_key_A}, pub:{pub_key_A}")
print()

# Encryption:
print("Starting encryption")
print()

print("Generating private and public key of sender:")
print()
priv_key_B = random.randint(2, p-2)
while gcd(priv_key_B,p) != 1: priv_key_B = random.randint(2, p-2) 

pub_key_B = pow(g,priv_key_B,p)
print(f"Obtained priv:{priv_key_B}, pub:{pub_key_B}")
print()

K = pow(pub_key_A,priv_key_B,p)
print(f"Secret key K:{K}")
print()

encrypt = (input*K) % p
print(f"Encrypted messege:{encrypt}")
print()

# Decryption:
print("Decrypting messege")
print()
K = pow(pub_key_B,priv_key_A,p)
inv_K = pow(K,-1,p)
print(f"Secret key K:{K}")
print()

reinput = (encrypt*inv_K) % p
print(f"Decrypted messege:{reinput}")
print()

assert(input==reinput)



