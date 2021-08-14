
#include "defines.h"


        .text


__w_number_t_i_b:                               // ( -- a-addr )
        .byte   4
        .ascii  "#TIB"
        .balign 4
        .word   __w_right_bracket
__c_number_t_i_b:
        .word   .+5
        b       next


__w_dot_paren:                                  // ( "ccc<paren>" -- )
        .byte   2
        .ascii  ".("
        .balign 4
        .word   __w_number_t_i_b
__c_dot_paren:
        .word   .+5
        b       next


        