#include "Servo.h"

void Servo_delay(int dtime){
	timer t;
	int time;
	t:>time;
	t when timerafter(time+dtime):>void;
}

//Initialize Servo
void InitModServo(struct r_Servo &Servo) {
	Servo.Angle_p :> void;
}

void Servo_PositiveAngle(struct r_Servo &Servo){
	timer t;
	int now;
	for(int cnt=0;cnt<12;cnt+1){
		t:>now;
		Servo.Angle_p  <: 1;
		t when timerafter(now+HIGH_DUTY) :> now;
		Servo.Angle_p  <: 0;
		if(PERIOD-HIGH_DUTY == 0){
		}
		else
			t when timerafter(now+PERIOD-HIGH_DUTY):> void;
		cnt++;
	}
}

void Servo_ZeroAngle(struct r_Servo &Servo){
	timer t;
	int now;
	while(1){
		t:>now;
		Servo.Angle_p <: 1;
		t when timerafter(now+MID_DUTY) :> now;
		Servo.Angle_p <: 0;
		t when timerafter(now+PERIOD-MID_DUTY):> void;
	}
}

void Servo_NegativeAngle(struct r_Servo &Servo){
	timer t;
	int now;
	for(int cnt=0;cnt<12;cnt+1){
		t:>now;
		Servo.Angle_p <: 1;
		t when timerafter(now+LOW_DUTY) :> now;
		Servo.Angle_p <: 0;
		t when timerafter(now+PERIOD-LOW_DUTY):> void;
		cnt++;
	}
}
