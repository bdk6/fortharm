
#include "defines.h"

	//  CONVERT TO F83!!!!
	

/* core wordset from dpans 94 ch 6  133 words
*/	
	.text
	.balign 4
	.syntax unified
	.thumb
	//.thumb_func


	// General Routines


	// call with dividend in r2, divisor in r1
	// Unsigned divide 32/32
	// dividend in r0
	// dividend / quotient / rmdr  in r0:r2
	// 32 bit divisor, 32 bit alu, 64 bit rmdr
	// 1: place dividend in remainder(low)
	// 2: shift rmdr left 1
	// 3: subtract divisor from high rmdr, place in high rmdr
	// 4: if rmdr >= 0, goto 6
	// 5: (<0) restore, shift 0 into rmdr/quotient: goto 7
	// 6: shift 1 into rmdr/quotient
	// 7: more steps? goto 3
	// 8: shift rmdr right 1
udiv_32:
	push    {r3}
	movs    r0, #0   // zero quotient
	movs    r3, 32   // counter
	
	lsls    r2, #1   // shift rmdr left 1
	adcs    r0, r0
	
3:	subs    r0, r1
	bpl     6f       // worked

	adds    r0, r1   // restore
	lsls    r2, #1   // too big, shift in a zero
	adcs    r0, r0
	b       7f

6:	lsls    r2, #1
	adcs    r0, r0
	adds    r2, #1
	

7:	subs    r3, #1
	bne     3b

	lsrs    r0, #1

	mov     r1, r0   // remainder
	mov     r0, r2   // quotient
	pop     {r3}
	push    {lr}
	bx      lr
	


	// Signed divide 32/32
	// Call with dividend in r2, divisor in r1
	// convert abs values and save signs
	// call udiv_32
	// if signs different, make quo negative
	// rmdr gets sign of divisor
	// return quotient in r0, rmdr in r1
sdiv_32:	
	push    {r4,r5, lr}
	movs    r4, #0    // sign of dividend
	movs    r5, #0    // sign of divisor
	orrs    r2,r2     // get sign of dividend
	bpl     1f
	negs    r2, r2    // negate dividend
	adds    r4, #1    // save sign

1:	orrs    r1, r1    // get sign of divisor
	bpl     2f
	negs    r1, r1    // negate divisor
	adds    r5, #1    // save sign

2:	bl      udiv_32   // call divide
	cmp     r4, r5
	beq     3f        // don't change
	negs    r0, r0    // negate quotient if signs diff

3:	cmp     r5, #1
	bne     4f        // skip if positive
	negs    r1, r1    // negate remainder if divisor neg

4:	bl      forth_printnum
	pop     {r4, r5, pc}   // exit
	

	// IN: r2:r3  dividend (64 bits, hi:r2, lo:r3)
	// IN: r1     divisor
	// OUT: r0    quotient
	// OUT: r1 (r2?) remainder
	// USE:
	
	// call with dividend in r2, divisor in r1
	// Unsigned divide 32/32
	// dividend in r0
	// dividend / quotient / rmdr  in r0:r2
	// 32 bit divisor, 32 bit alu, 64 bit rmdr
	// 1: place dividend in remainder(low)
	// 2: shift rmdr left 1
	// 3: subtract divisor from high rmdr, place in high rmdr
	// 4: if rmdr >= 0, goto 6
	// 5: (<0) restore, shift 0 into rmdr/quotient: goto 7
	// 6: shift 1 into rmdr/quotient
	// 7: more steps? goto 3
	// 8: shift rmdr right 1
udiv_64_32:
	// TODO: write 64 bit divide! broken!!!!!
	push    {r3}
	movs    r0, #0   // zero quotient
	movs    r3, 32   // counter
	
	lsls    r2, #1   // shift rmdr left 1
	adcs    r0, r0
	
3:	subs    r0, r1
	bpl     6f       // worked

	adds    r0, r1   // restore
	lsls    r2, #1   // too big, shift in a zero
	adcs    r0, r0
	b       7f

6:	lsls    r2, #1
	adcs    r0, r0
	adds    r2, #1
	

7:	subs    r3, #1
	bne     3b

	lsrs    r0, #1

	mov     r1, r0   // remainder
	mov     r0, r2   // quotient
	pop     {r3}
	push    {lr}
	bx      lr


sdiv_64_32:
	bx      lr

	
//  Send a character to terminal
//  Character passed in r0
//  All other regs saved
send_character:
	push    {r1,r2,r3,r4,r5,r6,r7, lr}
	mov     r1, r8
	mov     r2, r9
	mov     r3, r10
	mov     r4, r11
	mov     r5, r12
	push    {r1,r2,r3,r4,r5}
	bl      putchar         // call c routine
	pop     {r1,r2,r3,r4,r5}
	mov     r12, r5
	mov     r11, r4
	mov     r10, r3
	mov     r9,  r2
	mov     r8,  r1
	pop     {r1,r2,r3,r4,r5,r6,r7,pc}




//  Receive a character from  terminal
//  Character passed in r0
//  All other regs saved
receive_character:
	push    {r1,r2,r3,r4,r5,r6,r7, lr}
	mov     r1, r8
	mov     r2, r9
	mov     r3, r10
	mov     r4, r11
	mov     r5, r12
	push    {r1,r2,r3,r4,r5}
	bl      getchar         // call c routine
	pop     {r1,r2,r3,r4,r5}
	mov     r12, r5
	mov     r11, r4
	mov     r10, r3
	mov     r9,  r2
	mov     r8,  r1
	pop     {r1,r2,r3,r4,r5,r6,r7,pc}




//  Receive a line from  terminal
//  At most n characters
//  Placed at addr
//
//  Address passed in r0
//  Max in r1
//
//  Returns number of chars received in r0
//  
//  All other regs saved
receive_line:
	push    {r2,r3,r4,r5,r6,r7, lr}
	mov     r2, r8
	mov     r3, r9
	mov     r4, r10
	mov     r5, r11
	mov     r6, r12
	push    {r2,r3,r4,r5,r6}

	mov     r3, r0          // Keep our address safe
	movs    r2, #0          // Number chars received
	
9:	cmp     r2, r1          // Have we reached max?
	beq     1f              //   Then exit
	bl      receive_character   // Else get another character
	
	cmp     r0, #13         // CR?
	bne     2f
	b	1f

2:	cmp     r0, #8          // BS?
	bne     2f
	cmp     r2, #0          // ARe there any chars to remove
	beq     9b              // NO?  then skip
	mov     r4, r0          // save the BS
	bl      send_character  // echo
	movs    r0, #32         // erase
	bl      send_character
	mov     r0, r4          // and step back
	bl      send_character
	subs    r2, #1          // remove from buffer
	b       9b


2:	cmp     r0, #9          // TAB?
	bne     2f
	movs    r0, #32         // convert to space
	strb    r0, [r3,r2]     // save it
	bl      send_character  // and echo
	adds    r2, #1          // increment count
	b       9b

2:      cmp     r0, #32        // Is it another control char?
	bmi     9b             // yes, ignore it
	strb    r0, [r3,r2]    // Printing, save
	bl      send_character // and echo
	adds    r2, #1         // increment count
	b       9b
	
1:	mov     r0, r2         // return # chars rcvd
	
	pop     {r2,r3,r4,r5,r6}
	mov     r12, r6
	mov     r11, r5
	mov     r10, r4
	mov     r9,  r3
	mov     r8,  r2
	pop     {r2,r3,r4,r5,r6,r7,pc}

	
	//  Headerless words
	//

	
/****************************************************************/

//  Modifiers: C (colon def), I(immediae), M(multitask), U(user var), A(ANSI), S(F83)
	//  U: User Variable
	
	
// Store NOS to address in TOS            MOD: S
__w_store:                                @ ( x a-addr -- )            
	.byte 1
	.ascii "!"
        .balign 4
	.word 0                           // End of list
__c_store:
        .word .+5
	pop     {r0}
	str     r0, [TOS]
	pop     {TOS}
	NEXT

	
// Convert rem(ud1/base) to ascii and append to output
                                          // MOD:  S
__w_sharp:                                @ ( ud1 -- ud2 ) 
	.byte 1
	.ascii "#"
        .balign 4
	.word __w_store
__c_sharp:
        .word .+5
        NEXT

	
	// End pictured numeric output
	//                                // MOD: S
	.globl __w_sharp_greater
__w_sharp_greater:                             @ ( xd -- c-addr u )
	.byte 2
	.ascii  "#>"
        .balign 4
	.word   __w_sharp
__c_sharp_greater:        
	.word   .+5
        NEXT

        // Converts ud1 to digits until 0 for pictured output
	//                                // MOD: S
	.globl  __w_sharp_s
__w_sharp_s:                                   @ ( ud1 -- ud2)
        .byte   2
        .ascii  "#s"
        .balign 4
        .word   __w_sharp_greater
__c_sharp_s:      
        .word   .+5
	@ TODO: stuff here
        NEXT


	// The address of a variable containing # bytes in TIB
	//                                 // MOD: U,S
__w_number_tib:                            @ ( -- addr )
	.byte   4
	.ascii "#tib"
	.balign 4
	.word   __w_sharp_s
__c_number_tib:
	.word   .+5
	push    {TOS}
	ldr     TOS, 1f
	NEXT
	.balign 4
1:	.word  sys_number_tib



	// Gets compilation addr of following name
	//                                  // MOD: M, S
	.globl  __w_tick
