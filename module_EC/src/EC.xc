#include <platform.h>
#include <xs1.h>
#include <stdio.h>
#include "EC.h"


//Initialize EC
void InitModEC(struct r_EC &EC) {
	EC.pulse :> void;
}

//==============================================================================
float linearInterpolation(int adc_value)
{
	short int TEMPERATURE_LUT[][2]= //Temperature Look up table
	{
			{-35,1100},
			{-10,850},
			{55,230},
			{60,210},
			{65,190},
			{70,170},
			{75,150},
			{80,130},
			{85,110}
	};
	short int i=0;
	float x1,y1,x2,y2,temper;
	while(adc_value<TEMPERATURE_LUT[i][1]){
		i++;
	}
	//Calculating Linear interpolation using the formula y=y1+(x-x1)*(y2-y1)/(x2-x1)
	x1=TEMPERATURE_LUT[i-1][1];
	y1=TEMPERATURE_LUT[i-1][0];
	x2=TEMPERATURE_LUT[i][1];
	y2=TEMPERATURE_LUT[i][0];
	temper=y1+(((adc_value-x1)*(y2-y1))/(x2-x1));
	return temper;
}

//==============================================================================
int GetT(struct r_EC &EC){
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

	unsigned char i2c_register[1]={0x2B};
	unsigned char i2c_register1[2];
	int adc_value;
//TODO move configuration of i2c higher
	//::Config start
	i2c_master_write_reg(0x28, 0x00, i2c_register, 1, EC.i2cOne);

	//Read value from ADC
	i2c_master_rx(0x28, i2c_register1, 2, EC.i2cOne);
	i2c_register1[0]=i2c_register1[0]&0x0F;
	adc_value=(i2c_register1[0]<<6)|(i2c_register1[1]>>2);
	return adc_value;
}//GetTwaterMeasured

//==============================================================================
/** Get the measurement.
    @retval 0   The raw measured EC (resistance) or reference voltage failed.
    @retval 1   The raw measured EC (resistance) and reference voltage are both ok.
*/
unsigned long CaptureEC(struct r_EC &EC){
	float fRawOhm;
	unsigned long long  ullTeller, ullNoemer;
	unsigned long ulLatestPulseLength[PULSE_COUNT], ulToff, ulTab, ulTcd;
	float fRawMeasuredEc, fWaterTemperature, fTemperatureCorrectedEc;
	double gRawEc_mS,gCompensateEc_mS;
	int start, end, width;
	short index=0;
	short x=0;
	/*
	 *Capturing pulses (Timestamping on positive and negative edge measures positive pulse width.
	 * Can easily be changed to timestamping two positive edges thus measuring pulse width
	 */
	while (index < 5){
		timer t;
		EC.pulse when pinseq(0):> void;
		EC.pulse when pinseq(1):> void; 	//timestamp rising edge
		t :> start;
		EC.pulse when pinseq(0):> void;  	//timestamp falling edge
		t:>end;
		width = end-start;
		ulLatestPulseLength[index]= 2*width;

		//Synchornization Point
		//TODO a check on the time it takes t synch will cover the case of disconnected sensor
		if((index == 1) && ((ulLatestPulseLength[0] > TOFFSET_PULSE) || (ulLatestPulseLength[1] > TOFFSET_PULSE))) {
			index = 0;
			x= !x;
			//test0 <: x;
			ulLatestPulseLength[0] = ulLatestPulseLength[1];
		}

		index = index + 1;

		if(index > 4){
			ulToff = (ulLatestPulseLength[0]+ulLatestPulseLength[1]);
			ulTab = ulLatestPulseLength[2];
			ulTcd = ulLatestPulseLength[3];
			ullTeller = ((unsigned long long)(ulTcd - ulToff) * RREF1 * RREF2);
			ullNoemer = ((unsigned long long)(ulTab - ulToff) * RREF2) - ((unsigned long long)(ulTcd - ulToff) * RREF1);
			//Check division by zero.
			if (!ullNoemer ){
				printstrln("ERROR: EC: Division by zero");
			}
			fRawOhm = (float)((float)ullTeller / (float)ullNoemer);
			//Check raw resistance value.
			if (( fRawOhm < MIN_RAW_OHM ) || ( fRawOhm > MAX_RAW_OHM )){
				printstrln("ERROR: EC: Restistance value out of bounds");
				return 0;
			}
			return fRawOhm;
		}
	}
}//GetMeasurement

//==============================================================================
float MeasureEC(struct r_EC &EC){
	float           fRawMeasuredEc, fWaterTemperature, fTemperatureCorrectedEc;
	double          gRawEc_mS, gCompensateEc_mS;
	unsigned long   ulNewOperationMode, ulNewOperationState, ulNewCause, ulTwaterOperationMode;
	unsigned short  usNewReliability;
	float fRawOhm;
	// Get the measurement.
	fRawOhm = CaptureEC(EC);

	//Calculate condutivity in mS
	gRawEc_mS = 1000 / fRawOhm;
    // Compensate for a-linearity and input capacitance.
    gCompensateEc_mS = (0.0003 * gRawEc_mS * gRawEc_mS) + (0.9946 * gRawEc_mS) - 0.004;
    // Calculate raw measured EC in S.
    fRawMeasuredEc = (gCompensateEc_mS * CELL_CONSTANT) / 1000;
    // Get measured water temperature and convert it to degrees celcius.
    fWaterTemperature =linearInterpolation(GetT(EC));
    // Calculate temperature corrected measured EC.
    fTemperatureCorrectedEc = fRawMeasuredEc * (1 - (fWaterTemperature - 25.0) / 50.0);
    return fTemperatureCorrectedEc;
}//Handle_Ec_Measurement

