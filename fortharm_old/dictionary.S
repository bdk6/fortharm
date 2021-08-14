
#include "defines.h"

        

/* core wordset from dpans 94 ch 6  133 words
*/	
	.text

	.globl store
__w_store:                                      @ ( x a-addr -- )            
	.byte 1
	.ascii "!  "
        .balign 4
	.word 0
__c_store:
        .word .+5
	pop     {r0}
	str     r0, [TOS]
	pop     {TOS}
	b       next
	

	.globl __w_number_sign
__w_number_sign:                                @ ( ud1 -- ud2 ) 
	.byte 1
	.ascii "#"
        .balign 4
	.word __w_store
__c_number_sign:
        .word .+5

        b       next

	.globl __w_number_sign_greater
__w_number_sign_greater:                        @ ( xd -- c-addr u )
	.byte 2
	.ascii  "#>"
        .balign 4
	.word   __w_number_sign
__c_number_sign_greater:        
	.word   .+5

        b       next

        
	.globl  __w_number_sign_s
__w_number_sign_s:                              @ ( ud1 -- ud2)
        .byte   2
        .ascii  "#s"
        .balign 4
        .word   __w_number_sign_greater
__c_number_sign_s:      
        .word   .+5

        b       next

        
	.globl  __w_tick
__w_tick:                                       @ ( "<spaces>name" -- xt )
        .byte   1
        .ascii  "'"
        .balign 4
        .word   __w_number_sign_s
__c_tick:       
        .word   .+5

        b       next

        
	.globl __w_paren
__w_paren:                                      @ ( "ccc<paren>" -- )
        .byte   1+IMM
        .ascii  "("
        .balign 4
        .word   __w_tick
__c_paren:
        .word .+5

        b       next
        

	.globl __w_star
__w_star:                                       @ ( n1|u1 n2|u2 -- n3|u3 )
        .byte   1
        .ascii  "*"
        .balign 4
        .word __w_paren
__c_star:
        .word .+5
        pop     {r0}
        mul     TOS, r0, TOS
        b       next

        
	.globl __w_star_slash
__w_star_slash:                                 @ ( n1 n2 n3 -- n4 )
        .byte   2
        .ascii  "*/"
        .balign 4
        .word   __w_star
__c_star_slash:
        .word   .+5
        

	.globl __w_star_slash_mod
__w_star_slash_mod:                             @ ( n1 n2 n3 -- n4 )
        .byte   5
        .ascii  "*/MOD"
        .balign 4
        .word   __w_star_slash
__c_star_slash_mod:
        .word .+5

        b next
        

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
        b       next

        
	.globl __w_plus_store
__w_plus_store:                                 @ ( n|u a-addr -- )
        .byte   2
        .ascii  "+!"
        .balign 4
        .word   __w_plus
__c_plus_store:
        .word .+5
        pop     {r0}
        str     r0, [TOS]
        pop     {TOS}
        b       next
        

	.globl __w_plus_loop
__w_plus_loop:                                  @ ( C: do-sys -- )
        .byte   5
        .ascii  "+LOOP"
        .balign 4
        .word   __w_plus_store
__c_plus_loop:
        .word   .+5

        b       next
        

	.globl __w_comma
__w_comma:                                      @ ( x -- )
        .byte   1
        .ascii  ","
        .balign 4
        .word   __w_plus_loop
__c_comma:
        .word   .+5

        b       next

	.globl __w_minus
__w_minus:                                      @ ( n1|u1 n2|u2 -- n3|u3 )
        .byte   1
        .ascii  "-"
        .balign 4
        .word   __w_comma
__c_minus:
        .word   . + 5
        pop     {r0}
        sub     TOS, r0, TOS
        b       next
        

	.globl __w_dot
__w_dot:                                        @ ( n -- )
        .byte 1
        .ascii  "."
        .balign 4
        .word __w_minus
__c_dot:
        .word   .+5

        b next

        
	.globl __w_dot_quote
__w_dot_quote:                                  // ( "ccc<quote>" -- )
        .byte   2
        .ascii  ".\""
        .balign 4
        .word   __w_dot
__c_dot_quote:
        .word   .+5

        b       next
        

	.globl __w_slash
__w_slash:                                      @ ( n1 n2 -- n3 )
        .byte   1
        .ascii  "/"
        .balign 4
        .word __w_dot_quote
