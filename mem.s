#include "textflag.h"

// func PospopcntMem(counts *[8]int32, buf []byte)
TEXT ·PospopcntMem(SB),NOSPLIT,$0-32
	MOVQ counts+0(FP), DI
	MOVQ buf_base+8(FP), SI		// SI = &buf[0]
	MOVQ buf_len+16(FP), CX		// CX = len(buf)

	SUBQ $32, CX			// pre-subtract 32 bit from CX
	JL scalar

vector:	VMOVDQU (SI), Y0		// load 32 bytes from buf
	PREFETCHT1 384(SI)
	ADDQ $32, SI			// advance SI past them

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*7(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*6(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*5(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*4(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*3(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*2(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*1(DI)		// add to counter
	VPADDD Y0, Y0, Y0		// shift Y0 left by one place

	VPMOVMSKB Y0, AX		// move MSB of Y0 bytes to AX
	POPCNTL AX, AX			// count population of AX
	ADDL AX, 4*0(DI)		// add to counter

	SUBQ $32, CX
	JGE vector			// repeat as long as bytes are left

scalar:	ADDQ $32, CX			// undo last subtraction
	JE done				// if CX=0, there's nothing left

loop:	MOVBLZX (SI), AX		// load a byte from buf
	INCQ SI				// advance past it

	SHRL $1, AX
	ADCL $0, 4*0(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*1(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*2(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*3(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*4(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*5(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*6(DI)		// add it to the counters

	SHRL $1, AX
	ADCL $0, 4*7(DI)		// add it to the counters

	DECQ CX				// mark this byte as done
	JNE loop			// and proceed if any bytes are left

done:	VZEROUPPER			// restore SSE-compatibility
	RET
