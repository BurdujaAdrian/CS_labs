# Lab3 -- Cryptography and Security

## Author: Burduja Adrian

## Theory

## Task:
 De implementat algoritmul Playfair în unul din limbajele de programare pentru
mesaje în limba română (31 de litere). Valorile caracterelor textului sunt cuprinse între ‘A’
și ’Z’, ’a’ și ’z’ și nu sunt premise alte valori. În cazul în care utilizatorul introduce alte valori
- i se va sugera diapazonul corect al caracterelor. Lungimea cheii nu trebuie să fie mai mică
de 7. Utilizatorul va putea alege operația - criptare sau decriptare, va putea introduce cheia,
mesajul sau criptograma și va obține criptograma sau mesajul decriptat. Faza finală de
adăugare a spațiilor noi, în funcție de limba folosită și de logica mesajului – se va face
manual.

## Implementation:

My implementation fallows the steps of preparing the messege for encription, with manual input from the user.
```odin

	i := 0
	for i < len(input) - 1  /* iterate manually */{
		// if 2  of the same letter are found, point it out,
		if input[i] == input[i + 1] {
			println(input[i])
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
```

Then, for the encoding, it first creates a new alphabet map and array for easy access to
the indexes of the letters after the key is inserted. Then, it gets the row,col by doing
a simple divmod operation with 5.
```odin
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

```

For the decoding, the above algorithm is used but with the sign of the operation changed and
\+ 5 to account for negative modulo


## Demo output:
```

1. Encode
2. Decode
3. Exit  

1
Input messege('A'-'Z','a'-'z' and ' '): hello from moldova

Input key('A'-'Z','a'-'z', len >= 7):adriannnnnn
Choose Letter to put at the end
X
Choose Letter to put at the end
X

Encoded string obtained:
KBOVMPHAPOOPMALXRV

1. Encode
2. Decode
3. Exit

2
Input messege('A'-'Z','a'-'z' and ' '): KBOVMPHAPOOPMALXRV
Input key('A'-'Z','a'-'z', len >= 7):adriannnnnnn

Decoded string obtained:
HELXLOFROMMOLDOVAX


```

# Source code:
[Github](https://github.com/BurdujaAdrian/CS_lab1.git)