__c_slash:
        .word   .+5

        b       next
        

	.globl __w_slash_mod
__w_slash_mod:                                  @ ( n1 n2 -- n3 n4 )
        .byte   4
        .ascii  "/MOD"
        .balign 4
        .word   __w_slash
__c_slash_mod:
        .word   .+5

        b       next
        

	.globl __w_zero_less
__w_zero_less:                                  @ ( n -- flag )
        .byte   2
        .ascii  "0<"
        .balign 4
        .word   __w_slash_mod
__c_zero_mod:
        .word   .+5

        b       next
        

__w_zero_equals:                                @ ( n -- flag )
        .byte   2
        .ascii  "0="
        .balign 4
        .word   __w_zero_equals
__c_zero_equals:
        .word   .+5

        b       next

__w_one_plus:                                   @ ( n1|u1 -- n2|u2 )
        .byte   2
        .ascii  "1+"
        .balign 4
        .word   __w_zero_equals
__c_one_plus:
        .word   .+5
        add     TOS, #1
        b       next
        

__w_one_minus:                                  @ ( n1|u1 -- n2|u2 )
        .byte   2
        .ascii  "1-"
        .balign 4
        .word   __w_one_plus
__c_one_minus:
        .word   .+5
        sub     TOS, #1
        b       next

        
__w_two_store:                                  @ ( x1 x2 a-addr -- )
        .byte   2
        .ascii  "2!"
        .balign 4
        .word   __w_one_minus
__c_two_store:
        .word   .+5

        b       next
        

__w_two_star:                                   @ ( x1 -- x2 )
        .byte   2
        .ascii  "2*"
        .balign 4
        .word   __w_two_store
__c_two_star:
        .word   .+5

        b       next
        

__w_two_slash:                                  @ ( x1 -- x2 )
        .byte   2
        .ascii  "2/"
        .balign 4
        .word   __w_two_star
__c_two_slash:
        .word   .+5
        b       next
        

__w_two_fetch:                                  @ ( a-addr -- x1 x2 )
        .byte   2
        .ascii  "2@"
        .balign 4
        .word   __w_two_slash
__c_two_fetch:
        .word   .+5
        b       next
        

__w_two_drop:                                   @ ( x1 x2 -- )
        .byte   5
        .ascii  "2DROP"
        .balign 4
        .word   __w_two_fetch
__c_two_drop:
        .word   .+5
        b       next
        

__w_two_dupe:                                   @ ( x1 x2 -- x1 x2 x1 x2 )
        .byte   4
        .ascii  "2DUP"
        .balign 4
        .word   __w_two_drop
__c_two_dupe:
        .word   .+5
        b       next
        

__w_two_over:                                   @ ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 )
        .byte   5
        .ascii  "2OVER"
        .balign 4
        .word   __w_two_dupe
__c_two_over:
        .word   .+5
        b       next

	
__w_two_swap:                                   @ ( x1 x2 x3 x4 -- x3 x4 x1 x2 )
        .byte   5
        .ascii  "2SWAP"
        .balign 4
        .word   __w_two_over
__c_two_swap:
        .word   .+5
        b       next
        

__w_colon:                                      @ ( C: "<spaces>name" -- colon-sys )
        .byte   1
        .ascii  ":"
        .balign 4
        .word   __w_two_swap
__c_colon:
        .word   .+5
        b       next
        

__w_semicolon:                                  @ ( C: colon-sys -- )
        .byte   1
        .ascii  ";"
        .balign 4
        .word   __w_colon
__c_semicolon:
        .word   .+5
        b       next
        

__w_less_than:                                  @ ( n1 n2 -- flag )
        .byte   1
        .ascii  "<"
        .balign 4
        .word   __w_semicolon
__c_less_than:
        .word   .+5
        b       next
        

__w_less_number_sign:                           @ ( -- )
        .byte   2
        .ascii  "<#"
        .balign 4
        .word   __w_less_than
__c_less_number_sign:
        .word   .+5
        b       next
        

__w_equals:                                     @ ( x1 x2 -- flag )
        .byte   1
        .ascii  "="
        .balign 4
        .word   __w_less_number_sign
__c_equals:
        .word   .+5
        b       next
        

__w_greater_than:                               @ ( n1 n2 -- flag )
        .byte   1
        .ascii  ">"
        .balign 4
        .word   __w_equals
