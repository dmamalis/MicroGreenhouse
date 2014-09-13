/*
 * PulseModulation.h
 *
 *  Created on: Jul 02, 2013
 *      Author: dimitris
 */

#ifndef PULSEMODULATION_H_
#define PULSEMODULATION_H_

#include <xs1.h>
#include <xccompat.h>

//Dimmer
#define ON						1
#define OFF 					5

//Servo	
#define PERIOD					2000000
#define LOW_DUTY				100000
#define MID_DUTY				150000
#define HIGH_DUTY				200000

//Fans
#define SOFTSTART_DELAY 		100000000000	//10 second delay
#define SOFTSTART_PERIOD		1000000
#define SOFTSTART_MAX_DUTY		1000000  		//0 -> period
#define SOFTSTART_STEP_DUTY		250000
#define SOFTSTART_DUTY_OFFSET	0
#define SOFTSTART_PWM_RATE		2500

//==GLOBAL VARS=================================================================

typedef struct r_Dimmer {
	port zcd;
    port pwm;
}  r_Dimmer;

typedef struct r_Servo2 {
    port angle;
}  r_Servo2;

typedef struct r_SoftStart {
    port pwm;
}  r_SoftStart;

void InitModDimmer(REFERENCE_PARAM(struct r_Dimmer,Dimmer)) ;
void InitModServo(REFERENCE_PARAM(struct r_Servo2,Servo));
void InitModFan(REFERENCE_PARAM(struct r_SoftStart,Fan));
void Servo_NegativeAngle(struct r_Servo2 &Servo);
void Servo_ZeroAngle(struct r_Servo2 &Servo);
void Servo_PositiveAngle(struct r_Servo2 &Servo);
void Servo_delay(int dtime);
void Dimmer(struct r_Dimmer &Dimmer,int mode);
void pwm(struct r_SoftStart &SoftStart, int mode,int speed);
int SoftStart(struct r_SoftStart &SoftStart,int mode);
void onoff(struct r_SoftStart &SoftStart,int mode);
void SwitchRelay(port Relay_port,int Relay_mode);
void Servo(port Servo_p,chanend servo_c);
#endif /* PULSEMODULATION_H_ */
