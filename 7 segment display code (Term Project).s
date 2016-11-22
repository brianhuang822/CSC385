  .equ ADDR_7SEG1, 0xFF200020
  .equ ADDR_7SEG2, 0xFF200030

  .global main
 
 main:
  movia r2,ADDR_7SEG1
  movia r3,0xEF   # bits 0000110 will activate segments 1 and 2 
  stwio r3,0(r2)        # Write to 7-seg display 
  movia r2,ADDR_7SEG2
  stwio r0, 0(r2)
  
  
 /* Store the 7-segment patterns starting at memory address 0x200 */
PATTERNS:
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