__c_greater_than:
        .word   .+5
        b       next
        

__w_to_body:                                    @ ( xt -- a-addr )
        .byte   5
        .ascii  ">BODY"
        .balign 4
        .word   __w_greater_than
__c_to_body:
        .word   .+5
        b       next
        

__w_to_in:                                      @ ( -- a-addr )
        .byte   3
        .ascii  ">IN"
        .balign 4
        .word   __w_to_body
__c_to_in:
        .word   .+5
        b       next
        

__w_to_number:                                  @ ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 )
        .byte   7
        .ascii  ">NUMBER"
        .balign 4
        .word   __w_to_in
__c_to_number:
        .word   .+5
        b       next
        

__w_to_r:                                       @ (x -- ) ( R: -- x )
        .byte   2
        .ascii  ">R"
        .balign 4
        .word   __w_to_number
__c_to_r:
        .word   .+5
        b       next
        

__w_question_dupe:                              @ ( x -- 0 | x x )
        .byte   4
        .ascii  "?DUP"
        .balign 4
        .word   __w_to_r
__c_question_dupe:
        .word   .+5
        b       next
        

__w_fetch:                                      @ ( a-addr -- x )
        .byte   1
        .ascii  "@"
        .balign 4
        .word   __w_question_dupe
__c_fetch:
        .word   .+5
        b       next
        

__w_abort:                                      @ ( i*x -- ) ( R: j*x -- )
        .byte   5
        .ascii  "ABORT"
        .balign 4
        .word   __w_fetch
__c_abort:
        .word   .+5
        b       next
        

__w_abort_quote:                                @ ( "ccc<quote>" -- )
        .byte   6
        .ascii  "ABORT\""
        .balign 4
        .word   __w_abort
__c_abort_quote:
        .word   .+5
        b       next
        

__w_abs:                                        @ ( n -- u )
        .byte   3
        .ascii  "ABS"
        .balign 4
        .word   __w_abort_quote
__c_abs:
        .word   .+5
        b       next
        

__w_accept:                                     @ ( c-addr +n1 -- +n2 )
        .byte   6
        .ascii  "ACCEPT"
        .balign 4
        .word   __w_abs
__c_accept:
        .word   .+5
        b       next
        

__w_align:                                      @ ( -- )
        .byte   5
        .ascii  "ALIGN"
        .balign 4
        .word   __w_accept
__c_align:
        .word   .+5
        b       next
        

__w_aligned:                                    @ ( addr -- a-addr )
        .byte   7
        .ascii  "ALIGNED"
        .balign 4
        .word   __w_align
__c_aligned:
        .word   .+5
        b       next
        

__w_allot:                                      @ ( n -- )
        .byte   5
        .ascii  "ALLOT"
        .balign 4
        .word   __w_aligned
__c_allot:
        .word   .+5
        b       next
        

__w_and:                                        @ ( x1 x2 -- x3 )
        .byte   3
        .ascii  "AND"
        .balign 4
        .word   __w_allot
__c_and:
        .word   .+5
        b       next
        

__w_base:                                       @ ( -- a-addr )
        .byte   4
        .ascii  "BASE"
        .balign 4
        .word   __w_and
__c_base:
        .word   .+5
        b       next
        

__w_begin:                                      @ ( C: -- dest )
        .byte   5
        .ascii  "BEGIN"
        .balign 4
        .word   __w_base
__c_begin:
        .word   .+5
        b       next
        

__w_bl:                                         @ ( -- char )
        .byte   2
        .ascii  "BL"
        .balign 4
        .word   __w_begin
__c_bl:
        .word   .+5
        b       next
        

__w_c_store:                                    @ ( char c-addr -- )
        .byte   2
        .ascii  "C!"
        .balign 4
        .word   __w_bl
__c_c_store:
        .word   .+5
        b       next
        

__w_c_comma:                                    @ ( char -- )
        .byte   2
        .ascii  "C,"
        .balign 4
        .word   __w_c_store
__c_c_comma:
        .word   .+5
        b       next
        

__w_c_fetch:                                    @ ( c-addr -- char )
        .byte   2
        .ascii  "C@"
        .balign 4
        .word   __w_c_comma
__c_c_fetch:
        .word   .+5
        b       next
        

