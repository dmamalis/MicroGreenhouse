/*
 * BlinkM.xc
 *
 *  Created on: Jul 22, 2013
 *      Author: dimitris
 */

#include "BlinkM.h"
#include <stdio.h>
#include "i2c.h"

extern r_LCPorts LCPorts_rec;

void InitModBlinkM(struct r_i2c &BlinkM) {
	BlinkM.scl :> void;
	BlinkM.sda :> void;
}

void GoToRGB (unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]= R;
	i2c_register[1]= G;
	i2c_register[2]= B;
	i2c_master_write_reg(address,'n',i2c_register,3,linkm);
}

void FadeToRGB(unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]= R;
	i2c_register[1]= G;
	i2c_register[2]= B;
	i2c_master_write_reg(address,'c',i2c_register,3,linkm);
}

void FadeToHSB(unsigned char address, unsigned char H, unsigned char S, unsigned char B, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]= H;
	i2c_register[1]= S;
	i2c_register[2]= B;
	i2c_master_write_reg(address,'h',i2c_register,3,linkm);
}

void FadeToRandomRGB(unsigned char address, unsigned char R, unsigned char G, unsigned char B, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]= R;
	i2c_register[1]= G;
	i2c_register[2]= B;
	i2c_master_write_reg(address,'C',i2c_register,3,linkm);
}

void FadeToRandomHSB(unsigned char address, unsigned char H, unsigned char S, unsigned char B, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]= H;
	i2c_register[1]= S;
	i2c_register[2]= B;
	i2c_master_write_reg(address,'H',i2c_register,3,linkm);
}

void PlayLightScript(unsigned char address, int n,int r,int p, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]=n;
	i2c_register[1]=r;
	i2c_register[2]=p;
	i2c_master_write_reg(address, 'p', i2c_register,3,linkm);
}

void StopScript(unsigned char address, struct r_i2c &linkm){
	unsigned char i2c_register[1];
	i2c_master_write_reg(address, 'o',i2c_register,0,linkm);
}

void SetFadeSpeed(unsigned char address, unsigned char time, struct r_i2c &linkm){
	unsigned char i2c_register[1];
	i2c_register[0]= time;
	i2c_master_write_reg(address,'f',i2c_register,1,linkm);
}

void SetTimeAdjust(unsigned char address, unsigned char time, struct r_i2c &linkm){
	unsigned char i2c_register[1];
	i2c_register[0]= time;
	i2c_master_write_reg(address,'t',i2c_register,1,linkm);
}

void GetCurrentRGB(unsigned char address, struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_master_read_reg(address, 'g', i2c_register, 3, linkm);
	printf("%d\t%d\t%d\n",i2c_register[0],i2c_register[1],i2c_register[2]);
}

void WriteScriptLine(unsigned char address,unsigned char n,unsigned char p,unsigned char d,unsigned char c,unsigned char a1,unsigned char a2,unsigned char a3,struct r_i2c &linkm){
	unsigned char i2c_register[7];
	i2c_register[0]= 0x00;	//script id
	i2c_register[1]=p;		//line number
	i2c_register[2]=d;		//command duration
	i2c_register[3]=c;		//BlinkM command
	i2c_register[4]=a1;		//BlinkM command argument 1
	i2c_register[5]=a2;		//BlinkM command argument 2
	i2c_register[6]=a3;		//BlinkM command argument 3

	//Once all the lines of the desired script are writtern, set the script length with the Set Script Length command
	i2c_master_write_reg(address,'W',i2c_register, 7,linkm);
}

blinkm ReadScriptLine(unsigned char address,int n,int p,struct r_i2c &linkm){
	unsigned char i2c_register[8];
	blinkm scriptline;
	i2c_register[0]=n;
	i2c_master_write_reg(address,'R',i2c_register,1,linkm);
	i2c_master_read_reg(address,p,i2c_register,6,linkm);
	scriptline.val[0]=i2c_register[0];
	scriptline.val[1]=i2c_register[1];
	scriptline.val[2]=i2c_register[2];
	scriptline.val[3]=i2c_register[3];
	scriptline.val[4]=i2c_register[4];
	scriptline.val[5]=i2c_register[5];
	scriptline.val[6]=i2c_register[6];
	scriptline.val[7]=i2c_register[7];
	return scriptline;

}

void SetScriptLength(unsigned char address,unsigned char n,unsigned char l,unsigned char r,struct r_i2c &linkm){
	unsigned char i2c_register[3];
	i2c_register[0]=n;
	i2c_register[1]=l;
	i2c_register[2]=r;
	i2c_master_write_reg(address,'L',i2c_register,3,linkm);
}

void SetAddress(unsigned char address,struct r_i2c &linkm){
	unsigned char i2c_register[4];
	i2c_register[0]=address;
	i2c_register[1]=0xd0;
	i2c_register[2]=0x0d;
	i2c_register[3]=address;
	i2c_master_write_reg(0x00, 'A', i2c_register,4,linkm);
}

blinkm GetAddress(struct r_i2c &linkm){
	unsigned char i2c_register[1];
	blinkm address;
	i2c_master_read_reg(0x00,'a', i2c_register,1,linkm);
	address.val[0]=i2c_register[0];
	return address;
}

blinkm GetFirmwareVersion(unsigned char address,struct r_i2c &linkm){
	unsigned char i2c_register[2];
	blinkm firmware;
	i2c_master_read_reg(address, 'Z', i2c_register,2,linkm);
	firmware.val[0]=i2c_register[0];
	firmware.val[1]=i2c_register[1];
	return firmware;
}

void SetStartupParameters(unsigned char address,int m,int n,int r,int f,int t,struct r_i2c &linkm){
	unsigned char i2c_register[5];
	i2c_register[0]=m;
	i2c_register[1]=n;
	i2c_register[2]=r;
	i2c_register[3]=f;
	i2c_register[4]=t;
	i2c_master_write_reg(address,'B',i2c_register,5,linkm);
}

void appLightControl(chanend LCCommand_c){

	int mode=0;
	int start;
	int action;
	int req;

	//Start signal
	LCCommand_c :> start;
	//SetStartupParameters(0x00,0,0,0,0,0,LCPorts_rec.i2c_rec);
	while(1){
		select{
//			case WCData_c :> req:
//				WCData_rec = getWCData();
//				WCData_c <: WCData_rec;
//				break;



			case LCCommand_c :> action:
				switch(action){
					case LEDS_OFF: //0
						SetTimeAdjust(0X00, -10, LCPorts_rec.i2c_rec);
						SetFadeSpeed(0X00, 15, LCPorts_rec.i2c_rec);
						PlayLightScript(0x00,9,0,0,LCPorts_rec.i2c_rec);
						break;
					case BLINK_BLUE: //1
						PlayLightScript(0x00,5,0,0,LCPorts_rec.i2c_rec);
						break;
					case BLINK_RED: //2
						PlayLightScript(0x00,3,0,0,LCPorts_rec.i2c_rec);
						break;
					case PLAY_CUSTOM: //3
						PlayLightScript(0x00,0,0,0,LCPorts_rec.i2c_rec);
						break;
					case BLINK_ONE_BLUE: //4
						PlayLightScript(0x13,5,0,0,LCPorts_rec.i2c_rec);
						break;
					case BLINK_ONE_RED: //5
						PlayLightScript(0x13,3,0,0,LCPorts_rec.i2c_rec);
						break;
					case TEST:
						PlayLightScript(0x19,2,0,0,LCPorts_rec.i2c_rec);
						break;
					default:
						break;
				}
				break;
			default:
				break;
		}
/////////////////////////////////////////////
	}
}
