#ifndef GPS_H
#define GPS_H

#include <string.h>
#include <stdlib.h>
#include <stdint.h>

/* ========= User-defined USART Function ======== 

	Note: This must be customized to use your USART library of choice
	The USART_SEND function expects a null-terminated string as the argument.
	The USART_RECV returns the received data form the USART data register. 
*/
 
#include "USART.h"
#define USART_SEND printString
#define USART_RECV readString

/* ========== Baud rate ========== */
#define PMTK_SET_NMEA_BAUD_4800 "$PMTK251,4800*14"
#define PMTK_SET_NMEA_BAUD_9600 "$PMTK251,9600*17"
#define PMTK_SET_NMEA_BAUD_57600 "$PMTK251,57600*2C"

/* ========== Update rate ========== */
#define PMTK_SET_NMEA_UPDATE_10_SEC  "$PMTK220,10000*2F" // Every 10 seconds 
#define PMTK_SET_NMEA_UPDATE_5_SEC  "$PMTK220,5000*1B"  // Every 5 seconds
#define PMTK_SET_NMEA_UPDATE_1_SEC  "$PMTK220,1000*1F" // Every second

/* ========== System ========== */
#define PMTK_CMD_HOT_START "$PMTK101*32" // Reboot
#define PMTK_CMD_STANDBY_MODE "$PMTK161,0*28" // Standby


/* ========== Output format ========== */
/* Enable Recommended Minimum Sentence and GPS Fix data ( RMC and GGA )*/
#define PMTK_SET_NMEA_OUTPUT_RMCGGA "$PMTK314,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*28"
#define PMTK_SET_NMEA_OUTPUT_RMCONLY "$PMTK314,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0*29"
#define PMTK_SET_NMEA_OUTPUT_CUSTOM "$PMTK314,1,1,1,1,1,5,0,0,0,0,0,0,0,0,0,0,0,0,0*2C" 

#define DEG_PER_MIN .016666667f
struct GPS_Str_Data
{
	char latitude[16];
	char longitude[16];
	char latCardinal[2];
	char lonCardinal[2];	
	char fix[2];
	
};

struct GPS_Data
{
	float latitude;
	float longitude;
	int fix;
};

void gps_init( void );
char gps_parseHex(char c);
char gps_parseChecksum( char* checksum );
char gps_calcNMEAChecksum( char* str );
int gps_validateNMEA( char* nmea );
int gps_parseNMEA( char* nmea, struct GPS_Str_Data *gps );
struct GPS_Data gps_parseData( struct GPS_Str_Data *strData );
int gps_getData( struct GPS_Str_Data *gpsData );
double gps_minsToDec(double coord);

#endif

