/*****************************************************************************
fortharm  forth for arm cortex m0 (LPC1114)
copyright(c) 2013 William R Cooke
*/

	.thumb 

	.equ TIB_BYTES, 128
	.equ STACK_BYTES, 128
	.equ RSTACK_BYTES, 64
        .equ PAD_BYTES, 128
	   
// Easy macro to jump to "next"	
#define NEXT    bx  r12  // Always holds address of next:
	
#define PSP         sp
#define RSP         r7
#define IR          r6
#define TOS         r5
#define WA          r4
#define CA          r3

#define SC2         r2
#define SC1         r1
#define SC0         r0
	   
#define SC8         r8
#define SC9         r9
#define SC10        r10
	   
#define USERS       r11

// To make a word "immediate", set the high bit of first char 
#define IMM         (1<<7)