__w_cell_plus:                                  @ ( a-addr1 -- a-addr2 )
        .byte   5
        .ascii  "CELL+"
        .balign 4
        .word   __w_c_fetch
__c_cell_plus:
        .word   .+5
        b       next
        

__w_cells:                                      @ ( n1 -- n2 )
        .byte   5
        .ascii  "CELLS"
        .balign 4
        .word   __w_cell_plus
__c_cells:
        .word   .+5
        lsl     TOS, #2
        b       next
        

__w_char:                                       @ ( "<spaces>name" -- char )
        .byte   4
        .ascii  "CHAR"
        .balign 4
        .word   __w_cells
__c_char:
        .word   .+5
        b       next
        

__w_char_plus:                                  // ( c-addr1 -- c-addr2 )
        .byte   5
        .ascii  "CHAR+"
        .balign 4
        .word   __w_char
__c_char_plus:
        .word   .+5
        b       next

__w_chars:                                      // ( n1 -- n2 )
        .byte   5
        .ascii  "CHARS"
        .balign 4
        .word   __w_char_plus
__c_chars:
        .word   .+5
        b       next
        

__w_constant:                                   // ( x "<spaces>name" -- )
        .byte   8
        .ascii  "CONSTANT"
        .balign 4
        .word   __w_chars
__c_constant:
        .word   .+5
        b       next
        

__w_count:                                      // ( c-addr1 -- c-addr2 u )
        .byte   5
        .ascii  "COUNT"
        .balign 4
        .word   __w_constant
__c_count:
        .word   .+5
        b       next
        

__w_cr:                                         // ( -- )
        .byte   2
        .ascii  "CR"
        .balign 4
        .word   __w_count
__c_cr:
        .word   .+5
        b       next
        

__w_create:                                     // ( "<spaces>name" -- )
        .byte   6
        .ascii  "CREATE"
        .balign 4
        .word   __w_cr
__c_create:
        .word   .+5
        b       next
        

__w_decimal:                                    // ( -- )
        .byte   7
        .ascii  "DECIMAL"
        .balign 4
        .word   __w_create
__c_decimal:
        .word   .+5
        b       next
        

__w_depth:                                      // ( -- +n )
        .byte   5
        .ascii  "DEPTH"
        .balign 4
        .word   __w_decimal
__c_depth:
        .word   .+5
        b       next
        

__w_do:                                         // ( C: -- do-sys )  ( n1|u1 n2|u2 -- ) ( R: -- loop-sys )
        .byte   2
        .ascii  "DO"
        .balign 4
        .word   __w_depth
__c_do:
        .word   .+5
        b       next
        

__w_does:                                       // ( C: colon-sys1 -- colon-sys2 )
        .byte   5
        .ascii  "DOES>"
        .balign 4
        .word   __w_do
__c_does:
        .word   .+5
        b       next
        

__w_drop:                                       // ( x -- )
        .byte   4
        .ascii  "DROP"
        .balign 4
        .word   __w_does
__c_drop:
        .word   .+5
        pop     {TOS}
        b       next
        

__w_dupe:                                       // ( x -- x x )
        .byte   3
        .ascii  "DUP"
        .balign 4
        .word   __w_drop
__c_dupe:
        .word   .+5
        push    {TOS}
        b       next
        

__w_else:                                       // ( C: orig1 -- orig2 )
        .byte   4
        .ascii  "ELSE"
        .balign 4
        .word   __w_dupe
__c_else:
        .word   .+5
        b       next
        

__w_emit:                                       // ( x -- )
        .byte   4
        .ascii  "EMIT"
        .balign 4
        .word   __w_else
__c_emit:
        .word   .+5
        b       next
        

__w_environment_query:                          // ( c-addr u -- false | i*x true )
        .byte 12
        .ascii  "ENVIRONMENT?"
        .balign 4
        .word   __w_emit
__c_environment_query:
        .word   .+5
        b       next
        

__w_evaluate:                                   // ( i*x c-addr u -- j*x )
        .byte   8
        .ascii  "EVALUATE"
        .balign 4
        .word   __w_environment_query
__c_evaluate:
        .word   .+5
        b       next
        

__w_execute:                                    // ( i*x xt -- j*x )
	.byte   7
        .ascii  "EXECUTE"
        .balign 4
        .word   __w_evaluate
__c_execute:
        .word   .+5
        b       next
        
	
