/*
 * SimpleUART.h
 *
 *  Created on: Jun 14, 2013
 *      Author: dimitris
 */

#ifndef SIMPLEUART_H_
#define SIMPLEUART_H_

#include <xs1.h>
#include <xccompat.h>

typedef struct r_uart {
    port RXD;
    port TXD;
    int BAUDRATE;
    int BIT_TIME;
}  r_uart;

void InitModUart(REFERENCE_PARAM(struct r_uart,uart));
void uart_txByte(unsigned char c,struct r_uart &uart);
unsigned char uart_rxByte(struct r_uart &uart);

#endif /* SIMPLEUART_H_ */
