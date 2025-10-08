#+feature dynamic-literals
package main
import "core:fmt"
import "core:os"
import "core:strconv"

alphabet_map := map[string]int {
	"A" = 0,
	"B" = 1,
	"C" = 2,
	"D" = 3,
	"E" = 4,
	"F" = 5,
	"G" = 6,
	"H" = 7,
	"I" = 8,
	"J" = 9,
	"K" = 10,
	"L" = 11,
	"M" = 12,
	"N" = 13,
	"O" = 14,
	"P" = 15,
	"Q" = 16,
	"R" = 17,
	"S" = 18,
	"T" = 19,
	"U" = 20,
	"V" = 21,
	"W" = 22,
	"X" = 23,
	"Y" = 24,
	"Z" = 25,
}

alphabet_array := [?]string {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
}
main :: proc() {

	loop: for {
		fmt.println(`
1. Encode
2. Decode
3. Show criptogram
4. Exit
		`)
		switch take_input() {
		case "1", "encode", "Encode":
			fmt.print("Input messege('A'-'Z','a'-'z' and ' '): ")
			ok: bool
			input: []string
			input, ok = take_input_cript()

			if !ok {
				fmt.println("\nInput is invalid, it doesn't fit the range of characters,try again")
				continue loop
			}

			fmt.print("\nInput key('A'-'Z','a'-'z', len >= 7):")

			key: []string
			key, ok = take_input_cript()

			if !ok {
				fmt.println("\nKey is invalid, it doesn't fit the range of characters,try again")
				continue loop
			}

			if len(key) < 7 {
				fmt.println("\nLength of key is too short, try again")
				continue loop
			}


			fmt.print("\nInput shift(0-25): ")

			shift_s := take_input()

			shift, success := strconv.parse_uint(shift_s, 10)
			if !success {
				fmt.println("\nInputed shift is not a valid integer,try again")
				continue loop
			}

			if shift < 0 || shift > 25 {
				fmt.println("\nInputed integer is outside the range,try again")
				continue loop
			}

			encoded := caesar_encode2(input, key, auto_cast shift)

			fmt.println("\nEncoded string obtained: ")
			for letter in encoded {
				fmt.print(letter)
			}
			fmt.println()

		case "2", "decode", "Decode":
			fmt.print("Input messege('A'-'Z','a'-'z' and ' '): ")
			input, ok := take_input_cript()

			if !ok {
				fmt.println("\nInput is invalid, it doesn't fit the range of characters,try again")
				continue loop
			}

			fmt.print("\nInput key('A'-'Z','a'-'z', len >= 7):")

			key: []string
			key, ok = take_input_cript()

			if !ok {
				fmt.println("\nKey is invalid, it doesn't fit the range of characters,try again")
				continue loop
			}

			if len(key) < 7 {
				fmt.println("\nLength of key is too short, try again")
				continue loop
			}
			fmt.print("\nInput shift(0-25): ")

			shift_s := take_input()

			shift, success := strconv.parse_uint(shift_s, 10)

			if !success {
				fmt.println("\nInputed shift is not a valid integer,try again")
				continue loop
			}

			if shift < 0 || shift > 25 {
				fmt.println("\nInputed integer is outside the range,try again")
				continue loop
			}
			encoded := caesar_decode2(input, key, auto_cast shift)

			fmt.println("\nDecoded string obtained: ")
			for letter in encoded {
				fmt.print(letter)
			}
			fmt.println()

		case "3", "criptogram", "Criptogram":
			fmt.print("\n(optional)Input key('A'-'Z','a'-'z', len >= 7):")

			key, ok := take_input_cript()

			if len(key) > 0 { 	// if key was inputed
				if !ok {
					fmt.println(
						"\nKey is invalid, it doesn't fit the range of characters,try again",
					)
					continue loop
				}

				if len(key) < 7 {
					fmt.println("\nLength of key is too short, try again")
					continue loop
				}
			}
			fmt.print("\nInput shift(0-25): ")

			shift_s := take_input()

			shift, success := strconv.parse_uint(shift_s, 10)

			if !success {
				fmt.println("\nInputed shift is not a valid integer,try again")
				continue loop
			}

			if shift < 0 || shift > 25 {
				fmt.println("\nInputed integer is outside the range,try again")
				continue loop
			}
			show_criptogram2(key, auto_cast shift)
		case "4", "exit", "Exit":
			os.exit(0)
		case:
			fmt.println("Invalid input,try again")
		}

	}

}

key_alf :: proc(key: []string) -> (alf_m: map[string]int, alf_a: [dynamic]string) {
	for letter, i in key {
		if letter == " " {
			continue
		}
		_, found := alf_m[letter]
		if !found {
			alf_m[letter] = len(alf_a)
			append(&alf_a, letter)
		}
	}

	for letter, i in alphabet_array {
		id, found := alf_m[letter]

		if !found {
			alf_m[letter] = len(alf_a)
			append(&alf_a, letter)
		}
	}

	return
}
caesar_encode2 :: proc(input, key: []string, shift: int) -> (messege: []string) {
	messege = make([]string, len(input))

	_, alphabet2_array := key_alf(key)
	for letter, i in input {
		index := alphabet_map[letter]


		size := len(alphabet_array)
		messege[i] = alphabet2_array[(index + shift + size) % size]
	}

	return
}

caesar_decode2 :: proc(input, key: []string, shift: int) -> (messege: []string) {
	messege = make([]string, len(input))
	alphabet2_map, alphabet2_array := key_alf(key)
	for letter, i in input {
		index := alphabet2_map[letter]

		size := len(alphabet_array)
		messege[i] = alphabet_array[(index - shift + size) % size]
	}

	return
}

import str "core:strings"

show_criptogram2 :: proc(key: []string, shift: int) {
	_, alphabet2_array := key_alf(key)

	top_b: str.Builder
	bottom_b: str.Builder
	for s, i in alphabet2_array {
		str.write_string(&top_b, fmt.aprintf("%2d |", (i + shift) % 26))
		str.write_string(&bottom_b, fmt.aprintf(" %s |", s))
	}

	fmt.println(str.to_string(top_b))
	fmt.println(str.to_string(bottom_b))
	return
}

rb: struct {
	buf: [4096]byte,
	top: int,
}

buff_n :: proc(n: int) -> []byte {
	rb.top += n
	if rb.top >= 4096 {
		rb.top = 0
		return rb.buf[:]
	}

	return rb.buf[rb.top:]
}


take_input_cript :: proc() -> ([]string, bool) {
	buffer := buff_n(128)
	input_n, _ := os.read(os.stdin, buffer)

	input := make([]string, input_n - 2)

	for letter, i in buffer[:input_n - 2] {
		if letter == ' ' do continue
		if (letter >= 'a' && letter <= 'z') || (letter >= 'A' && letter <= 'Z') {
			input[i] = auto_cast buffer[i:i + 1]
			if letter >= 'a' {
				buffer[i] -= ('a' - 'A')
			}
		} else {
			return nil, false
		}
	}

	return input, true
}

take_input :: proc() -> string {
	buffer := buff_n(128)
	input_n, _ := os.read(os.stdin, buffer[:])

	return auto_cast buffer[:input_n - 2]
}
