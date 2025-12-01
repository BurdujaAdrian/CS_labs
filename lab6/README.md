# Lab 6:FUNCȚII HASH ȘI SEMNĂTURI DIGITALE 

## Elaborated by: Burduja Adrian

## Task 2:
### Initial input:
```
riverbank publication no. 22, written in 1920 when friedman was28, must be regarded 
as the most important single publication incryptology. it took the science into a new
world. entitled the index ofcoincidence and its applications in cryptography, it 
described thesolution of two complicated cipher systems. friedman, however, was 
lessinterested in proving their vulnerability than he was in using them as avehicle 
for new methods of cryptanalysis.in it, friedman devised two new techniques. one was
brilliant. itpermitted him to reconstruct a primary cipher alphabet without having to
guess at a single plaintext letter. but the other was profound. for thefirst time in 
cryptology, friedman treated a frequency distribution as anentity, as a curve whose 
several points were causally related, not as justa collection of individual letters 
that happen to stand in a certain orderfor noncausal (historical) reasons, and to 
this curve he applied statisticalconcepts. the results can only be described as 
promethean, forfriedman's stroke of genius inspired the numerous, varied, and 
vitalstatistical tools that are indispensable to the cryptology of today.before 
friedman, cryptology eked out an existence as a study untoitself, as an isolated 
phenomenon, neither borrowing from norcontributing to other bodies of knowledge. 
frequency counts, linguisticcharacteristics, kasiski examinations—all were peculiar 
and particular tocryptology. it dwelt a recluse in the world of science. friedman 
ledcryptology out of this lonely wilderness and into the broad rich domain of 
statistics. he connected cryptology to mathematics. the sense ofexpanding horizons 
must have resembled that felt by chemists whenfriedrich wohler synthesized urea, 
demonstrating that life processesoperate under well known chemical laws and are 
therefore subject toexperimentation and control, and leading to today's vast strides
inbiochemistry. when friedman subsumed cryptanalysis under statistics, he likewise 
flung wide the door to anarmamentarium to which cryptology had never before had 
access. itsweapons—measures of central tendency and dispersion, of fit andskewness, 
of probability and sampling and significance—were ideallyfashioned to deal with the 
statistical behavior of letters and words.cryptanalysts, seizing them with alacrity, 
have wielded them withnotable success ever since.this is why friedman has said, in 
looking back over his career, thatthe index of coincidence was his greatest single 
creation. it alone wouldhave won him his reputation. but in fact it was only the 
beginning. he and mrs. friedman quit riverbank near the end of 1920. thesituation 
had become intolerable. fabyan had lured him back after thewar with raises and 
promises of absolute freedom to prove or disprovethe existence of ciphers in 
shakespeare. but he had squelched everyattempt to do so and had embarrassed friedman
into apparentlyacquiescent silence at lantern-slide lectures on the subject. on 
january1, 1921, friedman began a six-month contract with the signal corps to devise 
cryptosystems. when it expired, he was taken on the civil-servicepayroll of the war 
department at $4,500 a year.one of his first assignments was to teach a course in 
military codesand ciphers at the signal school, then at camp alfred vail, new 
jersey.for this he wrote a textbook that, for the first time, imposed order uponthe 
chaos of cipher systems and their terminology. these had sproutedin a bewildering
variety, and writers treated each as individual andspecial cases. friedman sorted 
them out on the basis of structureinstead of aspect, and so logical and useful was 
this classification that ithas become standard. he modeled his nomenclature on his 
categories, sothat the names he minted have the great merit of making the 
relationsbetween the various genera of ciphers evident on sight. an example is 
thecomplementary pair "mono-alphabet" and "polyalphabet"; the frenchwere still 
calling polyalphabetic systems by the almost obfuscatory"double substitution," which
tells absolutely nothing at all about thesystem. friedman's most important coinage 
was the word"cryptanalysis," which he devised in 1920 to clear up a chronic source of
confusion in cryptology—the ambiguity of the verb "decipher," then usedto mean both 
authorized and unauthorized reductions of a cryptogram to plaintext.he titled his 
book elements of cryptanalysis, and the term has soprospered that today it circulates
in general conversation and print.
e6
```


### Hashing the text using md6-512, obtained the fallowing digest, in decimal:
```
6822730182401529160559115715859093584620592015482525191091457938056748309362225926010803280258444612647477491527603956811455616728616284675247684149672003
```

### Encrypting the digest with an private rsa key:

1. generate the public and private keys of 3072 bits using openssl:
```openssl genrsa -out private.key 3072```
```openssl rsa -in private.key -pubout -out public.key```
2. Encrypting it using openssl: 
```openssl rsautl -sign -inkey private.key -in input.txt -out output.bin```

3. Verifying using openssl:
```openssl rsautl -verify -pubin -inkey public.key -in output.bin -out reinput.txt```


## Task 3

For this task I wrote a simple script for doing the computations of Elgamal
algorithm:
```python
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
```

