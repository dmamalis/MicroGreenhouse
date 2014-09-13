//==INCLUDES====================================================================
#include <xscope.h>
#include <math.h>
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include "WaterControl.h"
#include "i2c.h"
#include <print.h>

#define BAUDRATE_PEM		115200

extern r_WCPorts WCPorts_rec;
extern out port enable_ports;

//==============================================================================
float GetEC(struct r_EC &EC){
	return 1000*MeasureEC(EC);
}

void wait(int dtime){
	timer t;
	int time;
	t:>time;
	t when timerafter(time+dtime*100000000):>void;
}

void ctrValves(struct r_Valves &Valves, int ID, int mode){
	switch(ID){
	case 1:
		Valves.Valve1 <: mode;
		break;
	case 2:
		Valves.Valve2 <: mode;
		break;
	case 3:
		Valves.Valve3 <: mode;
		break;
	case 4:
		Valves.Valve4 <: mode;
		break;
	case 5:
		Valves.Valve5 <: mode;
		break;
	case 6:
		Valves.Valve6 <: mode;
		break;
	default:
		break;
	}
}
void ctrPumps(struct r_SoftStart &Pumps, int ID, int mode){
	switch(ID){
		case 1:
			SoftStart(Pumps,mode);
			break;
		default:
			break;
	}
}

/* the four channel adc returns a struct containing all the 4 readings*/
r_adc GetADC(struct r_i2c &dP_rec){
/*
 *  |=======================================================|
 *	|	CHANNEL			|EXT_REF| 	REG_VAL		|	HEX		|
 *	|-------------------------------------------------------|
 *	|	NO				|	-	|	00000011	|	0x03	|
 *	|	1				|	-	|	00010011	|	0x13	|
 *	|	2				|	-	|	00100011	|	0x23	|
 *	|	2				|	V	|	00101011	|	0x2B	|
 *	|	3				|	-	|	01000011	|	0x43	|
 *	|	4				|	-	|	10000011	|	0x83	|
 *	|	1 & 2			|	-	|	00110011	|	0x33	|
 *	|	2 & 3			|	-	|	01100011	|	0x63	|
 *	|	1 & 2 & 3		|	-	|	01110011	|	0x73	|
 *	|	1 & 2 & 3 & 4	|	-	|	11110011	|	0xF3	|
 *	|=======================================================|
 */
	unsigned char i2c_register1[2];
	int adc_value[4];
	int chID=5;
	r_adc retval;

	//::Config start
	for(int i=0;i<4;i++){
		//Read value from ADC
		i2c_master_rx(0x28, i2c_register1, 2, dP_rec);
		chID = (i2c_register1[0]>>4)&0xF;
		i2c_register1[0]=i2c_register1[0]&0x0F;
		adc_value[i]=(i2c_register1[0]<<6)|(i2c_register1[1]>>2);
		//adc_value[i]=(i2c_register1[0]<<8)|(i2c_register1[1]);
	}
	retval.adc0=adc_value[0];
	retval.adc1=adc_value[1];
	retval.adc2=adc_value[2];
	retval.adc3=adc_value[3];
	return retval;
}

float GetHeight(struct r_i2c &dP_rec,int ID){
	unsigned char i2c_register[1]={0xF3};
	r_adc dP;
	float height;
	float scaler;
	short int ZEROPOINT 			=28;
	short int ZEROPOINT_SAMPLE_DP0 	=366;
	short int TOPPOINT_SAMPLE_DP0 	=665;
	short int ZEROPOINT_SAMPLE_DP1 	=417;
	short int TOPPOINT_SAMPLE_DP1 	=707;
	short int ZEROPOINT_SAMPLE_DP2 	=477;
	short int TOPPOINT_SAMPLE_DP2	=762;
	short int ZEROPOINT_SAMPLE_DP3 	=437;
	short int TOPPOINT_SAMPLE_DP3 	=736;

	//::Config start
	i2c_master_write_reg(0x28, 0x00, i2c_register, 1, dP_rec);

	dP=GetADC(dP_rec);
	switch(ID){
		case 0:
			scaler = (float)ZEROPOINT/(TOPPOINT_SAMPLE_DP0-ZEROPOINT_SAMPLE_DP0);
			height = scaler * ((float) dP.adc0 -ZEROPOINT_SAMPLE_DP0);
			//height= dP.adc0;
			break;
		case 1:
			scaler = (float)ZEROPOINT/(TOPPOINT_SAMPLE_DP1-ZEROPOINT_SAMPLE_DP1);
			height = scaler * ((float) dP.adc1 -ZEROPOINT_SAMPLE_DP1);
//			height= dP.adc1;
			break;
		case 2:
			scaler = (float)ZEROPOINT/(TOPPOINT_SAMPLE_DP2-ZEROPOINT_SAMPLE_DP2);
			height = scaler * ((float) dP.adc2 -ZEROPOINT_SAMPLE_DP2);
//			height= dP.adc2;
			break;
		case 3:
			scaler = (float)ZEROPOINT/(TOPPOINT_SAMPLE_DP3-ZEROPOINT_SAMPLE_DP3);
			height = scaler * ((float) dP.adc3 -ZEROPOINT_SAMPLE_DP3);
//			height= dP.adc3;
			break;
	}
	return height;
}

