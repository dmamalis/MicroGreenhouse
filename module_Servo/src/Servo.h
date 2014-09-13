/*
 * Servo.h
 *
 *  Created on: Jul 02, 2013
 *      Author: dimitris
 */

#ifndef Servo_H_
#define Servo_H_

#include <xs1.h>
#include <xccompat.h>

//Timing variables in nanoseconds
#define PERIOD			2000000
#define LOW_DUTY		100000
#define MID_DUTY		150000
#define HIGH_DUTY		200000


#define NEGATIVE_ANGLE 0
#define ZERO_ANGLE 2
#define POSITIVE_ANGLE 1


//==GLOBAL VARS=================================================================

typedef struct r_Servo {
    port Angle_p;
}  r_Servo;

void InitModServo(REFERENCE_PARAM(struct r_Servo,Servo));
void Servo_NegativeAngle(struct r_Servo &Servo);
void Servo_ZeroAngle(struct r_Servo &Servo);
void Servo_PositiveAngle(struct r_Servo &Servo);
void Servo_delay(int dtime);
#endif /* Servo_H_ */
