/** \file main.c
 * \brief Sample LPC1114 project
 * \details This file holds a very basic code for LPC1114. This code configures
 * flash access time, enables the PLL and all required clocks and peripherals
 * to achieve the highest allowed frequency for LPC1114 (50MHz). Main code
 * block just blinks the LED. The LED port and pin are defined in config.h
 * file. Target core frequency and quartz crystal resonator frequency are
 * defined there as well.
 *
 * \author Freddie Chopin, http://www.freddiechopin.info/
 * \date 2012-01-08
 */

/******************************************************************************
* project: lpc1114_blink_led
* chip: LPC1114
* compiler: arm-none-eabi-gcc (Sourcery CodeBench Lite 2011.09-69) 4.6.1
*
* prefix: (none)
*
* available global functions:
* 	int main(void)
*
* available local functions:
* 	static void flash_access_time(uint32_t frequency)
* 	static uint32_t pll_start(uint32_t crystal, uint32_t frequency)
* 	static void system_init(void)
*
* available interrupt handlers:
******************************************************************************/

/*
+=============================================================================+
| includes
+=============================================================================+
*/

#include <stdint.h>

#include "LPC11xx.h"
#include "system_LPC11xx.h"
#include "systick.h"
#include "uart.h"
#include "timers.h"

#include <stdio.h>
#include "nonstdio.h"

extern uint32_t forth(uint32_t x);

void my_pwm_init(void);


systick_timer_t  my_timers[4];

char msg[32] = "   Hello World! \n";
uint8_t rx_buf[32];

void systick_wait(uint32_t ms)
{
   systick_set_timer(0, ms, 0);
   while (systick_get_timer(0) != 0);
}

void blinky(void)
{
   GPIO0->DATA ^= 4;
}


static volatile uint32_t distance_mm = 0;
void TIMER16_1_IRQHandler(void)
{
   static uint32_t capture_rising = 0;
   static uint32_t capture_falling = 0;
   static uint8_t is_falling = 0;
   uint32_t what_int = CT16B1->IR;
   uint32_t capt;
   capt = CT16B1->CR0;
   if (is_falling == 1)
   {
      capture_falling = capt;
      is_falling = 0;
      CT16B1->CCR = TIMER_CAPTURE_RISING_EDGE|TIMER_CAPTURE_IRQ_ENABLE;
      distance_mm = (capture_falling - capture_rising) * 176 >> 10;
   }
   else
   {
      capture_rising = capt;
      is_falling = 1;
      CT16B1->CCR = TIMER_CAPTURE_FALLING_EDGE | TIMER_CAPTURE_IRQ_ENABLE;
   }
   CT16B1->IR = what_int;

}




void main(void)
{
   uint32_t count = 0;
   uint32_t count_max = 1000000;
   int16_t ch ;
   uint32_t ch_index = 0;
   uint32_t new_freq = 0;
   Flash_Set_Access_Clocks(48000000);
   new_freq = PLL_Set_Registers(3,1, SYSPLLCLK_IRC, 12000000);  // set to 48 MHz
   if(new_freq != 0) MAINCLK_Set_Source(MAINCLKSEL_PLLOUT);
   uint32_t mpr = new_freq / 12000000;
   //uint32_t cpu_freq = System_Core_Clock;

// wait a bit
    for (count = 0; count < 10000000; ++count);


   AHBCLKCTRL_enable(AHBCLKCTRL_IOCON);  // turn on io configure clock
   GPIO0->DIR =0xffffffff;
   GPIO1->DIR = 0xffffffff;

   systick_init(100,my_timers,4);
   IOCON->IOCON_RESET_PIO0_0 = PINFN_PIO0_0;   // set reset pin as gpio
   pwm_init(CT32B1, 1, 1024, TIMER_CHANNEL_0 | TIMER_CHANNEL_1 | TIMER_CHANNEL_2);
   pwm_init(CT16B1, 48, 65536, TIMER_CHANNEL_0);   // ultrasonic
   pwm_set(CT16B1,TIMER_CHANNEL_0, 10);            // 10 uS pulse to start ranging
   capture_init(CT16B1,  TIMER_CAPTURE_RISING_EDGE | TIMER_CAPTURE_IRQ_ENABLE);

   serial_init_irq(9600,0,8,1,rx_buf,32);

   print_string("F=");
   print_uint(SystemCoreClock);
   print_newline();
   systick_wait(5000);

   print_uint(forth(5));
   systick_wait(1000);

   systick_set_timer(1,500,1);
   systick_set_callback(1,blinky);
   while (1)
   {

      print_uint(distance_mm);
      print_newline();

   }



   while(1)
   {
   
      for(count = 0; count < count_max; ++count);

      uint32_t pos = 0;
      for(pos=1500; pos <2000; ++pos)
      {
        
        
         for(count = 0; count < 100000; ++count);

	 ++ch_index;
	 if (msg[ch_index] == 0)
	 {
	    ch_index = 0;
	 }


	 while ((ch = serial_receive_irq()) != 0)
	 {
	    if (ch == 'p')
	    {
	       puts(" world!\n");
	    }

	    if (ch > 0)
	    {
	       putchar(ch);
	    }
	 }

	 //getchar();
	 //putchar('P');
	 //putc('F',1);
	 //write(1,msg, 3);

      }
   
      for(count = 0; count < count_max; ++count);


   }

}






void sound_set(uint32_t sample)
{
   if (sample < 1024)
   {
      sample = 1024 - sample;
   }
   CT32B1->MR2 = sample;

}


