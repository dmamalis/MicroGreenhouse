//==INCLUDES====================================================================
#include <xscope.h>
#include <math.h>
#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include <stdlib.h>
#include <print.h>
#include "app_Top.h"
#include "AirControl.h"
#include "WaterControl.h"
#include "BlinkM.h"
#include "MartenMode.h"

//==MACROS=====================================================================
//#define __DUMMY	1//uncomment to work when sensors and actuators are not connected

//==DEFINES=====================================================================

//==PROTOTYPES==================================================================
void PEM_data_struct(struct r_ACData &ACData_rec,struct r_WCData &WCData_rec, struct r_uart &PEM_rec);
void XScopeOut(struct r_ACData &ACData_rec, struct r_WCData &WCData_rec);
void topwait(int dtime);

//==GLOBAL VARS=================================================================

//==PORT Mapping=======================================================================
/*
 *	X0D00	1A	J5_01	//EC Pulse Input	X1D00	1A	J9_01	//Servo_1
 *	X0D01	1B	J4_06						X1D01	1B	J8_06	//PEM Transmit xmos transmition
 *	X0D10	1C	J4_07						X1D10	1C	J8_07	//PEM Receive
 *	X0D11	1D	J5_03	//EC i2c Clock		X1D11	1D	J9_03	//Fan PWM
 *	X0D12	1E	J5_02	//EC i2c Data		X1D12	1E	J9_02	//Servo_2
 *	X0D12	1E	J5_02						X1D12	1E	J9_02
 *	X0D22	1G	J4_15						X1D22	1G	J8_15
 *	X0D23	1H	J5_04	//dP i2c Clock		X1D23	1H	J9_04	//Condenser Relay
 *	X0D24	1I	J5_19	//dP i2c Data		X1D24	1I	J9_19	//Zero Crossing Detection Input
 *	X0D25	1J	J5_10	//Pump 1			X1D25	1J	J9_10	//Dimmer
 *	X0D34	1K	J5_11	//Vavle 1			X1D34	1K	J9_11	//Sensirion SCL
 *	X0D35	1L	J5_20	//Vavle 2			X1D35	1L	J9_20	//Sensirion SDATA
 *	X0D36	1M	J5_15	//Vavle 3			X1D36	1M	J9_15	//Cozir
 *	X0D37	1N	J5_17	//Vavle 4			X1D37	1N	J9_17	//Cozir
 *	X0D38	1O	J5_21	//Vavle 5			X1D38	1O	J9_21	//BlinkM Clock
 *	X0D39	1P	J5_23	//Vavle 6			X1D39	1P	J9_23	//BlinkM Data
*/
#define BAUDRATE_PEM	115200
#define BAUDRATE_COZIR 	9600

r_ACPorts ACPorts_rec = {			//Air Control Record
		on stdcore[1]:	XS1_PORT_1I,				//Zero Crossing Detection Input
		on stdcore[1]:	XS1_PORT_1J,				//Dimmer
		on stdcore[1]:	XS1_PORT_1A,				//Servo_1
		on stdcore[1]:	XS1_PORT_1E,				//Servo_2
		on stdcore[1]:  XS1_PORT_1D, 				//Fan PWM
		on stdcore[1]: 	XS1_PORT_1H,				//Condenser ONOFF
		on stdcore[1]:	XS1_PORT_1K,				//Sensirion SCL
		on stdcore[1]:	XS1_PORT_1L,				//Sensirion SDATA
		on stdcore[1]:	XS1_PORT_1M,				//Cozir Transmit
		on stdcore[1]:	XS1_PORT_1N,				//Cozir Receive
		BAUDRATE_COZIR
};

r_uart PEM_rec = {					//Communication Record
		on stdcore[1]:	XS1_PORT_1C,				//PEM Transmit
		on stdcore[1]:	XS1_PORT_1B,				//PEM Receive
		BAUDRATE_PEM
};

r_WCPorts WCPorts_rec = {			//Water Control Record
		on stdcore[0]:	XS1_PORT_1A,				//EC Pulse Input
		on stdcore[0]:	XS1_PORT_1D,				//EC Temperature i2c Clock
		on stdcore[0]:	XS1_PORT_1E,				//EC Temperature i2c Data
		1000,
		on stdcore[0]:	XS1_PORT_1H,				//Differential Pressure i2c Clock
		on stdcore[0]:	XS1_PORT_1I,				//Differential Pressure i2c Data
		1000,
		on stdcore[0]:  XS1_PORT_1K,				//Vavle 1
		on stdcore[0]:	XS1_PORT_1L,				//Vavle 2
		on stdcore[0]:	XS1_PORT_1M,				//Vavle 3
		on stdcore[0]:	XS1_PORT_1N,				//Vavle 4
		on stdcore[0]:	XS1_PORT_1O,				//Vavle 5
		on stdcore[0]:	XS1_PORT_1P,				//Vavle 6
		on stdcore[0]:	XS1_PORT_1J					//Pump 1
};
//TODO CHECK PORTS
r_LCPorts LCPorts_rec = {
	on stdcore[1]: XS1_PORT_1O,
	on stdcore[1]: XS1_PORT_1P
};

