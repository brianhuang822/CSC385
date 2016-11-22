	.text /* executable code follows */
	.global main

#Register map
# anything below r16 is being used by brian
# r16 handles input/output of hex3-0 displays
# r17 handles input/output of hex6-4 displays
# r18 temp storage for value in r4
# r19 points to hex_bit patterns in memory
# r20 hex3-0 base address
# r21 hex6-4 base address
main:
	/* initialize base addresses of parallel ports */
	movia r20, 0xFF200020	/* HEX3_HEX0 base address */
	movia r21, 0xFF200030 	/* HEX6-HEX4 base address */
	movia r19, HEX_bits
	ldwio r16, 0(r19) 		/* load pattern for HEX3-0 displays */
	ldwio r17, 0(r19) 		/* load pattern for HEX6-4 displays */

DISPLAY:
	addi sp, sp, -16 		/* reserve space on stack */
	stw r4, 0(sp) 			/* store colour on stack */
	stw r21, 4(sp)			/* store hex3_0 address on stack */
	stw r22, 8(sp) 			/* current number to be pushed to display */
	stw r23, 12(sp) 		/* current digit in 7-seg */

MatchHex:
	ldw r18, 0(r4) 			/* temp stores hex value of the current colour */

DO_DISPLAY:
	ldbu r23, HEX_bits(r22)	/* Load 7-seg format */
	or r22, r22, r23
	roli r22, r22, 24
	srli r18, r18, 4 		/* Goes to next digit */
	#stwio r16, 0(r20) 		/* store to HEX3 ... HEX0 */
	#stwio r17, 0(r21) 		/* store to HEX6 ... HEX4 */

DISPLAY_DONE:
	ldw r4, 0(sp)
	ldw r21, 4(sp)
	ldw r22, 8(sp)
	ldw r23, 12(sp)
	addi sp, sp, 16
	
	ret						/* Returns from subroutine */
	
	
.data

HEX_bits:
	.byte  0x3f           	/* 0 */
	.byte  0x06           	/* 1 */
	.byte  0x5b          	/* 2 */
	.byte  0x4f           	/* 3 */
	.byte  0x66        		/* 4 */
	.byte  0x6d        		/* 5 */
	.byte  0x7d        		/* 6 */
	.byte  0x07        		/* 7 */
	.byte  0xff           	/* 8 */
	.byte  0x6f           	/* 9 */
	.byte  0x77           	/* A */
	.byte  0xfc           	/* B */
	.byte  0x39           	/* C */
	.byte  0x5e           	/* D */
	.byte  0xf9           	/* E */
	.byte  0xf1           	/* F */
.end