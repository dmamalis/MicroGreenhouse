/*
 * Cozir.h
 *
 *  Created on: Jun 28, 2013
 *      Author: dimitris
 */

#ifndef COZIR_H_
#define COZIR_H_

//==INCLUDES====================================================================
#include <platform.h>
#include <xs1.h>
#include <xccompat.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "SimpleUART.h"

//==DEFINES=====================================================================
//Cozir
#define BAUDRATE 9600

//==PROTOTYPES==================================================================
void InitModCOZIR(REFERENCE_PARAM(struct r_uart,COZIR));
void delay(int dtime);
void COZIR_callibrateCO2(struct r_uart &COZIR);
void COZIR_setMode(char mode, struct r_uart &COZIR);
int COZIR_getCO2(struct r_uart &COZIR);
int COZIR_getRH(struct r_uart &COZIR);
int COZIR_getTemp(struct r_uart &COZIR);
int COZIR_getReply(struct r_uart &COZIR);
void COZIR_Cozir(struct r_uart &COZIR);

#endif /* COZIR_H_ */