on stdcore[0]: out port enable_ports = XS1_PORT_8D; //Port controlling mux for SPI vs IO for XD0,1,10,11

//==============================================================================

/*---------------------------------------------------------------------------
	xSCOPE Constructors
 ---------------------------------------------------------------------------*/
void output_data_01(unsigned int value) {
	xscope_probe_data(0, value);
}
void output_data_02(unsigned int value) {
	xscope_probe_data(1, value);
}
void output_data_03(unsigned int value) {
	xscope_probe_data(2, value);
}
void output_data_04(unsigned int value) {
	xscope_probe_data(3, value);
}
void output_data_05(unsigned int value) {
	xscope_probe_data(4, value);
}
void output_data_06(unsigned int value) {
	xscope_probe_data(5, value);
}
void output_data_07(unsigned int value) {
	xscope_probe_data(6, value);
}
void output_data_08(unsigned int value) {
	xscope_probe_data(7, value);
}
void output_data_09(unsigned int value) {
	xscope_probe_data(8, value);
}
void output_data_10(unsigned int value) {
	xscope_probe_data(9, value);
}
void output_data_11(unsigned int value) {
	xscope_probe_data(10, value);
}

void topwait(int dtime){
	timer t;
	int time;
	t:>time;
	t when timerafter(time+dtime*100000000):>void;
}
//==============================================================================
void Top(chanend ACData_c, chanend ACCommand_c, chanend WCData_c, chanend WCCommand_c,chanend LCCommand_c){
	r_ACData ACData_rec;
	r_WCData WCData_rec;
	int mode=0;
	int datareq=1;
	int wcreq = 1;
	InitModUart(PEM_rec);

#ifdef __DUMMY
	printf("================================================================================\n");
	printf("                       THE SOFTWARE IS RUN ON DUMMY MODE                        \n");
	printf("================================================================================\n");
#endif
//XSCOPE.................................................................
	xscope_register(
			11,
			XSCOPE_CONTINUOUS, "Sensirion TEMP",XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "Sensirion RH", 	XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "Sensirion DEW", XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "Cozir TEMP", 	XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "Cozir RH", 		XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "Cozir CO2", 	XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "EC", 			XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "H1", 			XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "H2", 			XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "H3", 			XSCOPE_FLOAT, "Value",
			XSCOPE_CONTINUOUS, "H4", 			XSCOPE_FLOAT, "Value"
	);
//.......................................................................



//	Init data structs
	ACData_rec.SensTemp=0;
	ACData_rec.SensRH=0;
	ACData_rec.SensDew=0;
	ACData_rec.CozTemp=0;
	ACData_rec.CozRH=0;
	ACData_rec.CozCO2=0;
	WCData_rec.H1=0;
	WCData_rec.H2=0;
	WCData_rec.H3=0;
	WCData_rec.H4=0;
	WCData_rec.EC=0;
	delay(100000000);

	ACData_c <: 1;

	WCData_c <: 1;

	LCCommand_c <:1;

	LCCommand_c <: LEDS_OFF;
	ACCommand_c <: SERVOS_ON;


	while(1){
		LCCommand_c <: PLAY_CUSTOM;
//		printf("TOP: req data\n");
		for(int i=0; i<5;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		/////////////////////////////////////////
		//	WATER TEST
		////////////////////////////////////////

		WCCommand_c <: PUMP_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<20;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <: WATER_V_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<15;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <: WATER_V_OFF;
		WCCommand_c <: DRAIN_V_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<15;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <:	DRAIN_V_OFF;
		WCCommand_c <: NUTRIENT_V_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<10;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <: NUTRIENT_V_OFF;
		WCCommand_c <:	FERTIGATE_V_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<20;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <:	FERTIGATE_V_OFF;
		WCCommand_c <: WASTE_V_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<2;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		WCCommand_c <: WASTE_V_OFF;
		WCCommand_c <: PUMP_OFF;
//		printf("TOP: req data\n");
		for(int i=0; i<5;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		/////////////////////////////////////////
		//	AIR TEST
		////////////////////////////////////////

		ACCommand_c <: SERVOS_OFF;
		ACCommand_c <: FAN_ON_FULL;
//		printf("TOP: req data\n");
		for(int i=0; i<20;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		ACCommand_c <: FAN_ON_MIN;
		ACCommand_c <: CONDENSER_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<20;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		ACCommand_c <: CONDENSER_OFF;
		ACCommand_c <: FAN_ON_FULL;
		ACCommand_c <: HEATER_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<30;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		ACCommand_c <: HEATER_OFF;
		ACCommand_c <: SERVOS_ON;
//		printf("TOP: req data\n");
		for(int i=0; i<30;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		ACCommand_c <: SERVOS_OFF;
		ACCommand_c <: FAN_OFF;
//		printf("TOP: req data\n");
		for(int i=0; i<5;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		////////////////////////////////////////////
		//LIGHT TEST
		///////////////////////////////////////////

		LCCommand_c <: BLINK_BLUE;
//		printf("TOP: req data\n");
		for(int i=0; i<5;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

		LCCommand_c <: BLINK_RED;
//		printf("TOP: req data\n");
		for(int i=0; i<5;i++){
			ACData_c <: datareq;
			ACData_c :> ACData_rec;
			WCData_c <: datareq;
			WCData_c :> WCData_rec;
			PEM_data_struct(ACData_rec,WCData_rec,PEM_rec);
			XScopeOut(ACData_rec,WCData_rec);
			wait(1);
		}

	}
}
void XScopeOut(struct r_ACData &ACData_rec, struct r_WCData &WCData_rec){
	output_data_01(ACData_rec.SensTemp);
	output_data_02(ACData_rec.SensRH);
	output_data_03(ACData_rec.SensDew);
	output_data_04(ACData_rec.CozTemp);
	output_data_05(ACData_rec.CozRH);
	output_data_06(ACData_rec.CozCO2);
	output_data_07(WCData_rec.EC);
	output_data_08(WCData_rec.H1);
	output_data_09(WCData_rec.H2);
	output_data_10(WCData_rec.H3);
	output_data_11(WCData_rec.H4);
}

void PEM_data_struct(struct r_ACData &ACData_rec, struct r_WCData &WCData_rec, struct r_uart &PEM_rec){
	int i=0;
	char str[128];
	sprintf(str,"{\"I\":\"E82123456789ACxxx1\",\"S\":0,\"P\":{\"ST\":%.2f,\"SR\":%.2f,\"SD\":%.2f,\"CT\":%.2f,\"CH\":%.2f}}\n\0",ACData_rec.SensTemp, ACData_rec.SensRH, ACData_rec.SensDew, ACData_rec.CozTemp, ACData_rec.CozRH);
	while(1){
		uart_txByte(str[i],PEM_rec);
		i++;
		if(str[i] == '\0'){
			i=0;
			break;
		}
	}

	delay(1000000);

	sprintf(str,"{\"I\":\"E82123456789WCxxx1\",\"S\":0,\"P\":{\"EC\":%.2f,\"P1\":%.2f,\"P2\":%.2f,\"P3\":%.2f,\"P4\":%.2f}}\n\0",WCData_rec.EC, WCData_rec.H1, WCData_rec.H2, WCData_rec.H3, WCData_rec.H4);
	while(1){
		uart_txByte(str[i],PEM_rec);
		i++;
		if(str[i] == '\0'){
			i=0;
			break;
		}
	}
	delay(1000000);

//	printf("{\"I\":\"E82123456789WCxxx1\",\"S\":0,\"P\":{\"EC\":%.2f,\"P1\":%.2f,\"P2\":%.2f,\"P3\":%.2f,\"P4\":%.2f}}\n",WCData_rec.EC, WCData_rec.H1, WCData_rec.H2, WCData_rec.H3, WCData_rec.H4);
//	printf("{\"I\":\"E82123456789ACxxx1\",\"S\":0,\"P\":{\"ST\":%.2f,\"SR\":%.2f,\"SD\":%.2f,\"CT\":%.2f,\"CH\":%.2f}}\n",ACData_rec.SensTemp, ACData_rec.SensRH, ACData_rec.SensDew, ACData_rec.CozTemp, ACData_rec.CozRH);
//	printf("Sensirion-->\t Temp:%.2f\t RH: %.2f\t Dew: %.2f\n",ACData_rec.SensTemp,ACData_rec.SensRH,ACData_rec.SensDew);
//	printf("Cozir------>\t Temp:%.2f\t RH: %.2f\t CO2: %d\n",ACData_rec.CozTemp,ACData_rec.CozRH,ACData_rec.CozCO2);
//	printf("EC--------->\t EC:%.8f\n",WCData_rec.EC);
//	printf("dPw-------->\t MIX:%.2f\t NUT: %.2f\t DRAIN: %.2f\t WATER:%.2f\n",WCData_rec.H1,WCData_rec.H2,WCData_rec.H3,WCData_rec.H4);
}

//==============================================================================
/*
 * MAIN//
 */
void main(){
	chan ACData_c;
	chan WCData_c;
	chan dim_c;
	chan fan_c;
	chan lease_c;
	chan servo1_c;
	chan servo2_c;
	chan LCCommand_c;
	chan ACCommand_c;
	chan WCCommand_c;

	par{
		on stdcore[1]: Top(ACData_c, ACCommand_c, WCData_c,WCCommand_c,LCCommand_c);
		on stdcore[1]: appDimmer(dim_c);
		on stdcore[1]: appFan(fan_c);
		on stdcore[1]: appServo1(servo1_c);
		on stdcore[1]: appServo2(servo2_c);
		on stdcore[1]: appLightControl(LCCommand_c);
		on stdcore[1]: appAirControl(ACCommand_c, ACData_c,dim_c,fan_c,servo1_c,servo2_c);
		on stdcore[0]: appWaterControl(WCData_c,WCCommand_c);
	}
}
