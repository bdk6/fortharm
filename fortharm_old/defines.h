/*****************************************************************************
fortharm  forth for arm cortex m0 (LPC1114)
copyright(c) 2013 William R Cooke
*/

	.thumb 

#define PSP     sp
#define RSP     r7
#define IR      r6
#define WA      r5
#define CA      r4
#define TOS     r3
#define SCR0    r1
#define SCR1    r2
#define SCR2    r0

#define SCR3    r8
#define SCR4    r9
#define SCR5    r10


#define IMM     (1<<7)