void appWaterControl(chanend WCData_c,chanend WCCommand_c){

	r_WCData WCData_rec;
	int mode=0;
	int start;
	int action;
	int req;

	//*************************************************************************
	//TODO the two following lines are used to put pin XS1_PORT_1A on IO mode.
	//This is supposed to be done at boot time without the ened to programm it!
	enable_ports <: 0x80; //Send one to DFF
	enable_ports <: 0xc0;  //Latch one into DFF to disable SPI but enable ports
	//*************************************************************************

	//Start signal
	WCData_c :> start;

	while(1){

//		for(int i=0;i<7;i++){
//			ctrValves(WCPorts_rec.Valves_rec,i,1);
//			wait(5);
//			ctrValves(WCPorts_rec.Valves_rec,i,0);
//		}

///////////////////////////////////////////////////////////////////////////////////////////
//		/**********************************************
//		* APPLY WATER CONTROL TEST PROTOCOL
//		**********************************************/
//		select{
//			case WCCommand_c :> mode:
//				switch(mode){
//					case 0: //IDLE
//						printf("2:WC Idle\n");
//						break;
//					case 1: //FERTIGATION
//						printf("2:WC Fert\n");
//						ctrPumps(WCPorts_rec.Pumps_rec,1,1);
//						wait(20);
//						ctrValves(WCPorts_rec.Valves_rec,WATER_V,1);
//						wait(15);
//						ctrValves(WCPorts_rec.Valves_rec,WATER_V,0);
//						ctrValves(WCPorts_rec.Valves_rec,DRAIN_V,1);
//						wait(15);
//						ctrValves(WCPorts_rec.Valves_rec,DRAIN_V,0);
//						ctrValves(WCPorts_rec.Valves_rec,NUTRIENT_V,1);
//						wait(10);
//						ctrValves(WCPorts_rec.Valves_rec,NUTRIENT_V,0);
//						ctrValves(WCPorts_rec.Valves_rec,FERTIGATE_V,1);
//						wait(10);
//						wait(10);
//						wait(10);
//						ctrValves(WCPorts_rec.Valves_rec,FERTIGATE_V,0);
//						ctrValves(WCPorts_rec.Valves_rec,WASTE_V,1);
//						wait(2);
//						ctrValves(WCPorts_rec.Valves_rec,WASTE_V,0);
//						ctrPumps(WCPorts_rec.Pumps_rec,1,0);
//						break;
//					default:
//						break;
//				}
//			break;
//		default: //gather data
//			//Push data to top app
//
//			WCData_rec = getWCData();
////			printf("WCDEBUG------------------->\n");
//			WCData_c <: WCData_rec;
//			break;
//		}
//////////////////////////////////////////////////////////////////////////////////////////////

		/**********************************************
		* APPLY WATER CONTROL TEST PROTOCOL ver2
		**********************************************/
		select{
			case WCData_c :> req:
				WCData_rec = getWCData();
				WCData_c <: WCData_rec;
				break;
			case WCCommand_c :> action:
				switch(action){
					case PUMP_ON: //0
						ctrPumps(WCPorts_rec.Pumps_rec,1,1);
						//action =1;
						break;
					case WATER_V_ON	:
						ctrValves(WCPorts_rec.Valves_rec,WATER_V,1);
						//action =2;
						break;
					case WATER_V_OFF:
						ctrValves(WCPorts_rec.Valves_rec,WATER_V,0);
						//action =3;
						break;
					case DRAIN_V_ON:
						ctrValves(WCPorts_rec.Valves_rec,DRAIN_V,1);
						//action =4;
						break;
					case DRAIN_V_OFF:
						ctrValves(WCPorts_rec.Valves_rec,DRAIN_V,0);
//						action =5;
						break;
					case NUTRIENT_V_ON:
						ctrValves(WCPorts_rec.Valves_rec,NUTRIENT_V,1);
//						action =6;
						break;
					case NUTRIENT_V_OFF:
						ctrValves(WCPorts_rec.Valves_rec,NUTRIENT_V,0);
//						action =0;
						break;
					case FERTIGATE_V_ON:
						ctrValves(WCPorts_rec.Valves_rec,FERTIGATE_V,1);
//						action =0;
						break;
					case FERTIGATE_V_OFF:
						ctrValves(WCPorts_rec.Valves_rec,FERTIGATE_V,0);
//						action =0;
						break;
					case WASTE_V_ON:
						ctrValves(WCPorts_rec.Valves_rec,WASTE_V,1);
//						action =0;
						break;
					case WASTE_V_OFF:
						ctrValves(WCPorts_rec.Valves_rec,WASTE_V,0);
//						action =0;
						break;
					case PUMP_OFF:
						ctrPumps(WCPorts_rec.Pumps_rec,1,0);
//						action =0;
						break;
					default:
						break;
				}
			break;
		}
/////////////////////////////////////////////
	}
}

r_WCData getWCData(){
	r_WCData WCData_rec;
#ifdef __DUMMY
	WCData_rec.EC = 0xFF;
	//TODO check callibration!
	WCData_rec.H1 =0xFF;
	WCData_rec.H2 =0xFF;
	WCData_rec.H3 =0xFF;
	WCData_rec.H4 =0xFF;
#else
	WCData_rec.EC = GetEC(WCPorts_rec.EC_rec);
	//WCData_rec.EC = 0xFF;
	//TODO check callibration!
	WCData_rec.H1 =GetHeight(WCPorts_rec.dP_rec,0);
	WCData_rec.H2 =GetHeight(WCPorts_rec.dP_rec,1);
	WCData_rec.H3 =GetHeight(WCPorts_rec.dP_rec,2);
	WCData_rec.H4 =GetHeight(WCPorts_rec.dP_rec,3);
#endif /*__DUMMY*/
	return WCData_rec;
}
