/*****************************************************************************
fortharm  forth for arm cortex m0 (LPC1114)
copyright(c) 2013 William R Cooke
*/

#include "defines.h"

        
	.data
	
	.globl sign_on_message
sign_on_message:
	.byte sign_on_message_end - sign_on_message - 1
	.ascii "ForthARM 0.1 (c) 2017 William R Cooke"
	.byte 13,10
sign_on_message_end:	

	.bss

        @ word vars first
        .globl  sys_base
        .globl  sys_here
        .globl  sys_state
	
	.globl  user_start

	.globl  var_state

	.balign 4
	
user_start:
	// words first
var_u0:	        .word  0        // Link to next UP
var_s0:		.word  0        // Bottom of stack
var_r0:		.word  0        // Bottom of return stack

var_to_in:	.word  0
var_base:	.word  0
var_span:	.word  0        // number of characters input
var_state:	.word  0
var_dp:		.word  0
var_latest:	.word  0         // Link to last dictionary entry
var_pad:	.word  0       // Location of pad
		.skip  PAD_BYTES-4
	
		.skip  STACK_BYTES-4
var_stack:	.word  0     // Last word of stack
		.skip  RSTACK_BYTES-4   // room for return stack
var_rstack:	.word  0      // Last word of rstack
	
//var_tick_source:	.word    // ??? ansi?
//var_hp:		.word            // ???
//var_lp:		.word            // ??? ansi?


	
	
	/**********************  From Brad Rodriguez
	User vars	value(offset in user area)
	U0                00  Current user area address       +0
	>IN               02  offst into TIB                  +2
	BASE              04  number conversion radix (2-71)  +2
	STATE             06  compiler state                  +2
	DP                08  dictionary pointer              +2
	'SOURCE (2 words) 10  two cells: len, addr ???        +2
	LATEST            14  latest word in dictionary       +4
	HP                16  Hold Pointer                    +2
	LP                18  Leave Stack Pointer             +2
	S0               256  (100h) End of Stack             +238
	PAD              296  (128h) User pad buffer          +40
	L0               384  (180h) Bottom of Leave Stack    +88
	R0               512  (200h) End of Return Stack      +128
	
	 From Brad Rodriguez Z80 Camel Forth
	********************************************************/

	.globl U0_OFFSET
	.globl S0_OFFSET
	.globl R0_OFFSET
	.globl TO_IN_OFFSET
	.globl BASE_OFFSET
	.globl SPAN_OFFSET
	.globl DP_OFFSET
	.globl LATEST_OFFSET
	.globl PAD_OFFSET
	.globl STACK_OFFSET
	.globl RSTACK_OFFSET
	
	.equ  U0_OFFSET,     (var_u0 - user_start)
	.equ  S0_OFFSET,     (var_s0 - user_start)
	.equ  R0_OFFSET,     (var_r0 - user_start)
	.equ  TO_IN_OFFSET,  (var_to_in-user_start)
	.equ  BASE_OFFSET,   (var_base - user_start)
	.equ  SPAN_OFFSET,   (var_span - user_start)
	.equ  STATE_OFFSET,  (var_state - user_start)
	.equ  DP_OFFSET,     (var_dp - user_start)
	.equ  LATEST_OFFSET, (var_latest - user_start)
	.equ  PAD_OFFSET,    (var_pad - user_start)
	.equ  STACK_OFFSET,  (var_stack - user_start)
	.equ  RSTACK_OFFSET, (var_rstack - user_start)

	
// Holds number of characters in TIB
	.globl    sys_number_tib
sys_number_tib:	  .word
	
        @ halfword vars


        @ byte vars

	.globl  sys_tib
sys_tib:        .skip TIB_BYTES

//   The dictionary starts after all the system data
	
free_dictionary:

	

/************************************************************/
	.text
	.balign 4
	.syntax unified
	.thumb
	.thumb_func
	.global forth

        @ some handy constants
        @ put them here for easy access
        

forth_exit:		@ Exit the forth system back to c
	@ get ret address from storage location
	@ bx to it
	
forth:
	push {lr}
	
forth_start:
        movs    r0,#10          @ set base
        ldr     r1, =var_base
	str     r0, [r1, 0]
	ldr     r1, =next
	adds    r1, #1   // make it thumb compatible
	mov     r12, r1
	// set up RSP
	mov     RSP, sp
	mov     r0, sp
	adds    r0, #-128
	mov     sp, r0

	ldr     r0, =user_start
	mov     USERS, r0
	bl      user_initialize     // Set up the main user area
	
     
