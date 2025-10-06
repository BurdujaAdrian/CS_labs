# Lab1 -- Cryptography and Security

## Burduja Adrian

# 1.1. Cifrul lui Cesar
## Task:
De implementat algoritmul Cezar pentru alfabetul limbii engleze în unul din
limbajele de programare. Utilizați doar codificarea literelor cum este arătat în tabelul 1 (nu se
permite de folosit codificările specificate în limbajul de programare, de ex. ASCII sau Unicode).
Valorile cheii vor fi cuprinse între 1 și 25 inclusiv și nu se permit alte valori. Valorile caracterelor
textului sunt cuprinse între ‘A’ și ’Z’, ’a’ și ’z’ și nu sunt premise alte valori. În cazul în care
utilizatorul introduce alte valori - i se va sugera diapazonul corect. Înainte de criptare textul va
fi transformat în majuscule și vor fi eliminate spațiile. Utilizatorul va putea alege operația -
criptare sau decriptare, va putea introduce cheia, mesajul sau criptograma și va obține respectiv
criptograma sau mesajul decriptat.
## Implementation:
```odin
caesar_encode :: proc(input: []string, shift: int) -> (messege: []string) {
	messege = make([]string, len(input))
	for letter, i in input {
		index := alphabet_map[letter]

		size := len(alphabet_array)
		messege[i] = alphabet_array[(index + shift) % size]
	}

	return
}

```
The above procedure takes an array of strings and a shift, and return the encripted 
messege as an array of strings. In this case each string is just 1 letter.

Alphabet_map is a global variable:hash-map that maps each letter to an number.
Alphabet_array is a global variable, it's an array if strings: the letters of the
english alphabet.
```odin
caesar_decode :: proc(input: []string, shift: int) -> (messege: []string) {
	messege = make([]string, len(input))
	for letter, i in input {
		index := alphabet_map[letter]

		size := len(alphabet_array)
		messege[i] = alphabet_array[(index - shift + size) % size]
	}

	return
}
```
The above procedure does exactly the same thing except the function for getting the
letter has uses '-' rather then '+'

```odin
show_criptogram :: proc(shift: int) {

	top_b: str.Builder
	bottom_b: str.Builder
	for s, i in alphabet_array {
		str.write_string(&top_b, fmt.aprintf("%2d |", (i + shift) % 26))
		str.write_string(&bottom_b, fmt.aprintf(" %s |", s))
	}

	fmt.println(str.to_string(top_b))
	fmt.println(str.to_string(bottom_b))
	return
}
```
This procedures builds and formats a string to display the criptogram

The main procedure is an infinite loop that takes user input to choose from one of
the option:
```
1. Encode
2. Decode
3. Show criptogram
4. Exit
```

## Demo output:
```
1. Encode
2. Decode
3. Show criptogram
4. Exit

1

Input shift(0-25): 10
Input messege('A'-'Z','a'-'z' and ' '): hellofrommoldova

Encoded string obtained:
ROVVYPBYWWYVNYFK

1. Encode
2. Decode
3. Show criptogram
4. Exit

2

Input shift(0-25): 10
Input messege('A'-'Z','a'-'z' and ' '): ROVVYPBYWWYVNYFK

Decoded string obtained:
HELLOFROMMOLDOVA

1. Encode
2. Decode
3. Show criptogram
4. Exit

3

Input shift(0-25): 10
10 |11 |12 |13 |14 |15 |16 |17 |18 |19 |20 |21 |22 |23 |24 |25 |00 |01 |02 |03 |04 |05 |06 |07 |08 |09 |
 A | B | C | D | E | F | G | H | I | J | K | L | M | N | O | P | Q | R | S | T | U | V | W | X | Y | Z |
```

# 1.2. Cifrul lui Cesar + permutare
## Task:
De implementat algoritmul Cezar cu 2 chei, cu păstrarea condițiilor exprimate în
Sarcina 1.1. În plus, cheia 2 trebuie să conțină doar litere ale alfabetului latin, și să aibă o
lungime nu mai mică de 7.

## Implementation:
```odin
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
```
The above procedure creates an alphabet map and array by applying the textual key

```odin
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
```
`caesar_encode2` encodes an array of strings(the messege) using a key and a shift.
This procedure is identical to `caesar_encode` excpet it uses alphabet array 
generated from the inputed textual key.

```odin
caesar_decode2 :: proc(input, key: []string, shift: int) -> (messege: []string) {
	messege = make([]string, len(input))
	alphabet2_map, _ := key_alf(key)
	for letter, i in input {
		index := alphabet2_map[letter]
		size := len(alphabet_array)
		messege[i] = alphabet_array[(index - shift + size) % size]
	}
	return
}
```
`caesar_decode2` works the same as `caesar_decode2` except it uses the alphabet map 
generated from the key.

```odin
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
```
Similar to previous function, this is an adaptation of the `show_criptogram` procedure

The main loop is the same as in the previous exercise besides also asking the user
for an additional key

## Demo output:
```
1. Encode
2. Decode
3. Show criptogram
4. Exit

1
Input messege('A'-'Z','a'-'z' and ' '): hellofrommoldova

Input key('A'-'Z','a'-'z', len >= 7):adrianburduja

Input shift(0-25): 14

Encoded string obtained: 
VQZZRSBRAARZPREL

1. Encode
2. Decode
3. Show criptogram       
4. Exit

2
Input messege('A'-'Z','a'-'z' and ' '): VQZZRSBRAARZPREL

Input key('A'-'Z','a'-'z', len >= 7):adrianburduja

Input shift(0-25): 14

Decoded string obtained: 
HELLOFROMMOLDOVA

1. Encode
2. Decode
3. Show criptogram       
4. Exit

3

(optional)Input key('A'-'Z','a'-'z', len >= 7):adrianburduja

Input shift(0-25): 14
14 |15 |16 |17 |18 |19 |20 |21 |22 |23 |24 |25 |00 |01 |02 |03 |04 |05 |06 |07 |08 |09 |10 |11 |12 |13 | 
 A | D | R | I | N | B | U | J | C | E | F | G | H | K | L | M | O | P | Q | S | T | V | W | X | Y | Z |

```

# 1.3. 
## Task
Pentru această sarcină studenții se vor diviza în perechi. Fiecare dintre ei va cripta
câte un mesaj alcătuit din 7-10 simboluri (fără spații și scris doar cu majuscule) cu versiunea
cifrului Cesar cu permutare, alegând fiecare cheile sale. Criptogramele astfel obținute vor fi
transmise colegului, împreună cu cheile respective. Fiecare dintre cei doi va realiza decriptarea
și se va face compararea cu versiunea originală a colegului.

## My input:
- Messege: notseven
- keys: 7, cryptography
- Cryptogram:
- Encoded : SUCZEYES
- Cryptogram:
07 |08 |09 |10 |11 |12 |13 |14 |15 |16 |17 |18 |19 |20 |21 |22 |23 |24 |25 |00 |01 |02 |03 |04 |05 |06 |
 C | R | Y | P | T | O | G | A | H | B | D | E | F | I | J | K | L | M | N | Q | S | U | V | W | X | Z |

## My collegues output:

## My decryption:

# Source code:
[Github](https://github.com/BurdujaAdrian/CS_lab1.git)