__w_exit:                                       // ( -- ) ( R: nest-sys -- )
        .byte   4
        .ascii  "EXIT"
        .balign 4
        .word   __w_execute
__c_exit:
        .word   .+5
        b       next
        

__w_fill:                                       // ( c-addr u char -- )
        .byte   4
        .ascii  "FILL"
        .balign 4
        .word   __w_exit
__c_fill:
        .word   .+5
        b       next
        

__w_find:                                       // ( c-addr -- c-addr 0 | xt 1 | xt -1 )
        .byte   4
        .ascii  "FIND"
        .balign 4
        .word   __w_fill
__c_find:
        .word   .+5
        b       next
        

__w_f_m_slash_mod:                              // ( d1 n1 -- n2 n3 )
        .byte   6
        .ascii  "FM/MOD"
        .balign 4
        .word   __w_find
__c_f_m_slash_mod:
        .word   .+5
        b       next
        

__w_here:                                       // ( -- addr )
        .byte    4
	.ascii   "HERE"
        .balign 4
	.word __w_f_m_slash_mod
__c_here:       
	.word .+5
        b      next
	

__w_hold:                                       @ ( char -- )
        .byte   4
        .ascii  "HOLD"
        .balign 4
        .word   __w_here
__c_hold:
        .word   .+5
        b       next
        

__w_i:                                          // ( -- n|u ) ( R: loop-sys -- loop-sys )
        .byte   1
        .ascii  "I"
        .balign 4
        .word   __w_hold
__c_i:
        .word   .+5
        b       next
        

__w_if:                                         // ( C: -- orig )
        .byte   2
        .ascii  "IF"
        .balign 4
        .word   __w_i
__c_if:
        .word   .+5
        b       next
        

__w_immediate:                                  // ( -- )
        .byte 9
        .ascii  "IMMEDIATE"
        .balign 4
        .word   __w_if
__c_immediate:
        .word   .+5
        b       next
        

__w_invert:                                     // ( x1 -- x2 )
        .byte   6
        .ascii  "INVERT"
        .balign 4
        .word   __w_immediate
__c_invert:
        .word   .+5
        mvn     TOS, TOS
        b       next
        

__w_j:                                          // ( -- n|u ) ( R: loop-sys1 loop-sys2 -- loop-sys1 loop-sys2 )
        .byte   1
        .ascii  "J"
        .balign 4
        .word   __w_invert
__c_j:
        .word   .+5
        b       next
        

__w_key:                                        // ( -- char )
        .byte 3
        .ascii  "KEY"
        .balign 4
        .word   __w_j
__c_key:
        .word   .+5
        b       next
        

__w_leave:                                      // ( -- ) ( R: loop-sys -- )
        .byte 5
        .ascii  "LEAVE"
        .balign 4
        .word   __w_key
__c_leave:
        .word   .+5
        b       next
        

__w_literal:                                    // ( x -- )
        .byte   7
        .ascii  "LITERAL"
        .balign 4
        .word   __w_leave
__c_literal:
        .word   .+5
        push    {TOS}
        ldr     TOS, [WA]
        add     WA, #2
        b       next

__w_loop:                                       // ( C: do-sys -- )
        .byte   4
        .ascii  "LOOP"
        .balign 4
        .word   __w_literal
__c_loop:
        .word   .+5
        b       next
        

__w_lshift:                                     // ( x1 u -- x2 )	
        .byte   6
        .ascii  "LSHIFT"
        .balign 4
        .word   __w_loop
__c_lshift:
        .word   .+5
        pop     {r0}
        lsl     r0, TOS
        mov     TOS, r0
        b       next
        

__w_m_star:                                     // ( n1 n2 -- d )
        .byte   2
        .ascii  "M*"
        .balign 4
        .word   __w_lshift
__c_m_star:
        .word   .+5
        b       next
        

__w_max:                                        // ( n1 n2 -- n3 )
        .byte   3
        .ascii  "MAX"
        .balign 4
        .word   __w_m_star
__c_max:
        .word   .+5
        b       next
        

__w_min:                                        // ( n1 n2 -- n3 )
        .byte
        .ascii  "MIN"
        .balign 4
        .word   __w_max
__c_min:
        .word   .+5
        b       next
        

__w_mod:                                        // ( n1 n2 -- n3 )
        .byte   3
        .ascii  "MOD"
        .balign 4
        .word   __w_min
