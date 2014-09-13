#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "SHT75.h"

int SHT75_erno;

void delay(int dtime){
	timer t;
	int time;
	t:>time;
	t when timerafter(time+dtime):>void;
}
//Initialize SHT75
void InitModSHT75(struct r_SHT75 &SHT75) {
	SHT75.SCL :> void;
	SHT75.SDA :> void;
	SHT75_erno=0;
}

void SHT75_initPins(struct r_SHT75 &SHT75){
	SHT75.SDA :> void;
	SHT75.SCL <: 0;
	delay(100);
}

void SHT75_resetComm(struct r_SHT75 &SHT75){
	short j = 0;

	// Reset connection
	SHT75.SDA :> void;
	for(j = 10; j >= 0 ; j--){
		delay(100);
		SHT75.SCL <: 1;
		delay(100);
		SHT75.SCL <: 0;
	}
}

int SHT75_sendByte(unsigned short sht_send,struct r_SHT75 &SHT75){
	short ack = 0;
	short j = 0;
	short datain=0;

	// Transmission start
	delay(100);
	SHT75.SDA :> void;
	delay(100);
	SHT75.SCL <: 1;
	delay(100);
	SHT75.SDA <: 0;
	delay(100);
	SHT75.SCL <: 0;
	delay(100);
	SHT75.SCL <: 1;
	delay(100);
	SHT75.SDA :> void;
	delay(100);
	SHT75.SCL <: 0;
	delay(100);
	SHT75.SDA <: 0;
	delay(100);

	// Send one byte
	for(j = 7; j >= 0 ; j--)
	{
		delay(100);
		if(sht_send & (1<<j)){
			SHT75.SDA :> void;
		}
		else{
			SHT75.SDA <: 0;
		}
		delay(100);
		SHT75.SCL <: 1;
		delay(100);
		SHT75.SCL <: 0;
	}

	// Check for ACK
	delay(100);
	SHT75.SDA :> void;
	delay(100);
	delay(100);
	SHT75.SCL <: 1;
	delay(100);
	SHT75.SDA :> datain;

	if(datain==1){
		ack = 0;
		//printf("ERROR: Sensirion No ACK!\n");
	}
	else{
		ack = 1;
	}

	SHT75.SCL <: 0;
	delay(100);

	return ack;
}

unsigned short SHT75_recv2bytes(struct r_SHT75 &SHT75){
	short j = 0;
	short datain = 0;
	unsigned short sht_recv = 0x0000;

	// receive first byte
	for(j = 7; j >= 0 ; j--){
		delay(100);
		SHT75.SCL <: 1;
		delay(100);
		SHT75.SDA :> datain;
		sht_recv += (datain << j);
		delay(100);
		SHT75.SCL <: 0;
	}

	// Shift value
	sht_recv <<= 8;

	// Send ACK
	delay(100);
	SHT75.SDA <: 0;
	delay(100);
	SHT75.SDA <: 0;
	delay(100);
	SHT75.SCL <: 1;
	delay(100);
	SHT75.SCL <: 0;
	delay(100);
	SHT75.SDA :> datain;

	// receive second byte
	for(j = 7; j >= 0 ; j--){
		delay(100);
		SHT75.SCL <: 1;
		delay(100);
		SHT75.SDA :> datain;
		sht_recv += (datain << j);
		delay(100);
		SHT75.SCL <: 0;
	}

	// Send final ACK
	delay(100);
	SHT75.SDA <: 0;
	delay(100);
	SHT75.SDA :> void;
	delay(100);
	SHT75.SCL <: 1;
	delay(100);
	SHT75.SCL <: 0;
	delay(100);

	return sht_recv;
}

