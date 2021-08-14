/*****************************************************************************
fortharm  forth for arm cortex m0 (LPC1114)
copyright(c) 2013 William R Cooke
*/

#include "defines.h"

        
	.data


	.bss
        @ system variables

        @ word vars first
        .globl  sys_base
        .globl  sys_here
        .globl  sys_state
sys_base:       .word
sys_here:       .word
sys_state:      .word
        @ halfword vars


        @ byte vars
sys_tib:        .byte
	
	.text
	.balign 4
	.syntax unified
	.thumb
	.thumb_func
	.global forth

        @ some handy constants
        @ put them here for easy access
        
forth:
        push {lr}
        mov r1,r0
        add r0,r0               ;
        add r0,r1
        pop {pc}


forth_start:
        movs    r0,#10          @ set base
        ldr     r1, =sys_base
        str     r0, [r1, 0]
        
        

forth_restart:  




        @ put outer interp address in IR

        @ and jump to inner interp
        b       next

        
	.globl inner_interp
	.globl  semi
	.globl  next
	
inner_interp:
semi:	.word   . + 5
	ldr     IR, [RSP]
	adds    RSP, #4
	


next:   ldr     WA, [IR]
	adds    IR, #4
	

run:	ldr     CA, [WA]
	adds    WA, #4
	bx      CA


do_colon:
	str     IR, [RSP]
	mov     IR, WA
	b       next