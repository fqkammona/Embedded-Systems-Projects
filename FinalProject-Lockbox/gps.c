#include "GPS.h"

//  =========================================================
//  ||                       gps_init				 	   ||
//  =========================================================
void gps_init( void )
{
	USART_SEND( PMTK_SET_NMEA_UPDATE_10_SEC );
	USART_SEND( PMTK_SET_NMEA_OUTPUT_CUSTOM );
}



//  =========================================================
//  ||                      gps_parseHex			 	   ||
//  =========================================================
char gps_parseHex(char c)
{
	if ( c < '0' )
		return 0;
	if ( c <= '9' )
		return c - '0';
	if ( c < 'A' )
		return 0;
	if ( c <= 'F' )
		return ( c - 'A' ) + 10;
	return 0;
}



//  =========================================================
//  ||                   gps_parseChecksum				   ||
//  =========================================================
char gps_parseChecksum( char* checksum )
{
	char hex = 0;
	hex += 16 * gps_parseHex( checksum[0] );
	hex += gps_parseHex( checksum[1] );
	return hex;
}



//  =========================================================
//  ||                 gps_calcNMEAChecksum				   ||
//  =========================================================
char gps_calcNMEAChecksum( char* str )
{
	int len, sum, i;
	
	sum = 0;
	len = strlen( str );
	for ( i = 0; i < len - 4; i++ )
	sum ^= str[ i + 1 ];
	return sum;
}



//  =========================================================
//  ||                   gps_validateNMEA				   ||
//  =========================================================
int gps_validateNMEA( char* nmea )
{
	char targetChecksum = gps_parseChecksum( nmea + ( strlen(nmea) - 2 ) );
	if ( targetChecksum == gps_calcNMEAChecksum( nmea ) )
		return 1;
	return 0;
	
}



//  =========================================================
//  ||                    gps_parseNMEA				   ||
//  =========================================================
int gps_parseNMEA( char* nmea, struct GPS_Str_Data *gps )
{
	char *ptr, *nmeaStart;

	// Validate NMEA sentence header
	if ( ( nmeaStart = strstr ( nmea, "$GPGGA" ) ) == NULL )
		return 0;
	// validate Checksum
	if (!gps_validateNMEA( nmeaStart ) )
		return 0;
	
	// Separate the sentence by commas
	ptr = strtok ( nmeaStart, "," );

	// FastFwd to latitude
	ptr = strtok ( NULL, "," );
	ptr = strtok ( NULL, "," );
	strcpy( gps->latitude, ptr );

	// Latitude cardinal
	ptr = strtok ( NULL, "," );
	strcpy( gps->latCardinal, ptr );

	// Longitude
	ptr = strtok ( NULL, "," );
	strcpy( gps->longitude, ptr );

	// Longitude cardinal
	ptr = strtok ( NULL, "," );
	strcpy( gps->lonCardinal, ptr );
	
	// Fix
	ptr = strtok ( NULL, "," );
	strcpy( gps->fix, ptr );

	return 1;
}



//  =========================================================
//  ||                    gps_parseData					   ||
//  =========================================================
struct GPS_Data gps_parseData( struct GPS_Str_Data *strData )
{
	// Convert the struct of strings to a struct of integral types
	struct GPS_Data gpsData;
	
	// ===== Latitude =====
	gpsData.latitude = atof( strData->latitude );
	// Negate if Southern hempisphere
	if ( strData->latCardinal[0] == 'S' )
	gpsData.latitude *= -1;

	// Convert from NMEA Minute form to pure decimal
	gpsData.latitude =  gps_minsToDec( gpsData.latitude );

	// ===== Longitude =====
	gpsData.longitude = atof( strData->longitude );
	// Negate if Western hempisphere
	if ( strData->lonCardinal[0] == 'W' )
	gpsData.longitude *= -1;

	// Convert from NMEA Minute form to pure decimal
	gpsData.longitude =  gps_minsToDec( gpsData.longitude );

	gpsData.fix = atoi( strData->fix );

	return gpsData;
}



//  =========================================================
//  ||                    gps_getData 					   ||
//  =========================================================
int gps_getData( struct GPS_Str_Data *gpsData )
{
	// result will be summed with any successful NMEA parses
	int result = 0;
	
	char string[255];
	while ( USART_HAS_DATA )
	{
		USART_RECV( string, 255 );
		result += gps_parseNMEA( string, gpsData );
	}
	return result;
}



//  =========================================================
//  ||                    gps_minsToDec					   ||
//  =========================================================
// Convert the GPS lat/lon format from DDMM.MMMM to decimal
double gps_minsToDec(double coord)
{
	int degree = coord / 100;
	return (coord - degree * 100) / 60 + degree;
	
}