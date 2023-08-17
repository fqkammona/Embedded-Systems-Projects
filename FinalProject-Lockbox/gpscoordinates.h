/*
 * gpscoordinates.h
 *
 * Created: 4/24/2023 11:08:26 AM
 *  Author: fqkammona
 */ 

#ifndef GPSCOORDINATES_H_
#define GPSCOORDINATES_H_

float lat[3];
float lon[3];
void init_coords() {
	lat[0] = 41.66419332136861; // Chem
	lon[0] = -91.5366855468714;
	lat[1] = 41.6595744685326; // Seamans 
	lon[1] = -91.53670848734725;
	lat[2] = 41.66299999250464; // Imu 
	lon[2] = -91.53828284078881;
}


#endif /* GPSCOORDINATES_H_ */