__w_tick:                                       @ ( "<spaces>name" -- xt )
        .byte   1
        .ascii  "'"
        .balign 4
        .word   __w_number_tib
__c_tick:       
        .word   .+5
	@ TODO: stuff here
        NEXT


	// Start a comment until ")"
	//                                 // MOD: I,M,S
	.globl __w_paren
__w_paren:                                      @ ( "ccc<paren>" -- )
        .byte   1+IMM
        .ascii  "("
        .balign 4
        .word   __w_tick
__c_paren:
        .word .+5
	@ TODO: stuff here
        NEXT

	
	// multiply u1/n1 and u2/n2 giving u3/n3
        //                                 // MOD: S
	.globl __w_star
__w_star:                                       @ ( n1|u1 n2|u2 -- n3|u3 )
        .byte   1
        .ascii  "*"
        .balign 4
        .word __w_paren
__c_star:
        .word .+5
        pop     {r0}
        muls     TOS, r0, TOS
        NEXT


	// multiply n1 and n2 giving 64 bits then divide by n3
	//                                 // MOD: S
	.globl __w_star_slash
__w_star_slash:                                 @ ( n1 n2 n3 -- n4 )
        .byte   2
        .ascii  "*/"
        .balign 4
        .word   __w_star
__c_star_slash:
        .word   .+5

	@TODO: stuff here

	NEXT


	//   n1*n2/n3  giving remainder n4 and quotient n5
	//                                   // MOD: S
	.globl __w_star_slash_mod
__w_star_slash_mod:                             @ ( n1 n2 n3 -- n4 n5 )
        .byte   5
        .ascii  "*/MOD"
        .balign 4
        .word   __w_star_slash
__c_star_slash_mod:
        .word .+5

	@TODO: stuff here

        NEXT
        

	//  add n1 and n2 to give n3
	//                                    // MOD S
	.globl __w_plus
__w_plus:                                       @ ( n1|u1 n2|u2 -- n3|u3 )
        .byte   1
        .ascii  "+"
        .balign 4
        .word   __w_star_slash_mod
__c_plus:
        .word   .+5
        pop     {r0}
        add     TOS, r0, TOS
        NEXT


	// n|u is added to n|u at addr
	//                                     // MOD S
	.globl __w_plus_store
__w_plus_store:                                 @ ( n|u a-addr -- )
        .byte   2
        .ascii  "+!"
        .balign 4
        .word   __w_plus
__c_plus_store:
        .word .+5
        pop     {r0}
	ldr     r1, [TOS]
	adds    r0, r1
        str     r0, [TOS]
        pop     {TOS}
        NEXT
        

	// n is added to loop index, loop if n crosses boundary
	//                                     // MOD: C,I,S
	.globl __w_plus_loop
__w_plus_loop:                                  @ ( n -- )
	                                        @ ( sys -- )
        .byte   5 + IMM
        .ascii  "+LOOP"
        .balign 4
        .word   __w_plus_store
__c_plus_loop:
        .word   .+5

	@TODO: stuff here

        NEXT
        

	// ALLOT space for 32b then store 32b at HERE 2-
	//                                      MOD: S
	.globl __w_comma
__w_comma:                                      @ ( 32b -- )
        .byte   1
        .ascii  ","
        .balign 4
        .word   __w_plus_loop
__c_comma:
        .word   .+5

	@TODO: stuff here

        NEXT


	// n3|u3 is the result of subtracting u2|n2 from u1|n1
	//                                      MOD: S
	.globl __w_minus
__w_minus:                                      @ ( n1|u1 n2|u2 -- n3|u3 )
        .byte   1
        .ascii  "-"
        .balign 4
        .word   __w_comma
__c_minus:
        .word   . + 5
        pop     {r0}
        subs     TOS, r0, TOS
        NEXT
        

	// removes trailing spaces from str(len n1) at addr, leaving n2
	//                                     // MOD S, NON-ANSI
__w_dash_trailing:
	.byte 9
	.ascii "-trailing"
	.balign 4
	.word __w_comma
__c_dash_trailing:
	.word .+5
	@TODO: stuff here
	NEXT


	// Abs value of n is displayed with leading minus if negative
	//                                      MOD: S
	.globl __w_dot
__w_dot:                                        @ ( n -- )
        .byte 1
        .ascii  "."
        .balign 4
        .word __w_dash_trailing
__c_dot:
        .word   .+5

	@TODO: stuff here

        NEXT


	// Later execution will display the string "ccc"
	//                                      MOD: C,I,S
	.globl __w_dot_quote
__w_dot_quote:                                  @ ( "ccc<quote>" -- )
        .byte   2+IMM
        .ascii  ".\""
        .balign 4
        .word   __w_dot
__c_dot_quote:
        .word   .+5

	@TODO: stuff here

        NEXT


	// Execution (immediate) will display the string "ccc"
	//                                     MOD: I,M,S NON ANSI
__w_dot_paren:                                @( "ccc<paren>" -- )
	.byte 2+IMM
	.ascii ".("
	.balign 4
	.word __w_dot_quote
__c_dot_paren:
	.word .+5

	@TODO: stuff here

	NEXT

	
	// n3 is floor of quotient of n1 div by n2
	//                                     MOD: S
	.globl __w_slash
__w_slash:                                      @ ( n1 n2 -- n3 )
        .byte   1
        .ascii  "/"
        .balign 4
        .word __w_dot_paren
__c_slash:
        .word   .+5
	mov     r1, TOS
	pop     {r0}
	bl      sdiv_32
	mov     TOS, r0
        NEXT
        

	// n3 is remainder and n4 quotient of n1 / n2
	//                                     MOD: S
	.globl __w_slash_mod
__w_slash_mod:                                  @ ( n1 n2 -- n3 n4 )
        .byte   4
        .ascii  "/MOD"
        .balign 4
        .word   __w_slash
__c_slash_mod:
        .word   .+5
	mov     r1, TOS
	pop     {r0}
	bl      sdiv_32
	push    {r1}     // remainder
	mov     TOS, r0  // quotient
        NEXT
        

	// flag is true if n is less than zero
	//                                     MOD: S
	.globl __w_zero_less
__w_zero_less:                                  @ ( n -- flag )
        .byte   2
        .ascii  "0<"
        .balign 4
        .word   __w_slash_mod
__c_zero_less:
        .word   .+5
	movs    r0, #0
	orrs    TOS, TOS       // Set flags
	bpl     1f                     // Skip inversion if plus
	mvns    r0, r0     // invert
1:
	mov     TOS, r0
	NEXT


	// flag is true if n is zero
	//                                      MOD: S
	.globl   __c_zero_equals
__w_zero_equals:                                @ ( n -- flag )
        .byte   2
        .ascii  "0="
        .balign 4
        .word   __w_zero_equals
__c_zero_equals:
        .word   .+5
	movs    r0, #0
	orrs    TOS, TOS    // set the zero flag
	bne     1f          // skip invert if not zero
	mvns    r0, r0  // invert flag
1:	mov     TOS, r0
	NEXT

       

	// flag is true if n is greater than zero
	//                                     MOD: S NON ANSI
	.globl __w_zero_greater
__w_zero_greater:                                  @ ( n -- flag )
        .byte   2
        .ascii  "0>"
        .balign 4
        .word   __w_zero_equals
__c_zero_greater:
        .word   .+5
	movs    r0, #0
	orrs    TOS, TOS
	bpl     1f                 // skip if > 0
	beq     1f                 // skip if = 0
	mvns    r0, r0             // invert if < 0
1:	mov     TOS, r0
        NEXT


	// w2 is the result of adding one to w1 ( : 1+  1 + ; )
	//                                      MOD: S
__w_one_plus:                                   @ ( n1|u1 -- n2|u2 )
        .byte   2
        .ascii  "1+"
        .balign 4
        .word   __w_zero_greater
__c_one_plus:
        .word   .+5
        adds     TOS, #1
        NEXT


	// w2 is the result of subtracting 1 from w1 ( : 1- 1 - ; )
	//                                      MOD:S
	.globl __c_one_minus
__w_one_minus:                                  @ ( n1|u1 -- n2|u2 )
        .byte   2
        .ascii  "1-"
        .balign 4
        .word   __w_one_plus
__c_one_minus:
        .word   .+5
        subs     TOS, #1
        NEXT

	// w2 is the result of adding 2 to w1
	//                                       MOD: S, NON-ANSI?
__w_two_plus:	                                 @ ( w1 -- w2 )
	.byte 2
	.ascii   "2+"
	.balign 4
	.word __w_one_minus
__c_two_plus:
	.word .+5
	adds     TOS, #2
	NEXT


	// w2 is the result of subtracting two from w1
	//                                      MOD: S, NON-ANSI?
__w_two_minus:	                                @ (w1 -- w2)
	.byte    2
	.ascii   "2-"
	.balign 4
	.word __w_two_plus
__c_two_minus:
	.word .+5
	subs     TOS, #2
	NEXT


	// n2 is result of arithmetically shifting n1 right once
	//                                     MOD: S
__w_two_slash:                                  @ ( x1 -- x2 )
        .byte   2
        .ascii  "2/"
        .balign 4
        .word   __w_two_minus
__c_two_slash:
        .word   .+5
	asrs     TOS, TOS, #1
        NEXT
        
        

	// x2 is result of multiplying x1 by 2
	//                                      MOD: ANSI
__w_two_star:                                   @ ( x1 -- x2 )
        .byte   2
        .ascii  "2*"
        .balign 4
        .word   __w_two_slash
