//////////////////////////////////////////////////////////////////////////////
///
///  @file uart.h
///
///  @brief  uart interface routines for LPC1114
///
//////////////////////////////////////////////////////////////////////////////
#ifndef UART_H
#define UART_H

#include <stdint.h>
#include "LPC11xx.h"

enum
{
   RX_BUF_SIZE    = 32,
   TX_BUF_SIZE    = 32
};

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
///  @param[in] buff    pointer to rx buffer
///  @param[in] size    size of rx buffer in bytes
///
///  @return none
///
//////////////////////////////////////////////////////////////////////////////
void serial_init(uint32_t bps, uint32_t parity, uint32_t bits, uint32_t stop);

void serial_init_irq(uint32_t bps, uint8_t parity, uint8_t bits, uint8_t stop, uint8_t *buff, uint8_t size);

void serial_send(uint8_t data);

void serial_send_irq(uint8_t data);

int16_t serial_receive(void);

int16_t serial_receive_irq(void);

void serial_irq_disable(void);

void serial_irq_enable(void);

#endif