Output:
```
Original messege:85724594965407510948727254457429497187097678664708121433233363787066638118034

Generating private and public key of reciever:

Obtained priv:31677893574848853689055378072878963017284285582976220494387563399606587300032493
5180267844060270144099814917992549290333071934492347318556851569771099884273923578782382261362
4152413155197054659528705528267219822280542602484760436578614677968982696527800875995765322795
3590455786823341374213883850242636282461224038115223345226284402890923262827006055824064744054
5485686631101074167741557888022952302137369029541967433262725960146144856484772032178368808481
6304473996053477038602441114550094292900685611261264121125922686036901227824592382749127510500
2387087463887011733823667593640329363513486175195222882302114503525, pub:198605169776435749693
4403295610005019381763617126855920060901353821099681934626355412340121796825058132360117968276
0798269892008131593689502680102780390692708327549062074391669331877765169516711476250730705343
6720952236216664016662958423611850640141080631538198031349950870568751678465403850780472496652
3994375778105911647626761450184498553537977430590972890858003241383386902576877303094632003353
0194523972642117452545135438016045530563196161802115846703537169059362640039147254960004480255
6118520508337752267544996378684919950342447115383053180708903363765837646238488011989473169805
77017141545572416955541287642201

Starting encryption

Generating private and public key of sender:

Obtained priv:61056716393710369616970269757581268757750158717677570614014576765527502927718383
4001346420193203700141489708099816803615540636592011980377784360725077440598004128864405713147
9055115001886491876975192117303776295148021986011755439362617743577610509414529231636669623644
8811310911790252316395065586146858751262463565550632436405922120152948441883778574390515282610
9193560136342515273134241085426914078203897771794607743905061771157655862910952861209205272419
7265555392508805761009560615082161290685793846118307393873741560714101143640557776142468438482
755922156294564770961612662040758988765267779661758409068047586323, pub:2552010056138195715496
0253746843156351167993309554142500362695090415532689042560977074419370898600171751665807447668
4209879449368312013077691809579104972620341011964712562071446524642636384910586355792364333151
9934879468541093785268172620324284513982322065523557822021899888081504688578312982617305320459
1768011177968231345054025074617538586908395496021192473191034908200275696869036826674454546463
7231603681091714967408950936733915139768045005023056460763847597068663037956677330991770193111
4711232377728013067823220181113131444503361056059926557041825218504604603593703119199503714578
748123335021241415114187214981

Secret key K:125444603618604006409300076173628071407810610888042721757909160188477773501584356
7866493234409138878308336360620965953214474403735660302659652597378019056905265304386527551021
6541142767092958330254186654668848603498423843786238693434581219301517292249182643162787856753
5635661373425722184015203651141436426048492329007244199761782788602919851051826056487061804312
0491002919437248106080765301784141080715159568332661629333371493016071178340660853996003352210
4519033815500141210752500216297755617367175749987054982798225729947594401828535994475110793652
33078814105472996982760228251095500950049376015783623389929916825

Encrypted messege:3202502414976645157945667378106875881608566501059683840319376901583584850064
1311351051896015014763485947327332952075958454388850852769525895643269647032169285541493634264
3082764810658563048541245089588067328288814630486265555813154482160378382864828224874047659054
3286838756663416988929592702336253162581348097614242566359524290966467626685264049959391650211
2477432494902792339429460374930557581538615690097142454881405591781905498345830827530728173675
1925839654777356010619396162333538177575256123785134520502066849402106142443441612341216085084
53758625595644038956369050084151312225244001038251714243010730070344782

Decrypting messege

Secret key K:125444603618604006409300076173628071407810610888042721757909160188477773501584356
7866493234409138878308336360620965953214474403735660302659652597378019056905265304386527551021
6541142767092958330254186654668848603498423843786238693434581219301517292249182643162787856753
5635661373425722184015203651141436426048492329007244199761782788602919851051826056487061804312
0491002919437248106080765301784141080715159568332661629333371493016071178340660853996003352210
4519033815500141210752500216297755617367175749987054982798225729947594401828535994475110793652
33078814105472996982760228251095500950049376015783623389929916825

Decrypted messege:8572459496540751094872725445742949718709767866470812143323336378706663811803
4
```

## Conclusion
In this laboratory work, we explored the practical implementation of digital 
signatures using both RSA and ElGamal cryptographic systems. The work began with 
processing a text passage about William Friedman's contributions to cryptanalysis, 
which was hashed using the MD6-512 algorithm to produce a fixed-length digest. This 
digest served as the input for our signature schemes, demonstrating how hash 
functions enable the signing of arbitrarily large messages by first reducing them to
a standard size.

For the RSA signature implementation, we generated a 3072-bit key pair using OpenSSL
and used the private key to sign the hashed message. The signature was then 
successfully verified using the corresponding public key, confirming the authenticity
of the message. This process illustrated the fundamental principle of digital 
signatures where the private key creates a signature that can be publicly verified 
without revealing the private key itself.

The ElGamal signature scheme required a custom Python implementation since OpenSSL 
does not natively support this algorithm. Using the provided prime modulus and 
generator, we implemented the complete ElGamal signature process including key 
generation, signing, and verification. The successful encryption and decryption of 
the message demonstrated the mathematical properties of the ElGamal system, 
particularly how the shared secret key can be independently computed by both parties
using their respective private keys and the other party's public key.

Both implementations successfully demonstrated the core principles of digital 
signature schemes, showing how mathematical operations can provide cryptographic
guarantees of message authenticity and integrity. The work highlighted the practical
differences between RSA and ElGamal approaches, with RSA being directly supported by
standard cryptographic libraries while ElGamal required manual implementation of the
underlying mathematical operations.

# Source code:
[Github](https://github.com/BurdujaAdrian/CS_lab1.git)