forth_restart:

	@ set system (non-user) variables
	movs    r0, #0
	ldr     r1, =sys_number_tib
	str     r0, [r1]

        @ put outer interp address in IR
	ldr   IR, = __c_outer

        @ and jump to inner interp
        b       next

        
	.globl inner_interp
	.globl  semi
	.globl  next
	
inner_interp:
semi:	.word   . + 5
	ldr     IR, [RSP]
	adds    RSP, #4
	
next:	
        ldr     WA, [IR]
	adds    IR, #4

run:	ldr     CA, [WA]
	adds    WA, #4
	
	//mov r0, CA          // show CA, should be CA of h_literal
	//bl      forth_printnum

	bx      CA

/*************************************************
*  do_colon
*  Execute a secondary (colon) definition
*************************************************/
			
	.text
	.balign 2
	.syntax unified
	.thumb
	.thumb_func
	.global do_colon

do_colon:
	subs  RSP, #4
	str   IR, [RSP]     // Save the IR
	mov   IR, WA        // WA is pointing at first WA of THIS word
	NEXT


/*************************************************
*  do_constant
*  Push a constant value on the stack
*************************************************/
			
	.text
	.balign 2
	.syntax unified
	.thumb
	.thumb_func
	.global do_constant

do_constant:
	push   {TOS}        // Make room
	ldr    TOS, [WA]    // WA already incremented
	NEXT
	

/*************************************************
*  do_variable
*  Push address of a variable on the stack
*  Since we are in flash, vars are NOT in the
*  normal dictionary space, so we hold only the
*  address of where it actually is stored.  That
*  means that do_variable works exactly like
*  do_constant
*************************************************/
			
	.text
	.balign 2
	.syntax unified
	.thumb
	.thumb_func
	.global do_variable

do_variable:
	push   {TOS}        // Make room
	ldr    TOS, [WA]    // WA already incremented
	NEXT
	

/*************************************************
*  do_user
*  User variables are stored in a "structure" that
*  could potentially be anywhere in memory.  We
*  need to add the offset, stored in the user
*  variable, to the base address (which can change)
*  and push the resulting address on the stack
*  Works like do_variable, but
*  adds the user pointer to the value before pushing
*************************************************/
			
	.text
	.balign 2
	.syntax unified
	.thumb
	.thumb_func
	.global do_user

do_user:
	push   {TOS}           // Make room
	ldr    TOS, [WA]       // WA already incremented
	mov    SC2, USERS
	adds   TOS, SC2        // Add to base pointer
	NEXT
	

/****************************************************
* Initialize a (new) user area with proper contents
* Enter with r0 set to new user area adress
*
****************************************************/
	
	.text
	.balign 4
	.syntax unified
	.thumb
	.thumb_func
	.global user_initialize
user_initialize:
	movs r1, #0
	str  r1, [r0, #U0_OFFSET]  // Really not sure what needs to go here
	str  r1, [r0, #TO_IN_OFFSET]  // empty
	str  r1, [r0, #STATE_OFFSET]  // not in compile state
	movs r1, #10                  // start in decimal
	str  r1, [r0, #BASE_OFFSET]
	ldr  r1, =last_entry
	str  r1, [r0, #LATEST_OFFSET]
	// TODO: Fix the dictionary pointer!!!
	ldr  r1, =free_dictionary
	str  r1, [r0, #DP_OFFSET]
	ldr  r1, =var_stack
	str  r1, [r0, #S0_OFFSET]
	ldr  r1, =var_rstack
	str  r1, [r0, R0_OFFSET]


	bx   lr


		.text
	.balign 4
	.syntax unified
	.thumb
	.thumb_func
	.global user_initial_data
user_initial_data:
	.word  0        // U0
	.word  0        // S0
	.word  0        // R0
	.word  0        // TO_IN
	.word  0        // BASE
	.word  0        // SPAN
	.word  0        // STATE
	.word  0        // DP
	.word  last_entry  // LATEST
	

/*
	
#	.equ  U0_OFFSET, (var_u0 - user_start)
#	.equ  TO_IN_OFFSET, (var_to_in - user_start)
#	.equ  BASE_OFFSET,  (var_base - user_start)
#	.equ  STATE_OFFSET, (var_state - user_start)
#	.equ  DP_OFFSET,    (var_dp - user_start)
#	.equ  LATEST_OFFSET, (var_latest - user_start)
#	.equ  S0_OFFSET,     (var_s0 - user_start)
#	.equ  R0_OFFSET...
	.equ  PAD_OFFSET,    (var_pad - user_start)
	.equ  STACK_OFFSET,  (var_stack - user_start)
	.equ  RSTACK_OFFSET, (var_rstack - user_start)

	*/
	
