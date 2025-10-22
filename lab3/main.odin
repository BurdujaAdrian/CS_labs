#+feature dynamic-literals
package main
import "base:builtin"
import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import str "core:strings"
import "core:sys/windows"
import uni "core:unicode"


write_buf: []byte
alphabet_map: map[string]int

alphabet_array := [30]string {
	"A",
	"Ă",
	"Â",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	// "Î",
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
	"Ș",
	"T",
	"Ț",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
}
main :: proc() {
	write_buf = make([]byte, 3)
	windows.SetConsoleOutputCP(.UTF8)
	// populate the map
	for letter, i in alphabet_array {
		alphabet_map[letter] = i
	}
	loop: for {
		fmt.println(`
1. Encode
2. Decode
3. Exit
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


			encoded := pf_encode(input, key)

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
			encoded := pf_decode(input, key)

			fmt.println("\nDecoded string obtained: ")
			for letter in encoded {
				fmt.print(letter)
			}
			fmt.println()

		case "3", "exit", "Exit":
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

pf_encode :: proc(input, key: []string) -> []string {

	builder: str.Builder
	i := 0
	for i < len(input) - 1  /* iterate manually */{

		// if 2  of the same letter are found, point it out,
		if input[i] == input[i + 1] {
			str.write_string(&builder, input[i])

			write_buf := make([]byte, 3)
			fmt.printfln("Choose Letter to put at the end")
			os.read(os.stdin, write_buf)
			str.write_string(&builder, str.trim_space(cast(string)write_buf))

			i += 1
			continue
		}

		str.write_string(&builder, input[i])
		str.write_string(&builder, input[i + 1])
		i += 2
	}

	if i == len(input) - 1 {
		str.write_string(&builder, input[i])
	}

	if len(builder.buf) % 2 == 1 {
		fmt.printfln("Choose Letter to put at the end")
		os.read(os.stdin, write_buf)
		str.write_string(&builder, str.trim_space(cast(string)write_buf))

	}

	input_post := str.to_string(builder)

	messege := make([dynamic]string, str.rune_count(input_post))

	// Create the map & array
	alphabet2_map, alphabet2_array := key_alf(key)


	for i := 0; i < len(messege); {
		row_a, col_a := math.divmod(alphabet2_map[input_post[i:i + 1]], 5)
		i += 1
		row_b, col_b := math.divmod(alphabet2_map[input_post[i:i + 1]], 5)
		i += 1

		switch {
		case row_a == row_b:
			new_index_a := (row_a) * 5 + ((col_a + 1) % 5)
			new_index_b := (row_b) * 5 + ((col_b + 1) % 5)
			messege[i - 2] = alphabet2_array[new_index_a]
			messege[i - 1] = alphabet2_array[new_index_b]

		case col_a == col_b:
			new_index_a := ((row_a + 1) % 5) * 5 + col_a
			new_index_b := ((row_b + 1) % 5) * 5 + col_b

			messege[i - 2] = alphabet2_array[new_index_a]
			messege[i - 1] = alphabet2_array[new_index_b]

		case:
			messege[i - 2] = alphabet2_array[row_a * 5 + col_b]
			messege[i - 1] = alphabet2_array[row_b * 5 + col_a]
		}
	}


	return messege[:]
}

pf_decode :: proc(input, key: []string) -> []string {

	messege := make([dynamic]string, len(input))

	// Create the map & array
	alphabet2_map, alphabet2_array := key_alf(key)


	for i := 0; i < len(messege); {
		row_a, col_a := math.divmod(alphabet2_map[input[i]], 5)
		i += 1
		row_b, col_b := math.divmod(alphabet2_map[input[i]], 5)
		i += 1

		switch {
		case row_a == row_b:
			new_index_a := (row_a) * 5 + (col_a - 1 + 5) % 5
			new_index_b := (row_b) * 5 + (col_b - 1 + 5) % 5
			messege[i - 2] = alphabet2_array[new_index_a]
			messege[i - 1] = alphabet2_array[new_index_b]

		case col_a == col_b:
			new_index_a := ((row_a - 1 + 5) % 5) * 5 + col_a
			new_index_b := ((row_b - 1 + 5) % 5) * 5 + col_b

			messege[i - 2] = alphabet2_array[new_index_a]
			messege[i - 1] = alphabet2_array[new_index_b]

		case:
			messege[i - 2] = alphabet2_array[row_a * 5 + col_b]
			messege[i - 1] = alphabet2_array[row_b * 5 + col_a]
		}
	}


	return messege[:]
}


import utf "core:unicode/utf8"

take_input_cript :: proc() -> ([]string, bool) {
	buffer := make([]byte, 128)
	input_n, _ := os.read(os.stdin, buffer)

	input := make([dynamic]string)

	rune_array := utf.string_to_runes(auto_cast buffer[:input_n - 2])
	for letter, i in rune_array {
		if letter == ' ' do continue

		switch letter {
		// for this just replace with ugh
		case 'î', 'Î':
			append(&input, "Â")
		// to_upper doesn't work
		case 'ș':
			append(&input, utf.runes_to_string({letter - 1}))
		case 'ț':
			append(&input, utf.runes_to_string({letter - 1}))
		case 'a' ..= 'z', 'ă', 'â':
			append(&input, utf.runes_to_string({uni.to_upper(letter)}))
		case 'A' ..= 'Z', 'Ă', 'Â', 'Ș', 'Ț':
			append(&input, utf.runes_to_string({letter}))
		case ' ': /* do nothing */
		case:
			// else, invalid character
			return nil, false
		}


	}

	return input[:], true
}
