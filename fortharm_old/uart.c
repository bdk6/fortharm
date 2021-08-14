//////////////////////////////////////////////////////////////////////////////
///
///  @file uart.c
///
///  @brief  uart interface routines for LPC1114
///
//////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include "LPC11xx.h"
#include "uart.h"

static uint8_t Rx_buf_size = 0;
static uint8_t *Rx_buf = (uint8_t *) 0;
//static volatile uint8_t rx_buf[RX_BUF_SIZE];
//static volatile uint8_t tx_buf[TX_BUF_SIZE];
static volatile uint8_t Rx_head = 0;
static volatile uint8_t tx_head = 0;
static volatile uint8_t Rx_tail = 0;
static volatile uint8_t tx_tail = 0; 



//////////////////////////////////////////////////////////////////////////////
///
///  \b serial_init
///
///  @brief Initializes serial comm (UART)
/// 
///  @param[in] bps  bits per second comm speed
///  @param[in] parity  0,1,2: none, odd, even
///  @param[in] bits    how many data bits
///  @param[in] stop    how many stop bits 1,2
///
///  @return none
///
//////////////////////////////////////////////////////////////////////////////
void serial_init(uint32_t bps, uint32_t parity, uint32_t bits, uint32_t stop)
{
   uint32_t lcr = 0;   // value for line control
   uint32_t low = 0;   // divisor low
   uint32_t hi  = 0;   // divisor high

   //  As per user manual, configuration of pins must be done BEFORE
   //  turning on clock
 
   // configure pins
   // PIO1_6   RXD
   // PIO1_7   TXD
   //          /CTS
   //          etc
   IOCON->IOCON_PIO1_6 = (2<<3) | (1<<0);  // RXD and pullup
   IOCON->IOCON_PIO1_7 = (1<<0);           // TXD
   // any others, not used here
   SYSCON->SYSAHBCLKCTRL |= (1<<12);
   SYSCON->UARTCLKDIV = 1;  // Enable clock / 1

   switch(bits)
   {
   case 5:                      // 5 Data bits
      lcr |= UART_LCR_5_BITS;
      break;
   case 6:
      lcr |= UART_LCR_6_BITS;
      break;
   case 7:
      lcr |= UART_LCR_7_BITS;
      break;
   case 8:
      lcr |= UART_LCR_8_BITS;
      break;
   default:
      lcr |= UART_LCR_8_BITS;
   }

   switch (stop)                // 1 or (1.5) 2 stop bits
   {
   case 2:
      lcr |= 1<<1;
      break;
   default:
      break;
   }

   switch (parity)              // parity
   {
   case 0:  // none
      break;
   case 1: // odd
      lcr |= UART_LCR_PARITY_ODD;
      break;
   case 2: // even
      lcr |= UART_LCR_PARITY_EVEN;
      break;
   case 3:  // force 1
      lcr |= UART_LCR_PARITY_1;
      break;
   case 4:  // force 0
      lcr |= UART_LCR_PARITY_0;
      break;
   default:
      break;
   }

   // And enable the divisor latch
   lcr |= 1<<7;
   UART0 -> LCR = lcr;

   // calc divisor
   // The bps * 8 adds 1/2 for rounding
   low = (SystemCoreClock + bps * 8) / (bps * 16);
   low = (48000000 +bps * 8) / (bps * 16);
   hi = low>>8;
   low &= 0xff;
   UART0 -> DATA = low;
   UART0 -> IER = hi;
   UART0 -> LCR &= ~UART_LCR_DLAB;     // clear DLAB bit

   }

void serial_send(uint8_t data)
{
   while ((UART0->LSR & UART_LSR_THRE) == 0);  // wait for room
   UART0 -> DATA = data;
}

int16_t serial_receive(void)
{
   int16_t rtn = -1;
   uint32_t lsr = UART0->LSR;
   // check for character (and errrors)
   if ( (lsr&1) != 0)
   {
      rtn = UART0->DATA;
   }

   return rtn;
}

//////////////////////////////////////////////////////////////////////////////
///
///  \b UART_IRQHandler
///
//////////////////////////////////////////////////////////////////////////////
void UART_IRQHandler(void)
{
// identify interrupt
   uint16_t irq_status = UART0->IIR_FCR;
   uint16_t next_index;
   uint32_t lsr;        // line status register

   if ( (irq_status & (UART_IRQ_RDA | UART_IRQ_CTI)) != 0)
   {
      lsr = UART0->LSR;
      while (lsr & UART_LSR_RDR)        // Is there data?
      {
         next_index = Rx_head +1;
         if (next_index == Rx_buf_size)
         {
            next_index = 0;
         }
         if (next_index != Rx_tail)      // not full
         {
            Rx_buf[Rx_head] = UART0->DATA;
            Rx_head = next_index;
         }
         else
         {
	     // ERROR buffer overflow
         }
	 lsr = UART0->LSR;
      }
   }
   
   if ((irq_status & UART_IRQ_THRE) != 0)
   {
   }

   if ((irq_status & UART_IRQ_RLS) != 0)
   {
   }

   if ((irq_status & UART_IRQ_RLS) != 0)
   {
   }

   if ((irq_status & UART_IRQ_MODEM) != 0)
   {
   }
}
//////////////////////////////////////////////////////////////////////////////
///
///  \b serial_init_irq
///
///  @brief Initializes serial comm (UART) for interrupt
/// 
///  @param[in] bps  bits per second comm speed
///  @param[in] parity  0,1,2: none, odd, even
///  @param[in] bits    how many data bits
///  @param[in] stop    how many stop bits 1,2
///
///  @return none
///
//////////////////////////////////////////////////////////////////////////////
void serial_init_irq(uint32_t bps, uint8_t parity, uint8_t bits, uint8_t stop, uint8_t *buff, uint8_t size)
{
// call non-interrupt serial_init() for most of the work
   serial_init(bps, parity, bits, stop);

// set up the ring buffer
   Rx_buf = buff;
   Rx_buf_size = size;
   Rx_head = 0;
   Rx_tail = 0;

// set up the FIFO
   UART0 -> IIR_FCR = UART_FIFO_EN | UART_FIFO_RX_RESET | UART_FIFO_TX_RESET;

// enable interrupts
   UART0->IER = UART_IRQ_EN_RBRIE | UART_IRQ_EN_THREIE | UART_IRQ_EN_RXLIE; 
   NVIC_EnableIRQ(21);
}

void serial_send_irq(uint8_t data)
{
   while ((UART0->LSR & UART_LSR_THRE) == 0);  // wait for room
   UART0 -> DATA = data;
}

int16_t serial_receive_irq(void)
{
   int16_t rtn = 0;
   uint32_t int_enables;
   // disable interrupts
   int_enables = UART0->IER;
   UART0->IER = 0;  
   NVIC_DisableIRQ(21);

   // get character from buffer
   if (Rx_head != Rx_tail)
   {
      rtn = Rx_buf[Rx_tail];
      ++Rx_tail;
      if (Rx_tail == Rx_buf_size)
      {
	 Rx_tail = 0;
      }
   }

   // restore interrupts
   UART0->IER = int_enables;
   NVIC_EnableIRQ(NVIC_IRQ_UART_0);

   return rtn;
}
