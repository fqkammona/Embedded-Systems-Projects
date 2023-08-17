/*
 * FinalProject.c
 *
 * Created: 4/15/2023 7:20:28 AM
 * Author : fqkammona
 */ 

#include "config.h"

#include <ctype.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#include "lcd.h"
#include "gps.h"
#include "gpscoordinates.h"

int menu_index = 0;	// Index to menu options 
char *menu_options[] = {"Chem","Seamans", "Imu"};

int int0_called_count = 0;	

static volatile uint8_t rpg_history = 0;
static volatile uint8_t button_history = 0;

/* Different Display options */ 
static volatile enum state_t {
	WELCOME, 
	COORDINATES,
	GO,
	CURRENT_COORDINATES
} state = WELCOME; // Start at Welcome State 
static volatile bool refresh_requested = false; // Indicates that the rpg has changed and the welcome menu needs to be updated 

/* Do all initializations at start up */
static void startup_initializations(void){
	lcd_init();
	init_coords(); 
	gps_init();
}

static FILE lcd_io = FDEV_SETUP_STREAM(lcd_putchar, NULL, _FDEV_SETUP_WRITE);

void rpg_left_handler() {
	if (menu_index > 0) {
		--menu_index;
		refresh_requested = true;
	}
}

void rpg_right_handler() {
	if (menu_index < 2) {
		++menu_index;
		refresh_requested = true;
	}
}

void rpg_changed() {
	/* Shift over by 3 so that its in the least significant bit  */
	uint8_t current_state = (PINB & (1 << PINB3 | 1 << PINB4)) >> 3;
	// return if nothing has actually changed
	if (current_state == (rpg_history & 0b11))
		return;
		
	// RPG only works on WELCOME state 	
	if (state != WELCOME)
		return;	

	rpg_history = (rpg_history << 2) | current_state;
	switch (rpg_history) {
	case 0b01001011: // CCW turn
		rpg_left_handler();
		break;
	case 0b10000111: // CW turn 
		rpg_right_handler();
		break;
	}
}

/* Function for when the button is press*/ 
void button_pressed() {
	/* Shift by 5 to be in the least significant bit */
	uint8_t current_state = (PINB & (1 << PINB5)) >> 5;
	if (current_state == button_history)
		return;

	button_history = current_state;
	if (!current_state) /* button is still pressed*/
		return;
	
	++int0_called_count;
	switch (state) {
	case WELCOME:
		state = COORDINATES;
		break;
	case COORDINATES:
		state = GO;
		break;
	case GO:
		state = CURRENT_COORDINATES;
		break;
	case CURRENT_COORDINATES:
		state = WELCOME;
		break;
	}
}

ISR(PCINT0_vect) {
	rpg_changed();
	button_pressed();
}

/* Different display options */
void display_menu_options() {
	printf("Push button to\nselect: %s\n", menu_options[menu_index]);
}

void display_distination_lat_lon() {
	printf("LAT: %f\nLON: %f\n", lat[menu_index], lon[menu_index]);
}

void display_go() {
	printf("Push button to\nstart: \n");
}

void display_current_lat_lon() {
	//while( 1 )
	//{			
		struct GPS_Str_Data gpsRawData; // Data in string form
		struct GPS_Data gpsData; // Converted data

		// Get the string data from GPS
		gps_getData( &gpsRawData );

		// Parse string data into ints and floats
		gpsData = gps_parseData( &gpsRawData );

		// If GPS has a signal fix
		//if ( gpsData.fix )
		//{
			/* Here you are now free to use the following available data from the GPS.
			gpsData.fix (int) - 1 if has fix, otherwise zero
			gpsData.latitude (float) - latitude in decimal format, not NMEA Minutes format
			gpsData.longitude (float) - longitude in decimal format, not NMEA Minutes format */
			//printf("LAT: %f\nLON: %f\n", gpsData.latitude, gpsData.longitude);
			
			if(gpsData.fix == 0){
				printf("FIX: %d\n\n", gpsData.fix);
			} else {
				printf("Error \n\n");
			}
		//}
		//else
		//{
			//
			//// This is area executes when the GPS has not yet acquired, or has lost signal fix.
			//printf("Error \n");
		//}

		//_delay_ms(1000); // Wait one second
	//}
}

/******************************* Main Code *************************/
int main(void)
{
	startup_initializations();
	stdout = &lcd_io;
	
	/* DDRB &= ~(1 << DDB5); 
	1 << DDB5 == evaluates to the binary value 0b00100000 (i.e., 1 shifted left by 5 bits).
	 ~(1 << DDB5) == performs a bitwise NOT operation on the binary value 0b00100000, resulting in the binary value 0b11011111. 
	 This binary value is then used to clear the 5th bit of the DDRB register.
	  &= ~(1 << DDB5) == operator performs a bitwise AND operation between the original value of the DDRB register and the binary value 0b11011111. 
	  This clears the 5th bit of the DDRB register while leaving the other bits unchanged.
	*/
	
	// DDB5 = Button 
	// DDB3 and DDB4 = RPG 
	
	/* Setting up Interrupts*/ 
	DDRB &= ~(1 << DDB3 | 1 << DDB4 | 1 << DDB5);				// Pins B3 and B4 set as input
	
	// 13.2.4 PCICR – Pin Change Interrupt Control Register
	// Bit 0 – PCIE0: Pin Change Interrupt Enable 0
	/* When the PCIE0 bit is set (one) and the I-bit in the Status Register (SREG) is set (one), pin change interrupt 0 is
	enabled. Any change on any enabled PCINT[7:0] pin will cause an interrupt. The corresponding interrupt of Pin
	Change Interrupt Request is executed from the PCI0 Interrupt Vector. PCINT[7:0] pins are enabled individually
	by the PCMSK0 Register */ 
	
	PCICR |= 1 << PCIE0;
	
	// 13.2.8  PCMSK0 – Pin Change Mask Register 0
	/* Each PCINT[7:0] bit selects whether pin change interrupt is enabled on the corresponding I/O pin. If PCINT[7:0]
	is set and the PCIE0 bit in PCICR is set, pin change interrupt is enabled on the corresponding I/O pin. If
	PCINT[7:0] is cleared, pin change interrupt on the corresponding I/O pin is disabled */ 
	PCMSK0 |= (1 << PCINT3 | 1 << PCINT4 | 1 << PCINT5);

	sei();											// Enable Global interrupts
	
	enum state_t prev_state = state;
    while (1) {
		switch (state) {
		case WELCOME:
			display_menu_options();
			break;
		case COORDINATES:
			display_distination_lat_lon();
			break;
		case GO:
			display_go();
			break;
		case CURRENT_COORDINATES:
			display_current_lat_lon();
			break; 
		}
		
		while (prev_state == state && !refresh_requested)
			_delay_ms(10);

		prev_state = state;
		refresh_requested = false;
	}
    return 0;
}
/******************************* End of Main  Code ******************/
