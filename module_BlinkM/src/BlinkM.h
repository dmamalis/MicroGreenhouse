/*
 * BlinkM.h
 *
 *  Created on: Jul 22, 2013
 *      Author: dimitris
 */

#ifndef BLINKM_H_
#define BLINKM_H_

#include <platform.h>
#include <xs1.h>
#include <xccompat.h>
#include "i2c.h"


#define LEDS_OFF		0
#define BLINK_BLUE 		1
#define BLINK_RED		2
#define	PLAY_CUSTOM 	3
#define BLINK_ONE_BLUE	4
#define BLINK_ONE_RED	5
#define TEST			6

typedef struct r_LCPorts{
	r_i2c i2c_rec;
}r_LCPorts;

typedef struct blinkm{
	unsigned char val[8];
}blinkm;
//void delay(int dtime);
void InitModBlinkM(REFERENCE_PARAM(struct r_i2c,i2c));
void GoToRGB (unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm);
void FadeToRGB(unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm);
void FadeToHSB(unsigned char address, unsigned char H, unsigned char S, unsigned char B, struct r_i2c &linkm);
void FadeToRandomRGB(unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm);
void FadeToRandomHSB(unsigned char address, unsigned char H, unsigned char S, unsigned char B, struct r_i2c &linkm);
void PlayLightScript(unsigned char address, int n,int r,int p, struct r_i2c &linkm);
void StopScript(unsigned char address, struct r_i2c &linkm);
void SetFadeSpeed(unsigned char address, unsigned char time, struct r_i2c &linkm);
void SetTimeAdjust(unsigned char address, unsigned char time, struct r_i2c &linkm);
void GetCurrentRGB(unsigned char address, struct r_i2c &linkm);
void WriteScriptLine(unsigned char address,unsigned char n,unsigned char p,unsigned char d,unsigned char c,unsigned char a1,unsigned char a2,unsigned char a3,struct r_i2c &linkm);
blinkm ReadScriptLine(unsigned char address,int n,int p,struct r_i2c &linkm);
void SetScriptLength(unsigned char address,unsigned char n,unsigned char l,unsigned char r,struct r_i2c &linkm);
void SetAddress(unsigned char address,struct r_i2c &linkm);
blinkm GetAddress(struct r_i2c &linkm);
blinkm GetFirmwareVersion(unsigned char address,struct r_i2c &linkm);
void SetStartupParameters(unsigned char address,int m,int n,int r,int f,int t,struct r_i2c &linkm);
void appLightControl(chanend leds_c);


#endif /* BLINKM_H_ */
