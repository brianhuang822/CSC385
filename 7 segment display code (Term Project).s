	.text /* executable code follows */
	.global main

main:
	/* initialize base addresses of parallel ports */
	movia r20, 0xFF200020 /* HEX3_HEX0 base address */
	movia r21, 0xFF200030 /* HEX6-HEX4 base address */
	movia r19, HEX_bits
	ldwio r16, 0(r19) /* load pattern for HEX3-0 displays */
	ldwio r17, 0(r19) /* load pattern for HEX6-4 displays */

DO_DISPLAY:
	stwio r16, 0(r20) /* store to HEX3 ... HEX0 */
	stwio r17, 0(r21) /* store to HEX6 ... HEX4 */
	slli r6, r6, 8 /* print first read in value and then shift to the left */

.data

HEX_bits:
	.byte  0x3f           		/* 0 */
	.byte  0x06           		/* 1 */
	.byte  0x5b           		/* 2 */
	.byte  0x4f           		/* 3 */
	.byte  0x66           		/* 4 */
	.byte  0x6d           		/* 5 */
	.byte  0x7d           		/* 6 */
	.byte  0x07           		/* 7 */
	.byte  0xff           		/* 8 */
	.byte  0x6f           		/* 9 */
	.byte  0x77           		/* A */
	.byte  0xfc           		/* B */
	.byte  0x39           		/* C */
	.byte  0x5e           		/* D */
	.byte  0xf9           		/* E */
	.byte  0xf1           		/* F */
	.end