__c_mod:
        .word   .+5
        b       next
        

__w_move:                                       // ( addr1 addr2 u -- )
	.byte   4
        .ascii  "MOVE"
        .balign 4
        .word   __w_mod
__c_move:
        .word   .+5
        b       next
        

__w_negate:                                     // ( n1 -- n2 )
	.byte   6
        .ascii  "NEGATE"
        .balign 4
        .word   __w_move
__c_negate:
        .word   .+5
        mvn     TOS, TOS
        add     TOS, #1
        b       next
        

__w_or:	                                        // ( x1 x2 -- x3 )
        .byte   2
        .ascii  "OR"
        .balign 4
        .word   __w_negate
__c_or:
        .word   .+5
        pop     {r0}
        orr      TOS, r0
        b       next
        

__w_over:                                       // ( x1 x2 -- x1 x2 x1 )
	.byte   4
        .ascii  "OVER"
        .balign 4
        .word   __w_or
__c_over:
        .word   .+5
        push    {TOS}
        ldr     TOS, [SP, #4]
        b       next

        
__w_postpone:                                   // ( "<spaces>name" -- )
	.byte   8
        .ascii  "POSTPONE"
        .balign 4
        .word   __w_over
__c_postpone:
        .word   .+5
        b       next
        

__w_quit:                                       // ( -- ) ( R: i*x -- )
	.byte   4
        .ascii  "QUIT"
        .balign 4
        .word   __w_postpone
__c_quit:
        .word   .+5
        b       next
        

__w_r_from:                                     // ( -- x ) ( R: x -- )
	.byte 2
	.ascii "R>"
        .balign 4
        .word   __w_quit
__c_r_from:
        .word   .+5
        b       next
        

__w_r_fetch:                                    // ( -- x ) ( R: x -- x )
	.byte 2
	.ascii "R@"
        .balign 4
        .word   __w_r_from
__c_r_fetch:
        .word   .+5
        b       next
        

__w_recurse:                                    // ( -- )
	.byte   7
        .ascii  "RECURSE"
        .balign 4
        .word   __w_r_fetch
__c_recurse:
        .word   .+5
        b       next
        

__w_repeat:                                     // ( C: orig dest -- ) ( -- )
	.byte   6
        .ascii  "REPEAT"
        .balign 4
        .word   __w_recurse
__c_repeat:
        .word   .+5
        b       next
        

__w_rot:                                        // ( x1 x2 x3 -- x2 x3 x1 )
	.byte   3
        .ascii  "ROT"
        .balign 4
        .word   __w_repeat
__c_rot:
        .word   .+5
        b       next
        

__w_r_shift:                                    // ( x1 u -- x2 )
	.byte   6
        .ascii  "RSHIFT"
        .balign 4
        .word   __w_rot
__c_r_shift:
        .word   .+5
        pop     {r0}
        lsr     TOS, TOS, r0
        b       next
        

__w_s_quote:                                    // ( "ccc<quote>" -- ) ( -- c-addr u )
	.byte   2
        .ascii  "S\""
        .balign 4
        .word   __w_r_shift
__c_s_quote:
        .word   .+5
        b       next
        

__w_s_to_d:                                     // ( n -- d )
	.byte   3
        .ascii  "S>D"
        .balign 4
        .word   __w_s_quote
__c_s_to_d:
        .word   .+5
        b       next
        

__w_sign:                                       // ( n -- )
	.byte   4
        .ascii  "SIGN"
        .balign 4
        .word   __w_s_to_d
__c_sign:
        .word   .+5
        b       next
        

__w_s_m_slash_rem:                              // ( d1 n1 -- n2 n3 )
	.byte   6
        .ascii  "SM/REM"
        .balign 4
        .word   __w_sign
__c_s_m_slash_rem:
        .word   .+5
        b       next
        

__w_source:                                     // ( -- c-addr u )
	.byte   6
        .ascii  "SOURCE"
        .balign 4
        .word   __w_s_m_slash_rem
__c_source:
        .word   .+5
        b       next
        

__w_space:                                      // ( -- )
	.byte   5
        .ascii  "SPACE"
        .balign 4
        .word   __w_source
__c_space:
        .word   .+5
        b       next
        

__w_spaces:                                     // ( n -- )
	.byte   6
        .ascii  "SPACES"
        .balign 4
        .word   __w_space
__c_spaces:
        .word   .+5
        b       next
        

__w_state:                                      // ( -- a-addr )
	.byte   5
        .ascii  "STATE"
        .balign 4
        .word   __w_spaces
__c_state:
        .word   .+5
        push    {TOS}
        ldr     TOS, =sys_state
        b       next
        

__w_swap:                                       // ( x1 x2 -- x2 x1 )
	.byte   4
        .ascii  "SWAP"
        .balign 4
        .word   __w_state
__c_swap:
        .word   .+5
        pop     {r0}
        push    {TOS}
        mov     TOS, r0
        b       next
        

__w_then:                                       // ( C: orig -- ) ( -- )
	.byte   4
        .ascii  "THEN"
        .balign 4
        .word   __w_swap
__c_then:
        .word   .+5
        b       next
        

__w_type:                                       // ( c-addr u -- )
	.byte   4
        .ascii  "TYPE"
        .balign 4
        .word   __w_then
__c_type:
        .word   .+5
        b       next
        

__w_u_dot:                                      // ( u -- )
	.byte   2
        .ascii  "U."
        .balign 4
        .word   __w_type
__c_u_dot:
        .word   .+5
        b       next
        

__w_u_less_than:                                // ( u1 u2 -- flag )
	.byte   2
        .ascii  "U<"
        .balign 4
        .word   __w_u_dot
__c_u_less_than:
        .word   .+5
        b       next
        

__w_u_m_star:                                   // ( u1 u2 -- ud )
	.byte   3
        .ascii  "UM*"
        .balign 4
        .word   __w_u_less_than
__c_u_m_star:
        .word   .+5
        b       next
        

__w_u_m_slash_mod:                              // ( ud u1 -- u2 u3 )
	        .byte   6
        .ascii  "UM/MOD"
        .balign 4
        .word   __w_u_m_star
__c_u_m_slash_mod:
        .word   .+5
        b       next
        

__w_unloop:                                     // ( -- ) ( R: loop-sys )
	.byte   6
        .ascii  "UNLOOP"
        .balign 4
        .word   __w_u_m_slash_mod
__c_unloop:
        .word   .+5
        b       next
        

__w_until:                                      // ( C: dest -- ) ( x -- )
	.byte   5
        .ascii  "UNTIL"
        .balign 4
        .word   __w_unloop
__c_until:
        .word   .+5
        b       next
        

__w_variable:                                   // ( "<spaces>name" -- )
	.byte   8
        .ascii  "VARIABLE"
        .balign 4
        .word   __w_until
__c_variable:
        .word   .+5
        b       next
        

__w_while:                                      // ( C: dest -- orig dest )
	.byte   5
        .ascii  "WHILE"
        .balign 4
        .word   __w_variable
__c_while:
        .word   .+5
        b       next
        

__w_word:                                       // ( char "<chars>ccc<char>" -- c-addr )
	.byte   4
        .ascii  "WORD"
        .balign 4
        .word   __w_while
__c_word:
        .word   .+5
        b       next
        
	
__w_xor:                                        // ( x1 x2 -- x3 )
	.byte   3
        .ascii  "XOR"
        .balign 4
        .word   __w_word
__c_xor:
        .word   .+5
        pop     {r0}
        eor     TOS, r0
        b       next
        

__w_left_bracket:                               // ( -- )
	.byte 1
        .ascii  "["
        .balign 4
        .word   __w_xor
__c_left_bracket:
        .word   .+5
        b       next
        

__w_bracket_tick:                               // ( "<spaces>name" -- )
	.byte   2
        .ascii  "[']"
        .balign 4
        .word   __w_left_bracket
__c_bracket_tick:
        .word   .+4
        b       next
        

__w_bracket_char:                               // ( "<spaces>name" -- )
	.byte   6
        .ascii  "[CHAR]"
        .balign 4
        .word   __w_bracket_tick
__c_bracket_char:
        .word   .+5
        b       next
        

        .globl  __w_right_bracket
        .globl  __c_right_bracket
__w_right_bracket:                              // ( -- )
	.byte   1
        .ascii  "]"
        .balign 4
        .word   __w_bracket_char
__c_right_bracket:
        .word   .+5
        b       next
        


        .balign 4
        
	@ core extension words



	