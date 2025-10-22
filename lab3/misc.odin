package main
import "base:intrinsics"
import "core:fmt"
import "core:math"
import "core:os"
import "core:path/filepath"
import "core:slice"

nop :: #force_inline proc(_: ..any) {}

when ODIN_DEBUG {
	print :: fmt.print
	printf :: fmt.printf
	println :: fmt.println
	printfln :: fmt.printfln
} else {
	print :: nop
	printf :: nop
	println :: nop
	printfln :: nop
}
TODO :: proc($msg: string, loc := #caller_location) {context.assertion_failure_proc(
		"TODO",
		msg,
		loc,
	)}

take_input :: proc() -> (out: string) {
	buffer := make([]byte, 128)
	defer delete(buffer)
	input_n, _ := os.read(os.stdin, buffer[:])

	out = auto_cast slice.clone(buffer[:input_n - 2])

	return
}

@(private)
misc :: proc() {
	array := [?]string{"a", "b", "d"}
}

// matrix of 2 letters
MATRIX_WIDTH :: 5
when ODIN_DEBUG {
	print_matrix_wh :: proc(m: []string, index: int = -1, width: int = 2) {
		fmt.println()
		for letter, i in m {
			if i % (MATRIX_WIDTH * width) == 0 {
				fmt.println()
				row, col: int = math.divmod(index, MATRIX_WIDTH)
				if i / (MATRIX_WIDTH * width) == row do fmt.printf("%*s\n", col, "v")
				else do fmt.println()
			}
			// if i % width == 0 {fmt.print(letter); continue}
			fmt.print(letter)

		}
	}
} else {
	print_matrix_wh :: proc(m: []string, index: int = -1, width: int = 2) {}
}
