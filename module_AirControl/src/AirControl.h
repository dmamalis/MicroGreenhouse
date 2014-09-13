/*
 * AC.h
 *
 *  Created on: Jun 11, 2013
 *      Author: dimitris
 */

#ifndef AIRCONTROL_H_
#define AIRCONTROL_H_
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "SimpleUART.h"
#include "SHT75.h"
#include "Cozir.h"
#include "PulseModulation.h"


#define SERVOS_ON 		0
#define SERVOS_OFF 		1
#define HEATER_ON 		2
#define HEATER_OFF 		3
#define CONDENSER_ON	4
#define CONDENSER_OFF 	5
#define FAN_ON_FULL		6
#define FAN_ON_MIN		7
#define FAN_OFF			8

typedef struct r_ACPorts {
	r_Dimmer Dimmer_rec;
	r_Servo2 Servo1_rec ;
	r_Servo2 Servo2_rec ;
	r_SoftStart Fan_rec;
	r_SoftStart Condenser_rec;
	r_SHT75 SHT75_rec;
	r_uart Cozir_rec;
}  r_ACPorts;

typedef struct r_ACData {
	float SensTemp;
	float SensRH;
	float SensDew;
	float CozTemp;
	float CozRH;
	int CozCO2;
}  r_ACData;

void InitModAirControl();
void appFan(chanend fan_c);
void appDimmer(chanend dim_c);
void appServoControl(chanend servo_c);
void appServo1(chanend servo_c);
void appServo2(chanend servo_c);
void appAirControl(chanend ACCommand_c,chanend ACData_c,chanend dim_c,chanend fan_c,chanend servo1_c,chanend serv2_c);
r_ACData getData();
#endif /* AIRCONTROL_H_ */
