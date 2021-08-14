//////////////////////////////////////////////////////////////////////////////
///
///  @file timers.h
///  
///  @brief (C) 2013 William R Cooke
///  Timer control routines for LPC11xx
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "LPC11xx.h"
#include "system_LPC11xx.h"

enum
{
   TIMER_CHANNEL_0         = 1,
   TIMER_CHANNEL_1         = 2,
   TIMER_CHANNEL_2         = 4,
   TIMER_CHANNEL_3         = 8
};
//////////////////////////////////////////////////////////////////////////////
///
///  \b pwm_init
///
///  @brief set up pwm on a timer
///
///  @param[in]  timer   pointer to the timer to use
///  @param[in]  prescale      prescaler division
///  @param[in]  cycle_length  number of clocks for entire cycle
///  @param[in]  channels      which channels to pwm
///  @param[in]
///
///  @remark     uses match3 for cycle length. sets all channels to max count
//////////////////////////////////////////////////////////////////////////////
void pwm_init(ctxxb_t *timer, uint32_t prescale, uint32_t cycle_length,  uint32_t channels);

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
void pwm_set (ctxxb_t *timer, uint32_t channel, uint32_t width);


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
void capture_init(ctxxb_t *timer, uint32_t edge);

//////////////////////////////////////////////////////////////////////////////
///
///  \b get_capture
///
///  @param[in]  timer  which timer to get
///
///  @remark  returns latest capture value of timer
///
//////////////////////////////////////////////////////////////////////////////
uint32_t get_capture( ctxxb_t *timer);