float SHT75_getRH(struct r_SHT75 &SHT75){
	int ack;
	float relHumidity;
	delay(10000);
	SHT75_resetComm(SHT75);
	//Read RH
	ack=SHT75_sendByte(RH_REQ,SHT75);
	if(ack!=0){
		SHT75.SDA when pinseq(0) :> void;
		relHumidity= (float) SHT75_recv2bytes(SHT75);
		relHumidity=(-2.0468 + (relHumidity * 0.0367) + (relHumidity * relHumidity * -0.0000015955));
		if (relHumidity > 100 || relHumidity < 0){
			SHT75_erno=4;	//Bad Read
		}
	}
	else
		SHT75_erno=3;	//No ACK

	//Error Check
	switch(SHT75_erno){
		case 3:
			//printf("ERROR: Sensirion: No ACK\n");
			SHT75_erno=0;
			break;
		case 4:
			//printf("ERROR: Sensirion: No Data\n");
			SHT75_erno=0;
			break;
		default:
			break;
	}
	return relHumidity;
}

float SHT75_getTemp(struct r_SHT75 &SHT75){
	int ack;
	float temperature;
	delay(10000);
	SHT75_resetComm(SHT75);
	//Read Temp
	ack=SHT75_sendByte(TEMP_REQ,SHT75);
	if(ack != 0){
		SHT75.SDA when pinseq(0) :> void;
		//SHT75_temp = SHT75_readTemp(SHT75);
		temperature = (float) SHT75_recv2bytes(SHT75);
		temperature = (-39.65 + 0.01 * temperature);
		if (temperature > 100 || temperature < -40){
			SHT75_erno=2;	//Bad Read
		}
	}
	else{
		SHT75_erno=1; //No ACK
	}
	//Error Check
	switch(SHT75_erno){
		case 1:
			//printf("ERROR: Sensirion: No ACK\n");
			SHT75_erno=0;
			break;
		case 2:
			//printf("ERROR: Sensirion: No Data\n");
			SHT75_erno=0;
			break;
		default:
			break;
	}
	return temperature;
}

float SHT75_getDew(struct r_SHT75 &SHT75){
	float relHumidity;
	float temperature;
	float dew;

	relHumidity=SHT75_getRH(SHT75);
	temperature=SHT75_getTemp(SHT75);

	//Calculate Dew point
	if(SHT75_erno==0){
		dew = (17.62 * temperature);
		dew = dew / (243.12 + temperature);
		dew = dew + log(relHumidity / 100);
		dew = dew / (17.62 - dew);
		dew = 243.12 * dew;
	}
	//Error Check
	if (SHT75_erno!=0 ){
		//printf("ERROR: SgetDew: ensirion No Data\n");
		//reset error code
		SHT75_erno=0;
	}
	return dew;
}

void SHT75_print(struct r_SHT75 &SHT75){
	int ack;
	float rh;
	float temp;
	float dew;
	//TODO Start up delay might be only needed outside the while loop
	//delay(START_DELAY);
	SHT75_resetComm(SHT75);
	printf("Sensirion --> ");

	//Read RH
	ack=SHT75_sendByte(RH_REQ,SHT75);
	if(ack!=0){
		//SHT75.SDA when pinseq(0) :> void;
		rh = SHT75_getRH(SHT75);
		if (rh > 100 || rh < 0){
			SHT75_erno=4;	//Bad Read
		}
	}
	else
		SHT75_erno=3;	//No ACK

	//Read Temp
	ack=SHT75_sendByte(TEMP_REQ,SHT75);
	if(ack != 0){
		temp = SHT75_getTemp(SHT75);
		if (temp > 100 || temp < -40){
			SHT75_erno=2;	//Bad Read
		}
	}
	else
		SHT75_erno=1; //No ACK

	//Calculate Dew point
	if(SHT75_erno==0){
		dew = SHT75_getDew(SHT75);
	}
	delay(INTERVAL_DELAY);

//todo	//Error Check
//	switch(SHT75_erno){
//		case 1: printf("ERROR: Sensirion: No ACK\n");
//		break;
//		case 3: printf("ERROR: Sensirion: No ACK\n");
//		break;
//		case 2: printf("ERROR: Sensirion: No Data\n");
//		break;
//		case 4: printf("ERROR: Sensirion: No Data\n");
//		break;
//		default:
//			break;
//	}
}
