#include "Cozir.h"
//==============================================================================
//Initialize COZIR
void InitModCOZIR(struct r_uart &COZIR) {
	COZIR.RXD :> void;
	COZIR.TXD :> void;
}

int COZIR_getReply(struct r_uart &COZIR){
	int i,ret;
	unsigned char str[9];
	unsigned char result[3];
	unsigned char c=0;
	for(i = 0; i < 9; i++){
		str[i] = uart_rxByte(COZIR);
		if(str[i]=='\n'){
			break;
		}
	}
	result[0]=str[5];
	result[1]=str[6];
	result[2]=str[7];
	ret=atoi(result);
	return ret;
}

int COZIR_getTemp(struct r_uart &COZIR){
	char command[3]="T\r\n";
	unsigned char str[10];
	char result[4];
	int ret;
	int i;
	for(int i=0; i<3;i++){
		uart_txByte(command[i],COZIR);
	}
	return COZIR_getReply(COZIR);
}

int COZIR_getRH(struct r_uart &COZIR){
	char command[3]="H\r\n";
	for(int i=0; i<3;i++){
		uart_txByte(command[i],COZIR);
	}
	return COZIR_getReply(COZIR);
}

int COZIR_getCO2(struct r_uart &COZIR){
	char command[3]="Z\r\n";
	for(int i=0; i<3;i++){
		uart_txByte(command[i],COZIR);
	}
	return COZIR_getReply(COZIR);
}

void COZIR_setMode(char mode, struct r_uart &COZIR){
	char command[5]="K 0\r\n";
	command[2]=mode;
	for(int i=0; i<5;i++){
		uart_txByte(command[i],COZIR);
	}
	//getReply();
}

void COZIR_callibrateCO2(struct r_uart &COZIR){
	char zeroCO2[7]="X 400\r\n";
	for(int i=0; i<7;i++){
		uart_txByte(zeroCO2[i],COZIR);
	}
}
