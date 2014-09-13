/* Simple UART module.
 * External baud rate
 * No parity
 * One stop bit
 */

#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "SimpleUART.h"

//Initialize UART
void InitModUart(struct r_uart &uart) {
	uart.RXD :> void;
	uart.TXD :> void;
	uart.BAUDRATE;
	uart.BIT_TIME = XS1_TIMER_HZ/ uart.BAUDRATE;
}

//UART: Receive byte
unsigned char uart_rxByte(struct r_uart &uart){

	unsigned data = 0, time;
	int i;
	unsigned char c;
	// wait for start bit
	//TODO: Add Select to track disconnection
	uart.RXD when pinseq (1):>void;
	uart.RXD when pinseq (0) :> int _ @ time;
	time += uart.BIT_TIME + (uart.BIT_TIME >> 1);

	// sample each bit in the middle.
	for (i = 0; i < 8; i += 1){
		uart.RXD @ time :> >> data;
		time += uart.BIT_TIME;
	}

	// reshuffle the data.
	c = (unsigned char) (data >> 24);
	return {c};
}

//UART:Send byte
void uart_txByte(unsigned char c,struct r_uart &uart){
	unsigned time, data;

	data = c;

	// get current time from port with force out.
	uart.TXD <: 1 @ time;

	// Start bit.
	time += uart.BIT_TIME;
	uart.TXD @time <: 0;

	// Data bits.
	for (int i = 0; i < 8; i += 1){
		time += uart.BIT_TIME;
		uart.TXD @ time <: >>data;
	}

	// one stop bit
	time += uart.BIT_TIME;
	uart.TXD @ time <: 1;
}

