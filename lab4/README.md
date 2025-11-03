# Lab4 -- Cryptography and Security

## Author: Burduja Adrian

## Theory
The Data Encryption Standard is a symmetric-key algorithm for the encryption of 
digital data. Although its short key length of 56 bits makes it too insecure for 
modern applications, it has been highly influential in the advancement of cryptography.

The algorithm is designed to encipher and decipher blocks of data consisting of 64 
bits under control of a 64-bit key1. Deciphering must be accomplished by using the 
same key as for enciphering, but with the schedule of addressing the key bits altered
so that the deciphering process is the reverse of the enciphering process. A block to
be enciphered is subjected to an initial permutation IP, then to a complex 
key-dependent computation and finally to a permutation which is the inverse of the 
initial permutation IP-1.

DES has a key schedule in which the 56-bit key is divided into two 28-bit halves; each
half is thereafter treated separately. In successive rounds, both halves are rotated 
left by one or two bits (specified for each round), and then 48 round key bits are 
selected by Permuted Choice 2 (PC-2) – 24 bits from the left half and 24 from the 
right. The rotations have the effect that a different set of bits is used in each 
round key; each bit is used in approximately 14 out of the 16 round keys.

## Task:
În algoritmul DES este dat K+. Să se determine toate cele 16 chei de rundă Ki.

## Implementation:
```odin
Key_Schedule :: proc(key: u64) -> (Kn: u64) {
	U28_mask :: (~u64(0) >> (64 - 28))
	ls_28 :: proc(digit: u64, n: u8) -> u64 {
		return ((digit << n) | (digit >> (28 - n))) & U28_mask
	}

	// preserve state between calls
	@(static) iteration := 0
	@(static) C: u64
	@(static) D: u64

	if iteration == 0 {
		CD := permute(key, PC_1)

		C = CD >> 28
		D = U28_mask & CD
	}

	shift := SHIFTS[iteration]
	C = ls_28(C, shift)
	D = ls_28(D, shift)
	fmt.printfln("Iterarion %v\tC: %30b\tD: %30b", iteration, C, D)
	CD1 := (C << 28) | D

	iteration += 1

	return permute(CD1, PC_2)
}
```

The above procedure is , iteratively, calculating each new Kn. On the first call, CD 
is initialised from the key, afterwards C,D are separated and stored into the 
corresponding static variables. Consequently, each new call will continue rotating
C,D based on the iteration number.The number of shifts is obtained from the list 
SHIFTS. The result is congregates into CD1, permuted using PC_2 and returned to the
caller.

```odin
permute :: proc(data: $T, perms: []u8) -> (res: T) {
	for permutation, i in perms {i := u8(i)

		read_mask: T = 1 << (permutation - 1)
		// pos 1 is the first bit, 63 is the biggest number in the permutation arrray
		bit := data & read_mask
		// calculate the position of the isolated build
		shift_n: i32 = i32(permutation - 1 - i)
		if shift_n < 0 {
			res |= bit << u8(abs(shift_n))
		} else {
			res |= bit >> u8(abs(shift_n))
		}
	}
	return
}
```

`permute` is a helper procedure to apply an array of permutations to a given integer.
It uses `read_mask`, a N bit number obtained by shifting 0b1 by `permutation - 1`( the
final position, obtained from the table, normalised from 1..64 to 0..63). 

That singular bit is used to read the value of the `permutaion`th bit from the data, 
into the variable `bit`. The length of the shift is calculated by the number of shifts
necesarry to shift the bit into the correct possition.

Since `<<` and `>>` can only take a unsigned integer as the second argument, I have
to decide which to use based on the sign of the shift.

```odin
DES :: proc(data: u64, key: u64) -> (res: u64) {

	// res = permute(data, IP)

	R, L := split(data)
	for i in 0 ..< 16 {
		Kn := Key_Schedule(key)
		fmt.printfln("Key of %v:\t%50b ", i, Kn)
		Rn := L ~ cipher(R, Kn)
		Ln := R
		L = Ln
		R = Rn
	}

	res = transmute(u64)([2]u32{L, R})
	// permute(data, NOT_IP)
	return
}
```

The above is a mock of the `DES` algorithm. It's used to showcase the Keys obtained from
the key schedule.

```odin
main :: proc() {
	DES(rand.uint64(), rand.uint64())
}
```
The main program just calling the above procedure

## Demo output:
```
Iterarion 0     C: 000000000001100000111000011000       D: 000000000010000111000000001001
Key of 0:       00000001000100000010010000000000000000000100000001 
Iterarion 1     C: 000000000011000001110000110000       D: 000000000100001110000000010010
Key of 1:       00000000000100100010010001000000000000010100000001 
Iterarion 2     C: 000000001100000111000011000000       D: 000000010000111000000001001000
Key of 2:       00000100000010000000000001000000000001000000000010 
Iterarion 3     C: 000000110000011100001100000000       D: 000001000011100000000100100000
Key of 3:       00000000000001001100001010000000000010000000000000 
Iterarion 4     C: 000011000001110000110000000000       D: 000100001110000000010010000000
Key of 4:       00000001100100001010010000000100000000010000000100 
Iterarion 5     C: 001100000111000011000000000000       D: 000000111000000001001000000001
Key of 5:       00000000001010100000110001000000000001000000001000 
Iterarion 6     C: 000000011100001100000000000011       D: 000011100000000100100000000100
Key of 6:       00000100000011000100000000000000010000000100001000 
Iterarion 7     C: 000001110000110000000000001100       D: 001110000000010010000000010000
Key of 7:       00000001100000001100000110000100010000000010000011 
Iterarion 8     C: 000011100001100000000000011000       D: 001100000000100100000000100001
Key of 8:       00000001100000000000010010000100000000000110000000
Iterarion 9     C: 001110000110000000000001100000       D: 000000000010010000000010000111
Key of 9:       00000000001010100000100000000000000000000000000010
Iterarion 10    C: 001000011000000000000110000011       D: 000000001001000000001000011100
Key of 10:      00000100001000000100001000000000000010000000000000
Iterarion 11    C: 000001100000000000011000001110       D: 000000100100000000100001110000
Key of 11:      00000000100100000000000110000000000000010000001000
Iterarion 12    C: 000110000000000001100000111000       D: 000010010000000010000111000000
Key of 12:      00000000000000000010100001000000010001000000000001
Iterarion 13    C: 001000000000000110000011100001       D: 001001000000001000011100000000
Key of 13:      00000000001000000000000000000000000000000010000100
Iterarion 14    C: 000000000000011000001110000110       D: 000100000000100001110000000010
Key of 14:      00000000000001001000001100000100000000000000000100
Iterarion 15    C: 000000000000110000011100001100       D: 001000000001000011100000000100
Key of 15:      00000001000100001000001100000000000010000010000001

```


## Conclusion
For this laboratory the task was to implement and showcase the key schedule mechanism
employed in the DES algorithm for cryptography. The 16 round keys were generated and 
printed to the standard output from the initial K+ by initially applying the PC-1 
permutation to the input key, fallowed by the propriate bit rotations per round based
on the data in the shifts array. The output is returned as a permutation based on PC-2
. The usage of static variables for C,D and Iteration simplifies the use of the 
procedure as well as helps maintain the state between calls.

# Source code:
[Github](https://github.com/BurdujaAdrian/CS_lab1.git)


