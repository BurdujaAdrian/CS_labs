package main

import "core:fmt"
import "core:math/rand"
import "core:testing"

main :: proc() {
	DES(rand.uint64(), rand.uint64())
}

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

cipher :: proc(R: u32, key: u64) -> u32 {return 0}

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

split :: #force_inline proc(n: u64) -> (R: u32, L: u32) {
	return expand_values(transmute([2]u32)n)
}

@(test)
test_split_u64 :: proc(t: ^testing.T) {
	for i in 0 ..< u64(2 << 16) {
		num: u64 = i * rand.uint64()

		R, L := split(num)
		fmt.assertf(u64(L) == num >> 32, "split L\n%b\n%b\n%b", num, u64(L), num >> 32)
		fmt.assertf(u64(R) == u64(u32(num)), "split R\n%b\n%b\n%b", num, u64(R), u64(u32(num)))

		new_num := (u64(L) << 32) + u64(R)
		fmt.assertf(num == new_num, "split|\n%b\n\n%b ", num, new_num)
	}

}