__c_two_star:
        .word   .+5
	adds     TOS, TOS
        NEXT


	// store x1,x2 at addr  
	//                                      MOD: ANSI?
	//  x2 -> addr     (MSW)
	//  x1 -> addr+4   (LSW)
__w_two_store:                                  @ ( x1 x2 a-addr -- )
        .byte   2
        .ascii  "2!"
        .balign 4
        .word   __w_two_star
__c_two_store:
        .word   .+5
	pop     {r0}             // Get Most Sig Word
	str     r0, [TOS, #0]    // Store at lowest address
	pop     {r0}             // Get Least Sig Word
	str     r0, [TOS, #4]    // Store at next address
	pop     {TOS}                  // Get new top of stack
        NEXT


	// fetch x1,x2 from address
	//                                      MOD: ANSI?
__w_two_fetch:                                  @ ( a-addr -- x1 x2 )
        .byte   2
        .ascii  "2@"
        .balign 4
        .word   __w_two_store
__c_two_fetch:
        .word   .+5
	ldr     r0, [TOS,#4]  // Get LSW
	push    {r0}          // Push it
	ldr     TOS, [TOS, #0]      // Replace TOS with MSW
        NEXT
        

	//  drop top two values from stack
	//                                      MOD: ANSI?
__w_two_drop:                                   @ ( x1 x2 -- )
        .byte   5
        .ascii  "2DROP"
        .balign 4
        .word   __w_two_fetch
__c_two_drop:
        .word   .+5
	pop     {TOS}             @ should really pop multiple: TOS and scratch
	pop     {TOS}
        NEXT
        

	// duplicate top two stack entries as a double
	//                                     MOD: ANSI?
__w_two_dup:                                   @ ( x1 x2 -- x1 x2 x1 x2 )
        .byte   4
        .ascii  "2DUP"
        .balign 4
        .word   __w_two_drop
__c_two_dup:
        .word   .+5
	pop     {r0}  // Get a copy of LSW
	push    {TOS}       // MOve MSW onto stack, keep a copy in TOS
	push    {r0}  // Put LSW underneath TOS
        NEXT
        

	// duplicate 3rd and 4th stack entries on top of 1st and second
	//                                      MOD: ANSI?
__w_two_over:                                   @ ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
        .byte   5
        .ascii  "2OVER"
        .balign 4
        .word   __w_two_dup
__c_two_over:
        .word   .+5
	pop     {SC2}
	pop     {SC1}
	pop     {SC0}
	push    {SC0}
	push    {SC1}
	push    {SC2}
	push    {TOS}
	mov     TOS, SC1
        NEXT


	// swap positions of x1,x3 and x2,x4
	//                                      MOD: ANSI?
__w_two_swap:                                   @ ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
        .byte   5
        .ascii  "2SWAP"
        .balign 4
        .word   __w_two_over
__c_two_swap:
        .word   .+5
	pop     {r2}    // x3
	pop     {r1}    // x2
	pop     {r0}    // x1
	
	push    {r2}    // x3
	push    {TOS}         // x4
	push    {r0}    // x1
	mov     TOS, r1 // x2
        NEXT
        

	//  Define new secondary word
	//                                      MOD: M, S
__w_colon:                                      @ ( C: "<spaces>name" -- colon-sys )
        .byte   1
        .ascii  ":"
        .balign 4
        .word   __w_two_swap
__c_colon:
        .word   .+5

	@TODO: stuff here
	
        NEXT
        

	// End secondary definition, makes visible, sets interp state
	//                                      MOD: C, I, S
__w_semicolon:                                  @ ( C: colon-sys -- )
        .byte   1 + IMM
        .ascii  ";"
        .balign 4
        .word   __w_colon
__c_semicolon:
        .word   .+5

	@TODO: stuff here
        NEXT
        

	// flag is true if n1 is less than n2
	//                                      MOD: S
__w_less_than:                                  @ ( n1 n2 -- flag )
        .byte   1
        .ascii  "<"
        .balign 4
        .word   __w_semicolon
__c_less_than:
        .word   .+5
	movs    r1, #0
	pop     {r2}
	cmp     r2, TOS   // sub n2 from n1
	beq     1f              // if NOT neg, skip
	mvns    r1, r1
1:	mov     TOS, r1
        NEXT
        

	//  Initialize pictured numeric output
	//                                     MOD: S
__w_less_sharp:                                @ ( -- )
        .byte   2
        .ascii  "<#"
        .balign 4
        .word   __w_less_than
__c_less_sharp:
        .word   .+5

	@TODO: stuff here
	
        NEXT
        

	// flag is true if w1 is equal to w2
	//                                      MOD: S
__w_equals:                                     @ ( x1 x2 -- flag )
        .byte   1
        .ascii  "="
        .balign 4
        .word   __w_less_sharp
__c_equals:
        .word   .+5
	movs    r1, #0         // flag
	pop     {r2}           // x1
	cmp     TOS, r2
	bne     1f                   // skip if not eq
	mvns    r1, r1   // make true
1:	mov     TOS, r1        // replace TOS
        NEXT
        

	// flag is true if n1 is greater than n2
	//                                      MOD: S
__w_greater_than:                               @ ( n1 n2 -- flag )
        .byte   1
        .ascii  ">"
        .balign 4
        .word   __w_equals
__c_greater_than:
        .word   .+5
	movs    r1, #0
	pop     {r2}
	cmp     TOS, r2   // sub n1 from n21
	beq     1f              // if NOT neg, skip
	mvns    r1, r1
1:	mov     TOS, r1
        NEXT
        

	// addr is pfa corresp. to compil. addr xt
	//                                      MOD: S
__w_to_body:                                    @ ( xt -- a-addr )
        .byte   5
        .ascii  ">BODY"
        .balign 4
        .word   __w_greater_than
__c_to_body:
        .word   .+5
	adds    TOS, #4    // PFA is 4 bytes past CA
        NEXT
        

	// addr of a variable containing current offset in input stream
	//                                      MOD: U,S
__w_to_in:                                      @ ( -- a-addr )
        .byte   3
        .ascii  ">IN"
        .balign 4
        .word   __w_to_body
__c_to_in:
        .word   .+5
	push    {TOS}
	//movs    TOS, #TO_IN_OFFSET
	//ldr     TOS, =TO_IN_OFFSET
	mov     r0, USERS
	adds    TOS, r0
        NEXT
        

	// ??
	//                                      MOD: ANSI
__w_to_number:                                  @ ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )
        .byte   7
        .ascii  ">NUMBER"
        .balign 4
        .word   __w_to_in
__c_to_number:
        .word   .+5
        NEXT
        

	// Transfers 32b to return stack
	//                                      MOD: C, S
__w_to_r:                                       @ (32b -- ) ( R: -- 32b )
        .byte   2
        .ascii  ">R"
        .balign 4
        .word   __w_to_number
__c_to_r:
        .word   .+5
	mov     r0, TOS
	pop     {TOS}
	str     r0, [RSP]
	subs    RSP, #4
        NEXT
        

	// Duplicate top entry if it is non-zero
	//                                      MOD: S
__w_question_dup:                              @ ( x -- 0 | x x )
        .byte   4
        .ascii  "?DUP"
        .balign 4
        .word   __w_to_r
__c_question_dup:
        .word   .+5
	orrs    TOS, TOS       // Set flags
	bne     1f
	push    {TOS}          // copy if equal
1:	NEXT
        

	// x is the value at addr
	//                                        MOD: S
__w_fetch:                                      @ ( a-addr -- x )
        .byte   1
        .ascii  "@"
        .balign 4
        .word   __w_question_dup
__c_fetch:
        .word   .+5
	ldr     TOS, [TOS, #0]
        NEXT
        

	// Clears data stack and performs function of QUIT
	//                                        MOD: S
__w_abort:                                      @ ( i*x -- ) ( R: j*x -- )
        .byte   5
        .ascii  "ABORT"
        .balign 4
        .word   __w_fetch
__c_abort:
        .word   do_colon
	.word   __c_s_zero
	.word   __c_sp_store
	.word   __c_quit
        // quit doesn't return

	
	// when later executed, if flag is true "ccc" is printed, then abort
	//                                      MOD: C,I,S
	//                                      @ ( flag -- )
__w_abort_quote:                                @ (C: "ccc<quote>" -- )
        .byte   6 + IMM
        .ascii  "ABORT\""
        .balign 4
        .word   __w_abort
__c_abort_quote:
        .word   .+5
        NEXT
        

	// u is the absolute value of n. if most neg, returns same
	//                                      M: S
__w_abs:                                        @ ( n -- u )
        .byte   3
        .ascii  "ABS"
        .balign 4
        .word   __w_abort_quote
__c_abs:
        .word   .+5
	orrs    TOS, TOS
	bpl     1f       // Don't invert if not neg
	negs    TOS, TOS
1:	NEXT
        

	//  ??  Get some input?
/************************************************************************
6.1.0695 ACCEPT 
CORE        ( c-addr +n1 -- +n2 )
Receive a string of at most +n1 characters. An ambiguous condition exists
if +n1 is zero or greater than 32,767. Display graphic characters as they
are received. A program that depends on the presence or absence of
non-graphic characters in the string has an environmental dependency. The
editing functions, if any, that the system performs in order to construct
the string are implementation-defined.
Input terminates when an implementation-defined line terminator is
received. When input terminates, nothing is appended to the string, and
the display is maintained in an implementation-defined way.

+n2 is the length of the string stored at c-addr.
************************************************************************/
	
	//                                      M: ANSI
__w_accept:                                     @ ( c-addr +n1 -- +n2 )
        .byte   6
        .ascii  "ACCEPT"
        .balign 4
        .word   __w_abs
__c_accept:
        .word   .+5
	mov     r1, TOS       // max count
	pop     {r0}          // address
	bl      receive_line
	mov     TOS, r0
        NEXT
        

	// ??
	//                                      M: ANSI?
__w_align:                                      @ ( -- )
        .byte   5
        .ascii  "ALIGN"
        .balign 4
        .word   __w_accept
__c_align:
        .word   .+5
        NEXT
        

	// ??
	//                                      M: ANSI?
__w_aligned:                                    @ ( addr -- a-addr )
        .byte   7
        .ascii  "ALIGNED"
        .balign 4
        .word   __w_align
__c_aligned:
        .word   .+5
        b       next
        

	// allocates n bytes in the dictionary, free dp updated
	//                                      M: S
__w_allot:                                      @ ( n -- )
        .byte   5
        .ascii  "ALLOT"
        .balign 4
        .word   __w_aligned
__c_allot:
        .word   .+5
        NEXT
        

	// x3 is bitwise AND of x1 and x2
	//                                      M: S
__w_and:                                        @ ( x1 x2 -- x3 )
        .byte   3
        .ascii  "AND"
        .balign 4
        .word   __w_allot
__c_and:
        .word   .+5
	pop     {r0}
	ands    TOS, r0
        NEXT
        

	// Addr of variable containing current numeric radix (2-72)
	//                                      M: U, S
__w_base:                                       @ ( -- a-addr )
        .byte   4
        .ascii  "BASE"
        .balign 4
        .word   __w_and
__c_base:
        .word   .+5
	push    {TOS}
	ldr    TOS, 1f
        NEXT
	.balign 4
1:	.word  BASE_OFFSET

	// marks start of repetitive execution sequence
	//                                      MOD: C, I, S
	//         ( -- )
	//         (C: -- sys )
	//    BEGIN ... flag UNTIL
	//    BEGIN ... flag WHILE ... REPEAT
__w_begin:                                      @ ( C: -- dest )
        .byte   5 + IMM
        .ascii  "BEGIN"
        .balign 4
        .word   __w_base
__c_begin:
        .word   .+5
        NEXT
        

	// ?? emit a space?
	//                                      MOD: ANSI?
__w_bl:                                         @ ( -- char )
        .byte   2
        .ascii  "BL"
        .balign 4
        .word   __w_begin
__c_bl:
        .word   .+5
	movs    r0, #32             // a space
	bl      send_character
        NEXT


	// The addr of var containting block being interpreted as input
	//                                       MOD: M, S, NON_ANSI?
__w_blk:	
	.byte    3                               @ ( -- addr )
	.ascii   "BLK"
	.balign 4
	.word    __w_bl
__c_blk:
	.word    .+5
	NEXT
	

	// addr of the assigned buffer of first byte of block u
	//                                        MOD: M, S, NON_ANSI?
__w_block:	                                  @ ( u -- addr )
	.byte    5
	.ascii   "BLOCK"
	.balign  4
	.word    __w_blk
__c_block:
	.word    . + 5
	NEXT

	// Branch to definition at next word address
	//                                        ANSI?
	.globl __c_branch
__w_branch:	// branch always to following inline address
	.byte 6
	.ascii "BRANCH"
	.balign 4
	.word __w_block
__c_branch:
	.word .+5
	ldr IR, [IR]    // IR points at next word, get next word
	NEXT


	// assigns a block buffer to block u at addr
	//                                     MOD: M, S, NON_ANSI?
__w_buffer:	                               @( u -- addr )
	.byte 6
	.ascii   "BUFFER"
	.balign  4
	.word    __w_branch
__c_buffer:
	.word   .+5
	NEXT


	// Least sig 8 bits of TOS are stored into byte at addr
	//                                      MOD: S
__w_c_store:                                    @ ( char c-addr -- )
        .byte   2
        .ascii  "C!"
        .balign 4
        .word   __w_buffer
__c_c_store:
        .word   .+5
	pop     {r1}
	strb    TOS, [r1]
	pop     {TOS}
        NEXT
        

	// Store byte into dictionary
	//                                      MOD:  ANSI?
__w_c_comma:                                    @ ( char -- )
        .byte   2
        .ascii  "C,"
        .balign 4
        .word   __w_c_store
__c_c_comma:
        .word   .+5
        NEXT
        

	// char is the contents of byte at addr
	//                                      MOD: S
__w_c_fetch:                                    @ ( c-addr -- char )
        .byte   2
        .ascii  "C@"
        .balign 4
        .word   __w_c_comma
__c_c_fetch:
        .word   .+5
	ldrb    r0, [TOS]
	mov     TOS, r0
        NEXT
        

	// ??
	//                                      MOD:  ANSI
__w_cell_plus:                                  @ ( a-addr1 -- a-addr2 )
        .byte   5
        .ascii  "CELL+"
        .balign 4
        .word   __w_c_fetch
__c_cell_plus:
        .word   .+5
        NEXT
        

	// ??
	//                                      MOD: ANSI
__w_cells:                                      @ ( n1 -- n2 )
        .byte   5
        .ascii  "CELLS"
        .balign 4
        .word   __w_cell_plus
__c_cells:
        .word   .+5
        lsls     TOS, #2
        NEXT
        

	// ??
	//                                      MOD: ANSI
__w_char:                                       @ ( "<spaces>name" -- char )
        .byte   4
        .ascii  "CHAR"
        .balign 4
        .word   __w_cells
__c_char:
        .word   .+5
        NEXT
        

	// ??
	//                                      MOD: ANSI
__w_char_plus:                                  @ ( c-addr1 -- c-addr2 )
        .byte   5
        .ascii  "CHAR+"
        .balign 4
        .word   __w_char
__c_char_plus:
        .word   .+5
        NEXT


	// ??
	//                                      MOD: ANSI
__w_chars:                                      @ ( n1 -- n2 )
        .byte   5
        .ascii  "CHARS"
        .balign 4
        .word   __w_char_plus
__c_chars:
        .word   .+5
        b       next
        


	// Move u bytes beginning at addr1 to addr2 (toward high mem)
	//                                     MOD: S
__w_cmove:	                               @( addr1 addr2 u -- )
	.byte   5
	.ascii  "CMOVE"
	.balign 4
	.word   __w_chars
__c_cmove:
	.word   .+5
	NEXT


	// same as cmove but moves down, starting with addr1 + u - 1
	//                                      MOD: S
__w_cmoveup:	                                @( addr1 addr2 u -- )
	.byte   6
	.ascii  "CMOVE>"
	.balign 4
	.word   __w_cmove
__c_cmoveup:
	.word   .+5
	NEXT


// When <name> is executed, compile addr compiled for <namex>
// is compiled and not executed. <name> is typically immediate
// and <namex> is typically not immediate
//  : <name> ... COMPILE <namex> ... ;  MOD: C, S
__w_compile:	                                @( -- )
	.byte   7
	.ascii  "COMPILE"
	.balign 4
	.word   __w_cmoveup
__c_compile:
	.word   .+5
	NEXT


	// Definfing word creates dictionary entry for <name>
	//                                      MOD: M, S
__w_constant:                                   @ ( x "<spaces>name" -- )
        .byte   8
        .ascii  "CONSTANT"
        .balign 4
        .word   __w_compile
__c_constant:
        .word   .+5
        NEXT
        

// +d2 is the result of converting the characters within the
// text beginning at addr1+1 into digits, using the value of
// BASE , and accumulating each into +d1 after multiplying +d1
// by the value of BASE .  Conversion continues until an
// unconvertible character is encounter.  addr2 is the location
// of the first unconvertible character.
//                                      MOD: S
__w_convert:	                                @ ( +d1 addr1 -- +d2 addr2 )
	.byte   7
	.ascii  "CONVERT"
	.balign 4
	.word   __w_constant
__c_convert:
	.word   .+5
	NEXT

	
	// addr2 is addr1+1 and _n is length of counted string at addr1
	//                                      MOD: S
__w_count:	                                @( addr1 -- addr2 +n )
        .byte   5
        .ascii  "COUNT"
        .balign 4
        .word   __w_convert
__c_count:
        .word   .+5
	ldrb    r0, [TOS]   // get count of counted string
	adds    TOS, #1     // bump to next address
	push    {TOS}
	mov     TOS, r0
        NEXT
        

	// Displays a carriage return / line feed equivalent
	//                                      MOD: M, 79
__w_cr:                                         @ ( -- )
        .byte   2
        .ascii  "CR"
        .balign 4
        .word   __w_count
__c_cr:
        .word   .+5
        NEXT
        

	// Creates dictionary entry for <name>, leaving DP -> first byte of PFA
	//                                      MOD: M, S
__w_create:                                     @ ( "<spaces>name" -- )
        .byte   6
        .ascii  "CREATE"
        .balign 4
        .word   __w_cr
__c_create:
        .word   .+5
        NEXT


	// wd3 is the arithmetic sum of wd1 plus wd2
	//                                      MOD: S
__w_d_plus:	                                @( wd1 wd2 -- wd3 )
	.byte   2
	.ascii  "D+"
	.balign 4
	.word   __w_create
__c_d_plus:
	.word   .+5
	pop     {r0}
	pop     {r1}
	pop     {r2}
	add     r0, r2    // lsw
	adcs    TOS, r1   // msw
	push    {r0}      // put lsw back on stack
	NEXT

	// flag is true if d1 is less than d2
	//                                      MOD: S
__w_d_less_than:	                        @( d1 d2 -- flag )
	.byte   2
	.ascii  "D<"
	.balign 4
	.word   __w_d_plus
__c_d_less_than:
	.word   .+5
	NEXT


	//  Sets the input output numeric conversion base to ten
	//                                      MOD: S
__w_decimal:                                    @( -- )
        .byte   7
        .ascii  "DECIMAL"
        .balign 4
        .word   __w_d_less_than
__c_decimal:
        .word   .+5
	ldr     r0, 1f
	movs    r1, 10
	mov     r2, USERS
	str     r1, [r2,r0]
        NEXT
	.balign 4
1:	.word   BASE_OFFSET

	// Compilation vocabulary is changed to search vocabulary
	//                                      MOD: S, NON-ANSI
__w_definitions:	                        @( -- )
	.byte   11
	.ascii  "DEFINITIONS"
	.balign 4
	.word   __w_decimal
__c_definitions:
	.word   .+5
	NEXT
        

	// +n is the number of cells on stack before depth executes
	//                                      MOD: S
__w_depth:                                      @( -- +n )
        .byte   5
        .ascii  "DEPTH"
        .balign 4
        .word   __w_definitions
__c_depth:
        .word   .+5
        NEXT
        

	// d2 is the two's complement of d1
	//                                      MOD: S, NON_ANSI
__w_d_negate:	                                @( d1 -- d2 )
	.byte   7
	.ascii  "DNEGATE"
	.balign 4
	.word   __w_depth
__c_d_negate:
	.word   .+5
	NEXT


	// Begins a loop
	//                                      MOD: C, I, S
__w_do:                       @( C: -- do-sys )  ( n1|u1 n2|u2 -- ) ( R: -- loop-sys )
        .byte   2+IMM
        .ascii  "DO"
        .balign 4
        .word   __w_d_negate
__c_do:
        .word   .+5
        NEXT
        

	// Defines the execution time actionf of a word created by ":"
	//                                      MOD: C, I, S
	//       ( -- addr )
	//       ( -- )  Compiling
__w_does:                                       // ( C: colon-sys1 -- colon-sys2 )
        .byte   5
        .ascii  "DOES>"
        .balign 4
        .word   __w_do
__c_does:
        .word   .+5
        NEXT
        

	// Removes top element from stack
	//                                      MOD: S
__w_drop:                                       @( x -- )
        .byte   4
        .ascii  "DROP"
        .balign 4
        .word   __w_does
__c_drop:
        .word   .+5
        pop     {TOS}
        NEXT


	// Duplicate top stack element
	//                                       MOD: S
	.globl __c_dup
__w_dup:       // duplicate TOS                    // ( x -- x x )
        .byte   3
        .ascii  "DUP"
        .balign 4
        .word   __w_drop
__c_dup:
        .word   .+5
        push    {TOS}
        NEXT
        

	// flag IF ... ELSE ... THEN  -- executes false part after ELSE
	//                                      MOD: C, I, S
__w_else:                                       // ( C: orig1 -- orig2 )
        .byte   4 | IMM
        .ascii  "ELSE"
        .balign 4
        .word   __w_dup
__c_else:
        .word   .+5
        NEXT


	// Least significant 7 bit character is displayed
	//                                      MOD: M, S
	.globl __c_emit
__w_emit:                                       @( x -- )
        .byte   4
        .ascii  "EMIT"
        .balign 4
        .word   __w_else
__c_emit:
        .word   .+5
	mov r0, TOS       @ get TOS into parm 0
	bl   send_character
	pop {TOS}
	
        NEXT
        


	//  ??
	//                                      ANSI
__w_environment_query:                          // ( c-addr u -- false | i*x true )
        .byte 12
        .ascii  "ENVIRONMENT?"
        .balign 4
        .word   __w_emit
__c_environment_query:
        .word   .+5
        NEXT
        

	// ??
	//                                      ANSI
__w_evaluate:                                   // ( i*x c-addr u -- j*x )
        .byte   8
        .ascii  "EVALUATE"
        .balign 4
        .word   __w_environment_query
__c_evaluate:
        .word   .+5
        NEXT
        

	// The word whose address is addr is executed
	//                                      MOD: S
__w_execute:                                    @( addr -- )
	.byte   7
        .ascii  "EXECUTE"
        .balign 4
        .word   __w_evaluate
__c_execute:
        .word   .+5
	mov     r0, TOS
	pop     {TOS}
	ldr     CA, [r0]     // Get code a
	bx      CA
        // shouldn't need this! NEXT
        

	// Compiled within colon definition to return control to calling word.
	//                                      MOD: C, S
__w_exit:                                       // ( -- ) ( R: nest-sys -- )
        .byte   4
        .ascii  "EXIT"
        .balign 4
        .word   __w_execute
__c_exit:
        .word   .+5
        NEXT
        

	// Receive up to +n chars from input stream.
/***************************************************************
EXPECT       addr +n --                    M,83
   Receive characters and store each into memory.  The transfer
   begins at addr proceeding towards higher addresses one byte
   per character until either a "return" is received or until
   +n characters have been transferred.  No more than +n
   characters will be stored.  The "return" is not stored into
   memory.  No characters are received or transferred if +n is
   zero.  All characters actually received and stored into
   memory will be displayed, with the "return" displaying as a
   space.  See:  SPAN  "9.5.2 EXPECT"
***************************************************************/
	//                                      MOD: M, S, NON-ANSI
__w_expect:	                                @( addr +n -- )
	.byte   7
	.ascii "EXPECT"
	.balign 4
	.word   __w_exit
__c_expect:
	.word   .+5
	
	pop     {r0}            // get addr
	mov     r1, TOS         // get count
	bl      receive_line    // Get a line of input
	ldr     r1,  1f         // Store into SPAN
	//movs    r1, #SPAN_OFFSET
	mov     r2, USERS
	str     r0, [r2, r1]    // put #received in SPAN
	pop     {TOS}
	NEXT
	.balign 4
 1:	.word   SPAN_OFFSET


	// u bytes of memory starting at addr are filled with 8b
	//                                      MOD: S
__w_fill:                                       @( addr u 8b -- )
        .byte   4
        .ascii  "FILL"
        .balign 4
        .word   __w_exit
__c_fill:
        .word   .+5

        NEXT
        

	// Search for counted string at addr1, return 0, addr1 if not found,
	// or: addr2 is compilation addr, n=1 for imm, -1 for non-imm.
	//                                      MOD: S
__w_find:                                       @( addr1 -- addr2 n )
        .byte   4
        .ascii  "FIND"
        .balign 4
        .word   __w_fill
__c_find:
        .word   .+5
	// 1: get count from addr and mask
	// 2: if count ==
	// 3: check chars
	// 4: if chars match, exit success
	// 5: addr = link
	// 6: if link == 0, exit fail
	// r5, r6 hold addr and count
	// r3, r4 hold addr and count to compare

	push   {r4-r7}
	movs   r7, #3     // mask for aligning link
	mvns   r7, r7     // invert
	mov    r8, r7     // save for later
	movs   r7, 0x1f   // mask count to 5 bits
	ldrb   r6, [TOS]  // get count
	mov    r4, USERS  // get start address
	//movs   r3, LATEST_OFFSET
	ldr    r3, 9f
	adds   r3, r4

	// compare
4:	ldrb   r4, [r3]  // get the count
	ands   r4, r7    // mask
	cmp    r4, r6    // same count?
	bne    1f        // no
	// yes, check characters
2:	movs   r2, r4    // save count
	ldrb   r0, [r3, r2]  // check from end back
	ldrb   r1, [TOS, r2]
	cmp    r0, r1
	bne    1f        // no match, try next word
	subs   r2, #1    // next char
	beq    3f        // no more, all matched, exit
	b      2b        


1:	// no match, get next link
	adds   r3, r4, #4    // add count +1 for link, 3 for align
	mov    r4, r8        // get the mask
	ands   r3, r4    // mask low 2 bits
	ldr    r3, [r3]  // Finally! Get the next address.
	cmp    r3, #0    // is link zero?
	bne    4b        // no, try again
	// link == 0, checked all words with no match
	mov    r0, TOS   // return original address
	movs   r1, #0    // and 0
	b      5f
	
	
3:	// matched! Get address and immediate status
	mov    r0, r3    // match address
	movs   r1, #1    // mark as immediate
	ldrb   r2, [r0]  // check imm bit
	movs   r3, IMM
	tst    r2, r3
	beq    5f        // if zero, imm bit is set
	negs   r1, r1    // not immediate

5:	// exit
	pop   {r4-r7}
	push  {r0}       // address
	mov   TOS, r1    // immediate status
        NEXT

	.balign  4
9:	.word LATEST_OFFSET

	// Performs SAVE-BUFFERS and unassigns all block buffers
	//                                      MOD: M, S NON-ANSI
__w_flush:	                                @( -- )
	.byte   5
	.ascii  "FLUSH"
	.balign 4
	.word   __w_find
__c_flush:
	.word   .+5
	NEXT


	// Remove <name> and all later defined words from dictionary
	//                                      MOD: M, S, NON-ANSI
__w_forget:	                                @( -- )
	.byte   6
	.ascii  "FORGET"
	.balign 4
	.word   __w_flush
__c_forget:
	.word   .+5
	NEXT


	// Name of primary vocabulary.  Set search order to this vocab
	//                                      MOD: S, NON-ANSI
__w_forth:	                                @( -- )
	.byte   5
	.ascii  "FORTH"
	.balign 4
	.word   __w_forget
__c_forth:
	.word   .+5
	NEXT


	// Assures that a forth-83 standard system is available. Error if not
	//                                      MOD: S, NON-ANSI
__w_forth_83:	                                @( -- )
	.byte   8
	.ascii  "FORTH-83"
	.balign 4
	.word   __w_forth
__c_forth_83:
	.word   .+5
	NEXT


	// ??
	//                                      MOD: ANSI
__w_f_m_slash_mod:                              // ( d1 n1 -- n2 n3 )
        .byte   6
        .ascii  "FM/MOD"
        .balign 4
        .word   __w_forth_83
__c_f_m_slash_mod:
        .word   .+5
        NEXT
        

	// Returns address of next available dictionary position
	//                                      MOD: S
__w_here:                                       @( -- addr )
        .byte    4
	.ascii   "HERE"
        .balign 4
	.word __w_f_m_slash_mod
__c_here:       
	.word .+5
        NEXT
	

	// char is inserted into pictured numeric output string
	//                                      MOD: S
__w_hold:                                       @( char -- )
        .byte   4
        .ascii  "HOLD"
        .balign 4
        .word   __w_here
__c_hold:
        .word   .+5
        NEXT
        

	// w is a copy of the loop index. Used inside do loops
	//                                      MOD: C, S
	//  ( -- w )
__w_i:                                          // ( -- n|u ) ( R: loop-sys -- loop-sys )
        .byte   1
        .ascii  "I"
        .balign 4
        .word   __w_hold
__c_i:
        .word   .+5
        NEXT
        

	// if flag is true words following are executed, else words after ELSE
	// or THEN
	//  flag IF ... [ ELSE ]  ...  THEN ...
	//   ( flag -- )
	//   ( -- sys )  Compiling              MOD: C, I, S
__w_if:                                         // ( C: -- orig )
        .byte   2+IMM
        .ascii  "IF"
        .balign 4
        .word   __w_i
__c_if:
        .word   .+5
        NEXT
        

	// Marks most recently created dictionary entry as immediate
	//                                      MOD: S
__w_immediate:                                  // ( -- )
        .byte 9
        .ascii  "IMMEDIATE"
        .balign 4
        .word   __w_if
__c_immediate:
        .word   .+5
        NEXT
        

	// ?? negates?
	//                                      MOD: ANSI
__w_invert:                                     // ( x1 -- x2 )
        .byte   6
        .ascii  "INVERT"
        .balign 4
        .word   __w_immediate
__c_invert:
        .word   .+5
        mvns     TOS, TOS
        NEXT
        

	// w is copy of index of outer loop
	//                                      MOD: M, S
__w_j:                          // ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
        .byte   1
        .ascii  "J"
        .balign 4
        .word   __w_invert
__c_j:
        .word   .+5
        NEXT
        

	// Least significant byte of TOS is next ASCII char received.
	//                                      MOD: M, S
__w_key:                                        @( -- char )
        .byte 3
        .ascii  "KEY"
        .balign 4
        .word   __w_j
__c_key:
        .word   .+5
	push    {TOS}
	bl      receive_character
	mov     TOS, r0
        NEXT
        

	// Transfers execution to just beyond the next LOOP or +LOOP
	//                                      MOD: C,I,S
	// ( -- )
	// C( -- )
__w_leave:                                      // ( -- ) ( R: loop-sys -- )
        .byte 5+IMM
        .ascii  "LEAVE"
        .balign 4
        .word   __w_key
__c_leave:
        .word   .+5
        NEXT




	// Compiles a system dependent operation so that later 16b is pushed
	//                                      MOD: C, I, S
	//   ( -- 16b )
	//  C( 16b -- )
	.globl __c_literal
__w_literal:                                    // ( x -- )
        .byte   7+IMM
        .ascii  "LITERAL"
        .balign 4
        .word   __w_leave
__c_literal:                                 // Number literal handler
        .word   .+5
        NEXT
	
	.globl do_literal
	.balign 4
do_literal:	       // Pushes next word in thread to stack
	.word    .+5
        push    {TOS}                 // Make room for the number
        ldr     TOS, [IR]             // Push next secondary entry
        adds     IR, #4                // Skip over the number
	NEXT


	// Contents of >IN and BLK are saved
	//                                      MOD: M, S
	//   (u -- )
__w_load:	                                @( u -- )
	.byte   4
	.ascii  "LOAD"
	.balign 4
	.word   __w_literal
__c_load:
	.word .+5
	NEXT


	// Increments the DO-LOOP index by one. If boundary crossed, exit
	//                                      MOD: C, I, S
	//  C( sys -- )
__w_loop:                                       // ( C: do-sys -- )
        .byte   4+IMM
        .ascii  "LOOP"
        .balign 4
        .word   __w_load
__c_loop:
        .word   .+5
        NEXT
        

	// Left Shift x1 by u places?
	//                                      MOD: ANSI
__w_lshift:                                     // ( x1 u -- x2 )	
        .byte   6
        .ascii  "LSHIFT"
        .balign 4
        .word   __w_loop
__c_lshift:
        .word   .+5
        pop     {SC2}
        lsls     SC2, TOS
        mov     TOS, SC2
        NEXT
        

	// ??
	//                                      MOD: ANSI
__w_m_star:                                     // ( n1 n2 -- d )
        .byte   2
        .ascii  "M*"
        .balign 4
        .word   __w_lshift
__c_m_star:
        .word   .+5
        NEXT
        

	// n3 is the greater of n1 and n2 according to operation ">"
	//                                      MOD: S
__w_max:                                        // ( n1 n2 -- n3 )
        .byte   3
        .ascii  "MAX"
        .balign 4
        .word   __w_m_star
__c_max:
        .word   .+5
	pop     {SC2}
	cmp     TOS, SC2
	bmi	1f
	mov     TOS, SC2
1:	
        NEXT
        

	// n3 is the lesser of n1 and n2 according to the operation "<"
	//                                      MOD: S
__w_min:                                        // ( n1 n2 -- n3 )
        .byte   3
        .ascii  "MIN"
        .balign 4
        .word   __w_max
__c_min:
        .word   .+5
	pop     {SC2}
	cmp     SC2, TOS
	bmi	1f
	mov     TOS, SC2
1:	
        NEXT
        

	// n3 is the remainder after dividing n1 by n2, and sign of n2.
	//                                      MOD: S
__w_mod:                                        // ( n1 n2 -- n3 )
        .byte   3
        .ascii  "MOD"
        .balign 4
        .word   __w_min
__c_mod:
        .word   .+5
        NEXT
        

	// move words ? ansi
	//                                      MOD: ANSI
__w_move:                                       // ( addr1 addr2 u -- )
	.byte   4
        .ascii  "MOVE"
        .balign 4
        .word   __w_mod
__c_move:
        .word   .+5
        NEXT
        

	// n2 is the two's complement of n1
	//                                      MOD: S
__w_negate:                                     // ( n1 -- n2 )
	.byte   6
        .ascii  "NEGATE"
        .balign 4
        .word   __w_move
__c_negate:
        .word   .+5
	rsbs    TOS, #0
 //       mvns     TOS, TOS
 //       adds     TOS, #1
        NEXT
        

	// 16b2 is the one's complement of 16b1
	//                                      MOD: S, NON-ANSI
__w_not:	                                @ ( 16b1 -- 16b2 )
	.byte   3
	.ascii  "NOT"
	.balign 4
	.word   __w_negate
__c_not:
	.word  .+5
	mvns   TOS, TOS
	NEXT


	// 16b3 is the bit by bit inclusive or of 16b1 with 16b2
	//                                      MOD: S
__w_or:	                                        // ( x1 x2 -- x3 )
        .byte   2
        .ascii  "OR"
        .balign 4
        .word   __w_not
__c_or:
        .word   .+5
        pop     {SC2}
        orrs      TOS, SC2
        NEXT
        

	// 16b3 is a copy of 16b1
	//                                      MOD: S
	//   ( 16b1 16b2 -- 16b1 16b2 16b3 )
__w_over:                                       // ( x1 x2 -- x1 x2 x1 )
	.byte   4
        .ascii  "OVER"
        .balign 4
        .word   __w_or
__c_over:
        .word   .+5
        push    {TOS}
        ldr     TOS, [SP, #4]
        NEXT


	// Lower address of a scratch area for immediate processing
	//                                      MOD: U, S, NON-ANSI
__w_pad:	                                @( -- addr )
	.byte   3
	.ascii  "PAD"
	.balign 4
	.word   __w_over
__c_pad:
	.word   .+5
	mov     SC2, USERS
	ldr     SC1, 1f
	adds    SC2, SC1
	push    {TOS}
	mov     TOS, SC2
	NEXT
	.balign 4
1:	.word   PAD_OFFSET

	// 16b is a copy of the +nth stack value, not counting +n
	//                                     MOD: S, NON-ANSI
__w_pick:	                               @( +n -- 16b )
	.byte   4
	.ascii  "PICK:"
	.balign 4
	.word   __w_pad
__c_pick:
	.word   .+5
	NEXT

	
	// ??  ANSI
	//                                      MOD: ANSI
__w_postpone:                                   // ( "<spaces>name" -- )
	.byte   8
        .ascii  "POSTPONE"
        .balign 4
        .word   __w_pick
__c_postpone:
        .word   .+5
        NEXT


	// From "Moving Forth" branch if tos == 0
	//   (flag -- )                         MOD:  ??
	.globl __c_q_branch
__w_q_branch:	    // branch if TOS = 0
	.byte 7
	.ascii  "?BRANCH"
	.balign 4
	.word __w_postpone
__c_q_branch:
	.word   .+5
	orrs    TOS, TOS    // update zero flag
	
	bne   1f   // if not zero, skip the branch
	ldr IR, [IR]    // IR points at next word, get next word
	b     2f
1:	adds  IR, #4
2:	pop   {TOS}
	NEXT


	// Clears the return stack, sets interpret st, gets input, begins interpret
	//                                      MOD: S
__w_quit:                                       // ( -- ) ( R: i*x -- )
	.byte   4
        .ascii  "QUIT"
        .balign 4
        .word   __w_q_branch
__c_quit:                       // Near copy of Brad Rodriguez' Z80 Camelforth
        .word   do_colon
	.word   __c_r_zero
	.word   __c_rp_store
	.word   do_literal
	.word   0
	.word   __c_state
	.word   __c_store
1:	.word   __c_tib
	.word   __c_dup
	// tibsize
	.word   do_literal
	.word   TIB_BYTES
	//  .word   __c_accept?
	.word   __c_space
//	.word   __c_interpret
	.word   __c_state
	.word   __c_fetch
	.word   __c_zero_equals
	.word   __c_q_branch
	.word   2f
	.word   __c_cr
	// .word   xsquote
	//  .byte 3, "ok "
	//  .word __c_type
2:	.word   __c_branch
	.word   1b
	
        

	// 16b is removed from the return stack and moved to data stack
	//                                      MOD: C, S
	//   ( -- 16b)   R( 16b -- )
__w_r_from:                                     // ( -- x ) ( R: x -- )
	.byte 2
	.ascii "R>"
        .balign 4
        .word   __w_quit
__c_r_from:
        .word   .+5
        NEXT
        

	// 16b is a copy of the top of the return stack
	//                                      MOD: C, S
	//   ( -- 16b )   R( 16b -- 16b )
__w_r_fetch:                                    // ( -- x ) ( R: x -- x )
	.byte 2
	.ascii "R@"
        .balign 4
        .word   __w_r_from
__c_r_fetch:
        .word   .+5
        NEXT
        

	// Call word currently being compiled
	//                                      MOD:  ANSI
__w_recurse:                                    // ( -- )
	.byte   7
        .ascii  "RECURSE"
        .balign 4
        .word   __w_r_fetch
__c_recurse:
        .word   .+5
        NEXT
        

	// Continues execution to just after corresponding BEGIN
	//                                      MOD: C, I, S
	//   ( -- )
	//  C( sys -- )
__w_repeat:                                     // ( C: orig dest -- ) ( -- )
	.byte   6
        .ascii  "REPEAT"
        .balign 4
        .word   __w_recurse
__c_repeat:
        .word   .+5
        NEXT
        

	// The +nth stack value (before +n) is moved to top of stack
	//                                      MOD: S, NON-ANSI
	//   (+n -- )
__w_roll:	                                @( +n -- )
	.byte   4
	.ascii  "ROLL"
	.balign 4
	.word   __w_repeat
__c_roll:
	.word   .+5
	NEXT


	//  Top three stack entries rotate, bringing third to top
	//                                      MOD: S
__w_rot:                                        // ( x1 x2 x3 -- x2 x3 x1 )
	.byte   3
        .ascii  "ROT"
        .balign 4
        .word   __w_roll
__c_rot:
        .word   .+5
	pop     {SC2}
	pop     {SC1}
	push    {SC2}
	push    {TOS}
	mov     TOS, SC1
	
        NEXT
        

	//  shift right ?? ansi ??
	//                                     MOD: ANSI
__w_rshift:                                    // ( x1 u -- x2 )
	.byte   6
        .ascii  "RSHIFT"
        .balign 4
        .word   __w_rot
__c_rshift:
        .word   .+5
        pop     {SC2}
        lsrs     TOS, TOS, SC2
        NEXT
        

	// ?? ansi
	//                                     MOD: C?, ANSI
__w_squote:                                    // ( "ccc<quote>" -- ) ( -- c-addr u )
	.byte   2
        .ascii  "S\""
        .balign 4
        .word   __w_rshift
__c_squote:
        .word   .+5
        NEXT
        

	// ?? ansi?
	//                                      MOD: ANSI
__w_s_to_d:                                     // ( n -- d )
	.byte   3
        .ascii  "S>D"
        .balign 4
        .word   __w_squote
__c_s_to_d:
        .word   .+5
        NEXT
        

	// all block buffers marked UPDATEd are written
	//                                      MOD: M, S
__w_save_buffers:	                        @( -- )
	.byte   12
	.ascii  "SAVE-BUFFERS"
	.balign 4
	.word   __w_s_to_d
__c_save_buffers:
	.word   .+5
	NEXT
	

	// If n is negative, "-" is appended to pictured numeric
	//                                      MOD: S
__w_sign:                                       // ( n -- )
	.byte   4
        .ascii  "SIGN"
        .balign 4
        .word   __w_save_buffers
__c_sign:
        .word   .+5
        NEXT
        

	// ?? ansi?
	//                                      MOD: ANSI
__w_s_m_slash_rem:                              // ( d1 n1 -- n2 n3 )
	.byte   6
        .ascii  "SM/REM"
        .balign 4
        .word   __w_sign
__c_s_m_slash_rem:
        .word   .+5
        NEXT
        

	// ?? ansi?
	//                                      MOD: ANSI
__w_source:                                     // ( -- c-addr u )
	.byte   6
        .ascii  "SOURCE"
        .balign 4
        .word   __w_s_m_slash_rem
__c_source:
        .word   .+5
        NEXT
        

	// Displays an ASCII space
	//                                      MOD: M, S
__w_space:                                      // ( -- )
	.byte   5
        .ascii  "SPACE"
        .balign 4
        .word   __w_source
__c_space:
        .word   .+5
        NEXT
        

	// Displays +n spaces, unless n = 0
	//                                      MOD: M, S
__w_spaces:                                     // ( n -- )
	.byte   6
        .ascii  "SPACES"
        .balign 4
        .word   __w_space
__c_spaces:
        .word   .+5
        NEXT
        

	// Addr of var with count of chars actually received by EXPECT
	//                                      MOD: U, S, NON-ANSI
	//   ( -- addr )
__w_span:	                                @( -- addr )
	.byte   4
	.ascii  "SPAN"
	.balign 4
	.word   __w_spaces
__c_span:
	.word   do_user
	.word   SPAN_OFFSET
	


	.globl  __c_state
	.globl  ld1
	.globl  ld2
	
	// Addr of var containing compilation state: != zero compiling
	//                                      MOD: U, S
__w_state:                                      // ( -- a-addr )
	.byte   5
        .ascii  "STATE"
        .balign 4
        .word   __w_span
__c_state:
        .word   .+5
        push    {TOS}
	ldr     TOS, =var_state
	NEXT

	
	// Top two stack entries are exchanged
	//                                      MOD: S
__w_swap:                                       // ( x1 x2 -- x2 x1 )
	.byte   4
        .ascii  "SWAP"
        .balign 4
        .word   __w_state
__c_swap:
        .word   .+5
        pop     {SC2}
        push    {TOS}
        mov     TOS, SC2
        NEXT
        

	// THEN is where execution continues after IF/ELSE
	//   ( -- )                             MOD: C, I, S
	//  C( sys -- )
__w_then:                                       // ( C: orig -- ) ( -- )
	.byte   4+IMM
        .ascii  "THEN"
        .balign 4
        .word   __w_swap
__c_then:
        .word   .+5
        NEXT
        

	// Addr of text input buffer.
	//                                      MOD: M, S, NON-ANSI
	//   ( -- addr )
__w_tib:	                                @( -- addr )
	.byte   3
	.ascii  "TIB"
	.balign 4
	.word   __w_then
__c_tib:
	.word   .+5
	push    {TOS}
	ldr     TOS, =sys_tib
	NEXT


	// +n chars are displayed from memory at addr
	//                                      MOD: M, S
__w_type:                                       // ( c-addr u -- )
	.byte   4
        .ascii  "TYPE"
        .balign 4
        .word   __w_tib
__c_type:
        .word   .+5
	pop     {SC2}      // the address
	movs    SC0, #0    // The index
	
1:	cmp     TOS, SC0
	beq     2f
	ldrb    SC1, [SC0,SC2]
	push    {r0}
	mov  r0, SC1
	bl   send_character
	pop  {r0}
	adds SC0, #1
	b 1b
	
2:	pop {TOS}
        NEXT
        

	// u is displayed as unsigned number in free field
	//                                      MOD: M, S
__w_u_dot:                                      // ( u -- )
	.byte   2
        .ascii  "U."
        .balign 4
        .word   __w_type
__c_u_dot:
        .word   .+5
        NEXT
        

	// flag is true if u1 is less than u2
	//                                      MOD: S
__w_u_less_than:                                // ( u1 u2 -- flag )
	.byte   2
        .ascii  "U<"
        .balign 4
        .word   __w_u_dot
__c_u_less_than:
        .word   .+5
        NEXT
        

	// ud is the unsigned product of u1 times u2
	//                                      MOD: S
__w_u_m_star:                                   // ( u1 u2 -- ud )
	.byte   3
        .ascii  "UM*"
        .balign 4
        .word   __w_u_less_than
__c_u_m_star:
        .word   .+5
        NEXT
        

	// u2 is remainder and ud floor quotient of ud/u1
	//                                      MOD: S
__w_u_m_slash_mod:                              // ( ud u1 -- u2 u3 )
	        .byte   6
        .ascii  "UM/MOD"
        .balign 4
        .word   __w_u_m_star
__c_u_m_slash_mod:
        .word   .+5
        NEXT
        

	// ?? ansi?
	//                                      MOD: ANSI
__w_unloop:                                     // ( -- ) ( R: loop-sys )
	.byte   6
        .ascii  "UNLOOP"
        .balign 4
        .word   __w_u_m_slash_mod
__c_unloop:
        .word   .+5
        NEXT
        

	// Marks end of a BEGIN-UNTIL loop
	//                                      MOD: C, I, S
	//   ( flag -- )
	//  C( sys -- )
__w_until:                                      // ( C: dest -- ) ( x -- )
	.byte   5
        .ascii  "UNTIL"
        .balign 4
        .word   __w_unloop
__c_until:
        .word   .+5
        NEXT
        

	// Currently valid block buffer is marked as modified
	//                                      MOD: S, NON-ANSI
	//   ( -- )
__w_update:	                                @( -- )
	.byte   6
	.ascii  "UPDATE"
	.balign 4
	.word   __w_until
__c_update:
	.word   .+5
	NEXT


	// Defining word, creates dictionary entry for <name>
	//                                      MOD: M, S
__w_variable:                                   // ( "<spaces>name" -- )
	.byte   8
        .ascii  "VARIABLE"
        .balign 4
        .word   __w_update
__c_variable:
        .word   .+5
        NEXT
        

	// Defining word, creates dictionary entry for <name>
	//                                      MOD: M, S, NON-ANSI
	//   ( -- )
__w_vocabulary:	                                @( -- )
	.byte   10
	.ascii  "VOCABULARY"
	.balign 4
	.word   __w_variable
__c_vocabulary:
	.word   .+5
	NEXT


	// Selects conditional exucution based on flag
	//                                      MOD: C, I, S
	//   ( flag -- )
	//  C( sys1 -- sys2)
__w_while:                                      // ( C: dest -- orig dest )
	.byte   5+IMM
        .ascii  "WHILE"
        .balign 4
        .word   __w_vocabulary
__c_while:
        .word   .+5
        NEXT
        

	// Inputs chars as word to counted string
	//                                      MOD: M, S
__w_word:                                       // ( char "<chars>ccc<char>" -- c-addr )
	.byte   4
        .ascii  "WORD"
        .balign 4
        .word   __w_while
__c_word:
        .word   .+5
        NEXT
        
	// 16b3 is the bit by bit exclusive or of 16b1 and 16b2
	//                                      MOD: S
__w_xor:                                        // ( x1 x2 -- x3 )
	.byte   3
        .ascii  "XOR"
        .balign 4
        .word   __w_word
__c_xor:
        .word   .+5
        pop     {SC2}
        eors     TOS, SC2
        NEXT
        

	// Sets interpret state
	//                                      MOD: I, S
	//   ( -- )   C( -- )
__w_left_bracket:                               // ( -- )
	.byte 1
        .ascii  "["
        .balign 4
        .word   __w_xor
__c_left_bracket:
        .word   .+5
        NEXT
        

	// Compiles the comp add of <name> as a literal
	//                                      MOD: C, I, M, S
	//   ( -- addr )
	//  C( -- )
__w_bracket_tick:                               // ( "<spaces>name" -- )
	.byte   2
        .ascii  "[']"
        .balign 4
        .word   __w_left_bracket
__c_bracket_tick:
        .word   .+5
        NEXT
        

	// ?? ansi?
	//                                      MOD: ANSI
__w_bracket_char:                               // ( "<spaces>name" -- )
	.byte   6
        .ascii  "[CHAR]"
        .balign 4
        .word   __w_bracket_tick
__c_bracket_char:
        .word   .+5
        NEXT
        

	// Forces compilation of the following word <name>
	//                                      MOD: C, I, M, S, NON-ANSI
	//   ( -- )
	//  C( -- )
	//   [COMPILE] <name>
__w_bracket_compile:	                        @( -- )
	.byte   9+IMM
	.ascii  "[COMPILE]"
	.balign 4
	.word   __w_bracket_char
__c_bracket_compile:
	.word   .+5
	NEXT


	// Sets compilation state. Text from input is subsequently compiled
	//                                     MOD: S
        .globl  __w_right_bracket
        .globl  __c_right_bracket
__w_right_bracket:                              // ( -- )
	.byte   1
        .ascii  "]"
        .balign 4
        .word   __w_bracket_compile
__c_right_bracket:
        .word   .+5
        NEXT
        


        .balign 4
        
	@ core extension words


	@ Uncontrolled reference words

/***************************************************************

S0           -- addr                       U             "s-zero"
     A variable containing the address of the bottom of the
     stack.
****************************************************************/

__w_s_zero:
	.byte   2
	.ascii  "S0"
	.balign 4
	.word   __w_right_bracket
__c_s_zero:
	.word   do_user
	.word   S0_OFFSET
	
/****************************************************************
USER         +n --                         M
      A defining word executed in the form:
            +n USER <name>
      which creates a user variable <name>.  +n is the offset
      within the user area where the value for <name> is stored.
      Execution of <name> leaves its absolute user area storage
      address.
*******************************************************************/

__w_user:
	.byte   4
	.ascii  "USER"
	.balign 4
	.word   __w_s_zero
__c_user:
	.word   .+5
	NEXT




	@ Non-Standard (My) Words

/****************************************************************
SP!       ( w -- )
	Stores W into the Parameter Stack Pointer
****************************************************************/

__w_sp_store:
	.byte   3
	.ascii  "SP!"
	.balign 4
	.word   __w_user
__c_sp_store:
	.word   .+5
	pop     {SC2}
	mov     PSP, SC2
	NEXT


/****************************************************************
RP!       ( w -- )
	Stores W into the Return Stack Pointer
****************************************************************/

__w_rp_store:
	.byte   3
	.ascii  "SP!"
	.balign 4
	.word   __w_sp_store
__c_rp_store:
	.word   .+5
	pop     {SC2}
	mov     RSP, SC2
	NEXT




/***************************************************************

R0           -- addr                       U             "r-zero"
     A variable containing the address of the bottom of the
     return stack.
****************************************************************/

__w_r_zero:
	.byte   2
	.ascii  "R0"
	.balign 4
	.word   __w_right_bracket
__c_r_zero:
	.word   do_user
	.word   R0_OFFSET






	
/***************************************************************/
/*    Words for outer interpreter */

__w_cold:                  // Cold start
	.byte 4
	.ascii  "COLD"
	.balign 4
	.word   __w_rp_store
__c_cold:
	.word do_colon
	
//	.word __h_literal
//	.word 'C'
//	.word __c_emit

	// test udiv_32
	.word do_literal
	.word 13000
	.word do_literal
	//.word 200
	.word 4294967096
	.word __c_slash   // divide 13000/200
	.word __c_emit    // should be an A
	
	.word do_literal
	.word sign_on_message
	.word __c_dup
	.word __c_one_plus
	.word __c_swap
	.word __c_c_fetch

//	.word __c_dup
//	.word __c_emit
	
	.word __c_type

	// test expect
2:	.word __c_tib
	.word do_literal
	.word   32
	.word __c_expect

	.word __c_span
	.word __c_fetch
	.word __c_tib
	.word __c_swap

	.word do_literal
	.word 13
	.word __c_emit
	.word do_literal
	.word 10
	.word __c_emit
	
	.word __c_type
	.word __c_branch
	.word 2b


	
1:	.word __c_key
	.word __c_emit
	.word __c_branch
	.word 1b

	@TODO: stuff here

	.word    semi
	

	////////////////////////////////////////////
	////////////////////////////////////////////
	/////////////////    TEST WORDS
	
colon_test:
	.word  do_colon
	.word  do_literal
	.word  'S'
	.word  __c_emit
	.word  semi
	

goofy_word:
	.word   do_colon
	.word   do_literal
	.word   ':'
	.word   __c_emit
	.word   colon_test
	.word   semi
	
first_const:
	.word    do_constant
	.word    'z'
	NEXT

	///////////////////////////////////////////
	///////////////////////////////////////////
	///////////////////   END TEST WORDS

	
	.globl outer_interp
outer_interp:
        .globl  __w_outer
        .globl  __c_outer
__w_outer:                              // ( -- )
	.byte   5
        .ascii  "outer"
        .balign 4
        .word   __w_right_bracket
__c_outer:
	.word   __c_cold
	
	
	.word   do_literal
	.word    100
loop:	.word   do_literal
	.word   '>'                // emit a <
	.word   __c_emit           // emit
	.word   do_literal
	.word   'H'
	.word   __c_emit
	.word   do_literal
	.word   'I'
	.word   __c_emit
	.word   do_literal
	.word   ' '
	.word   __c_emit
	.word   __c_one_minus
	.word   __c_dup
	.word   __c_zero_equals
	.word   __c_q_branch

	//.word   __c_branch
	.word   loop       // branch back to start
	.word   do_literal
	.word  'X'
	.word   __c_emit
	.word   do_literal
	.word     6500
	.word   do_literal
	.word   100
	.word   __c_slash
	.word   __c_emit
	.word   __c_state
	.word   goofy_word
	.word   goofy_word
	.word   colon_test
	.word   first_const
	.word   __c_emit
	
	.word   semi
        
	.globl last_entry
	.equ  last_entry, __w_outer
	
