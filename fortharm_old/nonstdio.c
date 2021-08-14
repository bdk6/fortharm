//////////////////////////////////////////////////////////////////////////////
///
///  @file nonstdio.c
///
///  copyright (c) 2013 William R Cooke
///
//////////////////////////////////////////////////////////////////////////////
#include <stdint.h>
#include "nonstdio.h"

#define buff_size 32

static uint8_t buff[buff_size];
static const uint8_t hex_chars[] = "0123456789ABCDEF";

void print_uint(uint32_t num)
{
   uint8_t *next = &(buff[buff_size-1]);
   *next = 0;
   do
   {
      --next;
      *next = hex_chars[num % 10];
      num /= 10;
   } while (num != 0);
   print_string(next);
}

void print_int(int32_t num)
{
   if (num < 0)
   {
      print_char('-');
      num = -num;
   }
   print_uint(num);
}

void print_char(uint8_t ch)
{
   serial_send(ch);
}

void print_string(uint8_t *str)
{
   uint8_t ch;
   while ((ch=*str) != 0)
   {
      serial_send(ch);
      str++;
   }
}

void print_hex(uint32_t num)
{
   uint32_t cnt;
   for (cnt = 0; cnt < 8; ++cnt)
   {
      buff[buff_size - 2 - cnt] = hex_chars[num & 0xf];
      num >>= 4;
   }
   buff[buff_size - 1] = 0;
   print_string (&(buff[buff_size - 2 - 7]));
}

void print_newline(void)
{
   serial_send(13);
   serial_send(10);
}

uint8_t read_char()
{
   return serial_receive();
}

int32_t read_line(uint8_t *str, uint32_t len)
{
   return 0;
}

int32_t read_string(uint8_t *str, uint32_t len)
{
   return 0;
}

void unread_char(uint8_t ch)
{
}

void set_io_functions(void)
{
}

