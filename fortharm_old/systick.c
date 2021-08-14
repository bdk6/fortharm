//////////////////////////////////////////////////////////////////////////////
///
///  @file systick.c
///
///  Setup and handle systick timer and interrupt
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stddef.h>   // for NULL
#include "LPC11xx.h"
#include "system_LPC11xx.h"
#include "systick.h"



static volatile uint32_t ticks = 0;
static uint32_t ms_per_irq = 0;
static volatile uint32_t milliseconds = 0;
static volatile uint32_t milliseconds_high = 0;

static volatile systick_timer_t *Timers;
static uint8_t Num_timers;

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_init
///
///  @brief Initialize the systick timer and turn on interrupt
///
//////////////////////////////////////////////////////////////////////////////

void systick_init(uint32_t irq_freq, systick_timer_t *tim, uint8_t number)
{
   uint32_t index;
   uint32_t timer_val = SystemCoreClock / (irq_freq);
   //uint32_t timer_val = 48000000 / (irq_freq);
   Num_timers = number;
   Timers = tim;

   SYSTICK->RVR = timer_val-1;  // set reload value
   SYSTICK->CVR = 0;            // clear the timer
   
   ms_per_irq = 1000/irq_freq;
   for (index=0; index < Num_timers; ++index)
   {
      Timers[index].timeout = 0;
      Timers[index].timer = 0;
      Timers[index].callback = NULL;
   }


   SYSTICK->CSR = 0x7;  // Enable counter and IRQ and clock /1
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_get_ticks
///
///  @brief gets value of tick counter
///
///  @return The number of timer ticks since startup
///
//////////////////////////////////////////////////////////////////////////////
uint32_t systick_get_ticks(void)
{
   return ticks;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_get_milliseconds
///
///  @brief gets value of milliseconds
///
///  @return number of milliseconds since startup
///
//////////////////////////////////////////////////////////////////////////////
uint32_t systick_get_milliseconds(void)
{
   return milliseconds;
}

uint64_t systick_get_milliseconds_long(void)
{
   uint64_t ms;
   // stop interrupts
   NVIC_DisableIRQ(-1);
   ms = (uint64_t)milliseconds + ((uint64_t)milliseconds_high << 32);
   NVIC_EnableIRQ(-1);
   return ms;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_set_timer
///
///  @brief sets a timer for further use
///  
///  @param[in] index   timer number 0 to n-1
///  @param[in] ms      number of milliseconds to run
///  @param[in] repeat  one shot or repeating
///
//////////////////////////////////////////////////////////////////////////////
void systick_set_timer(uint32_t index, int32_t ms, uint8_t repeat)
{
   if (index < Num_timers)
   {
      Timers[index].timer = ms;
      if (repeat != 0)
      {
	 Timers[index].timeout = ms;
      }
      else
      {
	 Timers[index].timeout = 0;
      }
   }
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_get_timer
///  
///  @brief returns remaining time of the timer
/// 
///  @param index  timer number 0 to n-1
///  @return   Number of milliseconds remaining on timer
///
//////////////////////////////////////////////////////////////////////////////
int32_t systick_get_timer(uint32_t index)
{
   uint32_t rtn = 0;
   if (index < Num_timers)
   {
      rtn = Timers[index].timer;
   }
   return rtn;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b systick_set_callback
///
///  @brief sets callback of timer
///
///  @param[in]  index   timer number to set 0 to n-1
///  @param[in   callback  pointer to callback function
///
//////////////////////////////////////////////////////////////////////////////
void systick_set_callback(uint32_t index, callback_t callback)
{
// stop interrupts
   if (index < Num_timers)
   {
      Timers[index].callback = callback;
   }
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b Systick_Handler
///
///  @brief Systick Timer interrupt handler
///
/////////////////////////////////////////////////////////////////////////////
void SysTick_Handler(void)
{
   uint32_t index;
   uint32_t old_ms = milliseconds;
   ++ticks;
   milliseconds += ms_per_irq;

   if (milliseconds < old_ms)
   {
      ++milliseconds_high;
   }
   for (index = 0; index < Num_timers; ++index)
   {
      if (Timers[index].timer > 0)
      {
	 Timers[index].timer -= ms_per_irq;
	 if (Timers[index].timer <= 0)
	 {
	    Timers[index].timer = 0;
	 }
      }
   }
   for (index = 0; index < Num_timers; ++ index)
   {
      if (Timers[index].timer == 0 && Timers[index].callback != NULL)
      {
	 Timers[index].callback();
      }
      if (Timers[index].timer == 0)
      {
         Timers[index].timer = Timers[index].timeout;
      }
   }

   //  GPIO0->DATA ^= 4;
}
