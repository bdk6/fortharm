//////////////////////////////////////////////////////////////////////////////
///
///  @file timers.c
///  
///  @brief (C) 2013 William R Cooke
///  Timer control routines for LPC11xx
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "LPC11xx.h"
#include "system_LPC11xx.h"
#include "timers.h"


//////////////////////////////////////////////////////////////////////////////
///
///  \b pwm_init
///
///  @brief set up pwm on a timer
///
///  @param[in]  timer         pointer to the timer to use
///  @param[in]  prescale      prescaler division 
///  @param[in]  cycle_length  number of clocks for entire cycle
///  @param[in]  channels      which channels to pwm
///  @param[in]
///
///  @remark     uses match3 for cycle length. sets all channels to max count
//////////////////////////////////////////////////////////////////////////////
void pwm_init(ctxxb_t *timer, uint32_t prescale, uint32_t cycle_length,  uint32_t channels)
{
// match 3 is pulse width

   uint32_t emr_value = 0;

   if (timer == CT16B0)
   {
      if ((channels & TIMER_CHANNEL_0) != 0) IOCON->IOCON_PIO0_8 = PINFN_CT16B0_MAT0;
      if ((channels & TIMER_CHANNEL_1) != 0) IOCON->IOCON_PIO0_9 = PINFN_CT16B0_MAT1;
      if ((channels & TIMER_CHANNEL_2) != 0) IOCON->IOCON_SWCLK_PIO0_10 = PINFN_CT16B0_MAT2;
      SYSCON->SYSAHBCLKCTRL |= (AHBCLKCTRL_CT16B0); // turn on timer

   }
   else if (timer == CT16B1)
   {
      if ((channels & TIMER_CHANNEL_0) != 0) IOCON->IOCON_PIO1_9  = PINFN_CT16B1_MAT0;
      if ((channels & TIMER_CHANNEL_1) != 0) IOCON->IOCON_PIO1_10  = PINFN_CT16B1_MAT1;
      SYSCON->SYSAHBCLKCTRL |= (AHBCLKCTRL_CT16B1); // turn on timer

   }
   else if (timer == CT32B0)
   {
      if ((channels & TIMER_CHANNEL_0) != 0) IOCON->IOCON_PIO1_6 = PINFN_CT32B0_MAT0;
      if ((channels & TIMER_CHANNEL_1) != 0) IOCON->IOCON_PIO1_7 = PINFN_CT32B0_MAT1;
      SYSCON->SYSAHBCLKCTRL |= (AHBCLKCTRL_CT32B0); // turn on timer

   }
   else if (timer == CT32B1)
   {
      if ((channels & TIMER_CHANNEL_0) != 0) IOCON->IOCON_R_PIO1_1 = PINFN_CT32B1_MAT0;
      if ((channels & TIMER_CHANNEL_1) != 0) IOCON->IOCON_R_PIO1_2 = PINFN_CT32B1_MAT1;
      if ((channels & TIMER_CHANNEL_2) != 0) IOCON->IOCON_SWDIO_PIO1_3 = PINFN_CT32B1_MAT2;
      SYSCON->SYSAHBCLKCTRL |= (AHBCLKCTRL_CT32B1); // turn on timer
   }


   timer->PR = prescale-1;             // set reg to prescale value
   timer->MR3 = cycle_length - 1;      // number of clocks for complete cycle
   timer->PWMC = channels & 0x07;;     // turn on pwm channels
   timer->MCR = (1<<10);               // reset on match 3

   if ((channels & TIMER_CHANNEL_0) != 0)
   {
      emr_value |= (2<<4);             // set output on match
      timer->MR0 = 0xffffffff;         // start with no outputs
   }
   if ((channels & TIMER_CHANNEL_1) != 0)
   {
      emr_value |= (2<<6);
      timer->MR1 = 0xffffffff;
   }
   if ((channels & TIMER_CHANNEL_2) != 0)
   {
      emr_value |= (2<<8);
      timer->MR2 = 0xffffffff;
   }
   timer->EMR = emr_value; // set outputs on match
   timer->TCR = 1;
}

//////////////////////////////////////////////////////////////////////////////
///
/// \b pwm_set
///
///  @brief sets a pwm channel pulse width
///
///  @param[in]  timer   which timer to use
///  @param[in]  channel which channel to set
///  @param[in]  width   output pulse width (high)
///
///  @remark     pulse high time is at end of cycle
///
//////////////////////////////////////////////////////////////////////////////
void pwm_set(ctxxb_t *timer, uint32_t channel, uint32_t width)
{
   uint32_t value = timer->MR3 - width;
   if (timer == CT16B1 | timer == CT16B0)
   {
      value &= 0xffff;
   }
   if (width != 0xffffffff)
   {
      //timer->MR3 = width - 1;
   }
   switch (channel)
   {
   case TIMER_CHANNEL_0:
      timer->MR0 = value;
      break;
   case TIMER_CHANNEL_1:
      timer->MR1 = value;
      break;
   case TIMER_CHANNEL_2:
      timer->MR2 = value;
      break;
   default:
      break;
   }
}


//////////////////////////////////////////////////////////////////////////////
///
///  \b capture_init
///
///  @param[in]  timer  which timer to use
///  @param[in]  edge   which edge to capture
///
///  @remark    Timer needs to already be set up.  Only the capture is set up
///             here.
///
//////////////////////////////////////////////////////////////////////////////
void capture_init(ctxxb_t *timer, uint32_t edge)
{
   if (timer == CT16B0)
   {
      IOCON->IOCON_PIO0_2 = PINFN_CT16B0_CAP0;
   }
   else if (timer == CT16B1)
   {
      IOCON->IOCON_PIO1_8 = PINFN_CT16B1_CAP0;
   }
   else if (timer == CT32B0)
   {
      IOCON->IOCON_PIO1_5 = PINFN_CT32B0_CAP0;
   }
   else if (timer == CT32B1)
   {
      IOCON->IOCON_R_PIO1_0 = PINFN_CT32B1_CAP0;
   }
   

   timer->CCR = edge & 0x7; // choose edges and interrupt
   if (edge & TIMER_CAPTURE_IRQ_ENABLE != 0)
   {
      NVIC_EnableIRQ(17);
   }
}


//////////////////////////////////////////////////////////////////////////////
///
///  \b get_capture
///
///  @param[in]  timer  which timer to get
///
///  @remark  returns latest capture value of timer
///
//////////////////////////////////////////////////////////////////////////////
uint32_t get_capture( ctxxb_t *timer)
{
}

