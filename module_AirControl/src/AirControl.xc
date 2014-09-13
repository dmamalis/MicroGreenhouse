//==INCLUDES====================================================================
#include <xscope.h>
#include <math.h>
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "AirControl.h"
//==MACROS======================================================================
#define FanON() fan_c<:1
#define FanOFF() fan_c<:0
#define HeaterON() dim_c<:1
#define HeaterOFF() dim_c<:0
//==DEFINES=====================================================================
#define BAUDRATE_COZIR 9600
//==PROTOTYPES==================================================================
//==GLOBAL VARS=================================================================
extern r_ACPorts ACPorts_rec;
//==============================================================================

void appAirControl(chanend ACCommand_c,chanend ACData_c,chanend dim_c, chanend fan_c, chanend servo1_c,chanend servo2_c){
	r_ACData ACData_rec;//, data_temp;
	int start,req;
	int action=0;
	//Initialize modules
	InitModSHT75(ACPorts_rec.SHT75_rec);
	InitModUart(ACPorts_rec.Cozir_rec);

#ifndef __DUMMY
	//Set COZIR to polling mode
	COZIR_setMode('2',ACPorts_rec.Cozir_rec);
	//COZIR_callibrateCO2(ACPorts_rec.Cozir_rec);
#endif /*__DUMMY*/


	//Start signal
	ACData_c :> start;
	servo1_c <:0;
	servo2_c <:0;

	while(1){

		select{
			case ACData_c :> req:
				//Push data to top app
				ACData_rec = getData();
				ACData_c <: ACData_rec;
				break;
			case ACCommand_c :>action:
				switch(action){
					case SERVOS_ON:
						servo1_c <: -1;
						servo2_c <: -1;
						break;
					case SERVOS_OFF:
						servo1_c <: 1;
						servo2_c <: 1;
						action =3;
						break;
					case HEATER_ON:
						dim_c<:1;
						break;
					case CONDENSER_ON:
						SwitchRelay(ACPorts_rec.Condenser_rec.pwm,1);
						break;
					case FAN_ON_FULL:
						fan_c <: 1;
						fan_c <: 4;
						break;
					case FAN_ON_MIN:
						fan_c <: 1;
						fan_c <: 3;
						break;
					case CONDENSER_OFF:
						SwitchRelay(ACPorts_rec.Condenser_rec.pwm,0);
						break;
					case FAN_OFF:
						fan_c<:0;
						fan_c<:0;
						break;
					case HEATER_OFF:
						dim_c<:0;
						break;
						break;
					default:
						break;
				}
			break;
		}
	}
}

r_ACData getData(){
	r_ACData ACData_rec;
#ifdef __DUMMY
		ACData_rec.SensRH	= 0xFF;
		ACData_rec.SensTemp	= 0xFE;
		ACData_rec.SensDew	= 0xFD;
		ACData_rec.CozRH	= 0xFC;
		ACData_rec.CozTemp	= 0xFB;
		ACData_rec.CozCO2	= 0xFA;
#else
//		//Get Sensirion Data
		ACData_rec.SensRH=SHT75_getRH(ACPorts_rec.SHT75_rec);
		ACData_rec.SensTemp=SHT75_getTemp(ACPorts_rec.SHT75_rec);
		ACData_rec.SensDew=SHT75_getDew(ACPorts_rec.SHT75_rec);
//		//Get Cozir Data
		ACData_rec.CozRH=(float)COZIR_getRH(ACPorts_rec.Cozir_rec)/10;
		ACData_rec.CozTemp=(float)COZIR_getTemp(ACPorts_rec.Cozir_rec)/10;
		ACData_rec.CozCO2=COZIR_getCO2(ACPorts_rec.Cozir_rec);
#endif/*__DUMMY*/
		return ACData_rec;
}

void appDimmer(chanend dim_c){

	int mode;
	InitModDimmer(ACPorts_rec.Dimmer_rec);
	dim_c :> mode;
	while(1){
		select{
			case dim_c :> mode:
				break;
			default:
				Dimmer(ACPorts_rec.Dimmer_rec,mode);
				break;
		}
	}
}

void appFan(chanend fan_c){
	int fanmode=0;
	int fanspeed=0;
	InitModFan(ACPorts_rec.Fan_rec);
	while(1){
		select{
			case fan_c:>fanmode:
				fan_c :> fanspeed;
				break;
			default:
				pwm(ACPorts_rec.Fan_rec,fanmode,fanspeed);
				break;
		}
	}
}

void appServo1(chanend servo1_c){
	int mode, duty,now,start;
	timer time;
	InitModServo(ACPorts_rec.Servo1_rec);
	mode =-1;
	servo1_c :> start;
	while(1){
		select{
			case servo1_c :> mode:
				break;
			default:
				switch(mode){
					case -1:
						duty=LOW_DUTY;
						break;
					case 0:
						duty=MID_DUTY;
						break;
					case 1:
						duty=HIGH_DUTY;
						break;
					default:
						break;
				}
				ACPorts_rec.Servo1_rec.angle <: 1;
				time :> now;
				time when timerafter(now+duty):> void;
				ACPorts_rec.Servo1_rec.angle <: 0;
				time :> now;
				time when timerafter(now+PERIOD-duty):> void;
				break;
		}
	}
}

void appServo2(chanend servo2_c){
	int mode, duty,now,start;
	timer time;
	InitModServo(ACPorts_rec.Servo2_rec);
	mode =-1;
	servo2_c :> start;
	while(1){
		select{
			case servo2_c :> mode:
				break;
			default:
				switch(mode){
					case -1:
						duty=LOW_DUTY;
						break;
					case 0:
						duty=MID_DUTY;
						break;
					case 1:
						duty=HIGH_DUTY;
						break;
					default:
						break;
				}
				ACPorts_rec.Servo2_rec.angle <: 1;
				time :> now;
				time when timerafter(now+duty):> void;
				ACPorts_rec.Servo2_rec.angle <: 0;
				time :> now;
				time when timerafter(now+PERIOD-duty):> void;
				break;
		}
	}
}
