
//////////////////////////////////////////////////////////////////////////////
///  
///  \file main.c
///  Copyright 2015 William R Cooke
///
///  \brief Fill in brief descripton here
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "LPC11xx/LPC11xx.h"
#include "LPC11xx/system_LPC11xx.h"
#include "LPC11xx/flash.h"
#include "LPC11xx/systick.h"
#include "LPC11xx/gpio.h"
#include "LPC11xx/uart.h"
#include "LPC11xx/timers.h"
#include "LPC11xx/adc.h"
#include "LPC11xx/clock.h"
#include <stdio.h>

int asm_func(void);
int asm_parm(int x, int y, int z);
void forth(void);

static SysTick_Timer_t systick_timers[4];  // systick timers
static uint8_t uart_buffer[32] = "Hello World I Love You!";
uint32_t dly = 1000000;


void show(int x)
{
  printf("showing %d \n", x);
}

void emit(uint8_t c)
{
  printf("emitting __%c__\n", c);
}

void forth_emit(int c)
{
  putchar(c);
}

void forth_printnum(uint32_t num)
{
  printf("forth number %x \n", num);
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b initialize
///
///  \brief Sets up all peripherals etc
///
//////////////////////////////////////////////////////////////////////////////
void initialize(void)
{
  uint32_t dly = 1000000;
  //while(1);
  //uint32_t dly=100000000;
  GPIO1->DIR = 0xffffffff;
  GPIO1->DATA = 0;
 
    Flash_SetAccessClocks(48000000);  // set flash to use 48 MHz
    PLL_Set48();  // initialize clock to 48 MHz, internal 12 MHz osc
    SysTick_Initialize(100, systick_timers, 4); // interrupt freq, timer array, #timers
    GPIO_Initialize();
    AHBCLKCTRL_Enable(AHBCLKCTRL_IOCON);  // turn on io configure clock
   UART_Initialize(9600, 0, 8, 1, uart_buffer, 32);
   //SysTick_SetTimer(1,500,1);  // blink callback timer
   //  SysTick_Set_Callback(1,blinky);
   printf("CPU Frequency: %d\n", SystemCoreClock);
   // _write(1,uart_buffer,16);
   printf("%d \n", asm_func());
   printf("Calling forth \n");
   forth();
   printf("Returned from forth \n");
   printf("%d \n", asm_parm(2,6,10));

}


/////////////////////////////////////////////////////////////////////////////
///
///  \b main
///
///  \brief Main entry point of charger
///
//////////////////////////////////////////////////////////////////////////////

void main(void)
{
  volatile uint32_t dly;
  uint8_t ch = 100;
  int c;

  
  initialize();
  forth();

  while(1);
}




