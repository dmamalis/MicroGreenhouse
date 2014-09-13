#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "PulseModulation.h"

//==============================================================================

//Initialize PWMs
void InitModDimmer(struct r_Dimmer &Dimmer) {
	Dimmer.zcd 		:> void;
	Dimmer.pwm 		:> void;
}

void InitModServo(struct r_Servo2 &Servo){
	Servo.angle 	:> void;
}

void InitModFan(struct r_SoftStart &SoftStart){
	SoftStart.pwm			:> void;
}

void Servo_delay(int dtime){
	timer t;
	int time;
	t:>time;
	t when timerafter(time+dtime):>void;
}

void Servo_PositiveAngle(struct r_Servo2 &Servo){
	timer t;
	int now;
	for(int cnt=0;cnt<12;cnt+1){
		t:>now;
		Servo.angle <: 1;
		t when timerafter(now+HIGH_DUTY) :> now;
		Servo.angle  <: 0;
		if(PERIOD-HIGH_DUTY == 0){
		}
		else
			t when timerafter(now+PERIOD-HIGH_DUTY):> void;
		cnt++;
	}
}

void Servo_ZeroAngle(struct r_Servo2 &Servo){
	timer t;
	int now;
	while(1){
		t:>now;
		Servo.angle <: 1;
		t when timerafter(now+MID_DUTY) :> now;
		Servo.angle<: 0;
		t when timerafter(now+PERIOD-MID_DUTY):> void;
	}
}

void Servo_NegativeAngle(struct r_Servo2 &Servo){
	timer t;
	int now;
	for(int cnt=0;cnt<12;cnt+1){
		t:>now;
		Servo.angle <: 1;
		t when timerafter(now+LOW_DUTY) :> now;
		Servo.angle <: 0;
		t when timerafter(now+PERIOD-LOW_DUTY):> void;
		cnt++;
	}
}

void Dimmer(struct r_Dimmer &Dimmer,int mode){
	int cnt;
	if(mode==1){
		for(cnt=0; cnt<ON; cnt++){
			Dimmer.zcd when pinseq(0) :> void;
			Dimmer.zcd when pinseq(1) :> void;
		}
		Dimmer.pwm<:0;
		for(cnt=0; cnt<OFF; cnt++){
			Dimmer.zcd when pinseq(0) :> void;
			Dimmer.zcd when pinseq(1) :> void;
		}
		Dimmer.pwm<:1;
	}
	else
		Dimmer.pwm<:0;
}


int SoftStart(struct r_SoftStart &SoftStart, int mode){
	int duty;
	int now;
	int drivedown, driveup;
	timer t;
	duty   =	SOFTSTART_DUTY_OFFSET;
	//start with the output off
	SoftStart.pwm <: 0;

	//Uncomment for safe start delay
	//t when timerafter(SOFTSTART_DELAY) :> void;
	if(mode){
		while(duty != SOFTSTART_PERIOD) {
			t:>now;
			if(duty != SOFTSTART_PERIOD) { // if not always on
				//obtain time of PWM falling edge
				drivedown = now + duty;
				if (duty < SOFTSTART_MAX_DUTY){
					duty = duty + SOFTSTART_PWM_RATE;
				}
				//output falling edge
				t when timerafter(drivedown) :> void;
				SoftStart.pwm <: 0;
			}
			if(duty != 0) { // if not always off
				//obtain time for end of PWM cycle
				driveup = now + SOFTSTART_PERIOD;
				//output rising edge
				t when timerafter(driveup) :> void;
				SoftStart.pwm<: 1;
			}
		}
	}
	else
		SoftStart.pwm<:0;
//	printf("return\n--------------------------------->");
	return 1;
}

void pwm(struct r_SoftStart &SoftStart, int mode, int speed){
	timer time;
	int now;
	int max_duty;
	if (speed > 4){
		speed=4;
	}
	else if (speed < 0){
		speed =0;
	}
	max_duty = SOFTSTART_STEP_DUTY * speed;

	if(mode){
		SoftStart.pwm <: 1;
		time :> now;
		time when timerafter(now+max_duty) :> void;
		SoftStart.pwm <: 0;
		time :> now;
		time when timerafter(now+SOFTSTART_PERIOD-max_duty) :> void;
	}
	else
		SoftStart.pwm <: 0;
}

void onoff(struct r_SoftStart &SoftStart,int mode){
	if(mode){
		SoftStart.pwm <:1;
	}
	else{
		SoftStart.pwm <:0;
	}
}

void SwitchRelay(port Relay_port,int Relay_mode){
	Relay_port <: Relay_mode;
}

