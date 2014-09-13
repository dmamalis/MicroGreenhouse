/*
 * WaterControl.h
 *
 *  Created on: Jul 25, 2013
 *      Author: dimitris
 */

#ifndef WATERCONTROL_H_
#define WATERCONTROL_H_

//==INCLUDES====================================================================
#include <math.h>
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "EC.h"
#include "i2c.h"
#include "PulseModulation.h"

//==DEFINES=====================================================================
	//devices
#define	WASTE_V		1
#define	WATER_V		2
#define	FERTIGATE_V	3
#define	NUTRIENT_V 	4
#define	DRAIN_V		5
#define	WATER_DP	1
#define	DRAIN_DP	2
#define NUTRIENT_DP	3
#define MIX_DP		4
	//actions
#define PUMP_ON			0
#define PUMP_OFF		11
#define WATER_V_ON		1
#define WATER_V_OFF		2
#define DRAIN_V_ON		3
#define DRAIN_V_OFF		4
#define NUTRIENT_V_ON	5
#define NUTRIENT_V_OFF	6
#define FERTIGATE_V_ON	7
#define FERTIGATE_V_OFF	8
#define WASTE_V_ON		9
#define WASTE_V_OFF		10

typedef struct r_adc{
		int adc0;
		int adc1;
		int adc2;
		int adc3;
}r_adc;

typedef struct r_Valves {
	port Valve1;
	port Valve2;
	port Valve3;
	port Valve4;
	port Valve5;
	port Valve6;
} r_Valves;

typedef struct r_WCPorts {
	r_EC EC_rec;
	r_i2c dP_rec ;
	r_Valves Valves_rec;
	r_SoftStart Pumps_rec;
}  r_WCPorts;

typedef struct r_WCData {
	float H1;	//Liquid Height
	float H2;	//Liquid Height
	float H3;	//Liquid Height
	float H4;	//Liquid Height
	float EC;
}  r_WCData;

void wait(int dtime);
void delay(int dtime);
void appWaterControl(chanend WCData_c, chanend WCCommand_c);
float GetEC(struct r_EC &EC);
float GetHeight(struct r_i2c &dP_rec,int dPid);
void ctrValves(struct r_Valves &Valves,int ID, int mode);
r_adc GetADC(struct r_i2c &dP_rec);
r_adc callibratedP(r_adc dP);
void ctrPumps(struct r_SoftStart &Pumps,int ID, int mode);
r_WCData getWCData();

#endif /* WATERCONTROL_H_ */
