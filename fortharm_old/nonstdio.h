//////////////////////////////////////////////////////////////////////////////
///
///  @file nonstdio.h
///
///  copyright (c) 2013 William R Cooke
///
//////////////////////////////////////////////////////////////////////////////
#include <stdint.h>

void print_uint(uint32_t num);
void print_int(int32_t num);
void print_char(uint8_t ch);
void print_string(uint8_t *str);
void print_hex(uint32_t num);
void print_newline(void);
uint8_t read_char(void);
int32_t read_line(uint8_t *str, uint32_t len);
int32_t read_string(uint8_t *str, uint32_t len);
void unread_char(uint8_t ch);
void set_io_functions(void);
