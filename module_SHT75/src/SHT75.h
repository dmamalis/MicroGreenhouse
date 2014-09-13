/*
 * SHT75.h
 *
 *  Created on: Jun 28, 2013
 *      Author: dimitris
 */

#ifndef SHT75_H_
#define SHT75_H_

#include <xs1.h>
#include <xccompat.h>
#include <math.h>

#define TEMP_REQ 		0x03		//temperature read command
#define RH_REQ 			0x05		//humidity read command
#define START_DELAY 	2000000		//start delay
#define INTERVAL_DELAY 	100000000	//minimum read interval

//==GLOBAL VARS=================================================================
extern int SHT75_erno;

typedef struct r_SHT75 {
    port SCL;
    port SDA;
}  r_SHT75;

float SHT75_calcDew();
float SHT75_readTemp(struct r_SHT75 &SHT75);
float SHT75_readRH(struct r_SHT75 &SHT75);
float SHT75_getRH(struct r_SHT75 &SHT75);
float SHT75_getTemp(struct r_SHT75 &SHT75);
float SHT75_getDew(struct r_SHT75 &SHT75);
unsigned short SHT75_recv2bytes(struct r_SHT75 &SHT75);
int SHT75_sendbyte(unsigned short sht_send,struct r_SHT75 &SHT75);
void SHT75_resetComm(struct r_SHT75 &SHT75);
void SHT75_initPins(struct r_SHT75 &SHT75);
void InitModSHT75(REFERENCE_PARAM(struct r_SHT75,SHT75));
void delay(int dtime);
void SHT75_print(struct r_SHT75 &SHT75);

#endif /* SHT75_H_ */
