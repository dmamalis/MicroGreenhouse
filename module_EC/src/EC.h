/*
 * EC.h
 *
 *  Created on: Jun 28, 2013
 *      Author: dimitris
 */

#ifndef EC_H_
#define EC_H_

#include <xs1.h>
#include <xccompat.h>
#include <platform.h>
#include <print.h>
#include "i2c.h"

//==============================================================================
#define PULSE_COUNT 						5
#define RREF1 								1000
#define RREF2								1000
											/*
											 *  Toff = N * K2 * Vo
											 * 		 = 1024 * 56 μs/V * 0,36 V =
											 * 		 = 20643,84μs
											 * 		 = 20.643.840
											 * 	Td+  = Toff/4 = 5.160.960ns
											 */
#define TOFFSET_PULSE 						1854980
#define POSSIBLE_VALUE_AFTER_TOV			32768	// Value chosen half the range of 16 bits
#define MIN_RAW_OHM							90
#define MAX_RAW_OHM                 		150000
#define CELL_CONSTANT						1.23 // 1.23 cm/cm^2

//==============================================================================


//==============================================================================
typedef struct r_EC{
    in port pulse;
    r_i2c i2cOne;
}r_EC;

void InitModEC(REFERENCE_PARAM(struct r_EC,EC));
float MeasureEC(struct r_EC &EC);
unsigned long CaptureEC(struct r_EC &EC);
int GetT(struct r_EC &EC);
float linearInterpolation(int adc_value);

#endif /* EC_H_ */
