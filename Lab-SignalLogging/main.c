/*
 * Lab5Again.c
 *
 * Created: 4/11/2023 3:19:18 PM
 * Author : fqkammona
 */ 

/* USART Initialization */

// fclk / (16 * BAUD) - 1
// Fclk = 16000000 Clock Speed 
#define F_CPU 16000000UL		//Clock Frequency = 16000000 Hz  
#define UART_BAUD 9600			// Baud Rate (in bits per second, bps) - Symbol Rate 
#define __DELAY_BACKWARD_COMPATIBLE__

#define DAC_ADDRESS	0b01011000 // found from MAX517-MAX519 datasheet  page 9

#include <ctype.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <avr/io.h>
#include <util/delay.h>
#include <util/twi.h>

#include "i2cmaster.h"

int uart_putchar(char, FILE*);
int uart_getchar(FILE*);

// set up FILE STREAM
// link: https://www.nongnu.org/avr-libc/user-manual/group__avr__stdio.html
static FILE uart_io = FDEV_SETUP_STREAM(uart_putchar, uart_getchar, _FDEV_SETUP_RW);

static uint8_t sin_table[] = {128,141,153,165,177,188,199,209,219,227,234,241,246,250,254,255,255,255,254,250,246,241,234,227,219,209,199,188,177,165,153,141,128,115,103,91,79,68,57,47,37,29,22,15,10,6,2,1,0,1,2,6,10,15,22,29,37,47,57,68,79,91,103,115};


static float read_adc(uint8_t pin){
	ADMUX = (ADMUX & 0xf0) | pin;		    // DS 24.9.1, Table 24-4
	ADCSRA |= 1<<ADSC;						//  The first conversion must be started by writing a logical one to the ADSC bit in ADCSRA
	
	/* 24.4 Prescaling and Conversion Timing 
	When initiating a single ended conversion by setting the ADSC bit in ADCSRA, the conversion starts at the
	following rising edge of the ADC clock cycle. */
											
	while(!(ADCSRA & (1<< ADIF)));			//wait for conversion
	
	/* 24.4 Prescaling and Conversion Timing */ 
	/*When a conversion is complete, the result is written to the
	ADC Data Registers, and ADIF is set. In Single Conversion mode, ADSC is cleared simultaneously. The
	software may then set ADSC again, and a new conversion will be initiated on the first rising ADC clock edge.*/
	
	ADCSRA |= 1 << ADIF;					// clear interrupt flag
	
	return 5.0f * (ADCL + (ADCH << 8)) / 1023.0f;
	
	/* The ADC generates a 10-bit result which is presented in the ADC Data Registers, ADCH and ADCL. */ 
}

/* 20.6.1 Sending Frames with 5 to 8 Data Bit */
int uart_putchar(char c, FILE *s){
	if (c == '\n')						//CRLF insertion
		uart_putchar('\r', s);
	
	while (!(UCSR0A & (1 << UDRE0)));		/* Wait for empty transmit buffer */
	UDR0 = c;							/* Put data into buffer, sends the data */
	
	return 0;
}

/* 20.7.1  Receiving Frames with 5 to 8 Data Bits */
int uart_getchar(FILE *s) {
	while(!(UCSR0A & (1<< RXC0)));		/* Wait for data to be received */
	uint8_t c = UDR0; 					/* Get and return received data from buffer */
	return c;
}

void send_dac_voltage(uint8_t chan, uint8_t v) {
	i2c_start(DAC_ADDRESS | I2C_WRITE);     // set device address and write mode
	i2c_write(chan);						// MAX518 DS, Figure 7 - LSB = channel
	i2c_write(v);							// Write the voltage
	i2c_stop();
}

int main(){
	stdout = stdin = &uart_io;			//enables printf

	i2c_init();                         // initialize I2C library
	
	//ADC setup
	ADMUX |= 0b01 << REFS0;
	ADCSRA = 1 << ADEN | 0b110 << ADPS0;
	
	UCSR0A = 1 << U2X0;
	UBRR0L = (F_CPU / (8UL * UART_BAUD))-1;
	UCSR0B = 1 << TXEN0 | 1 << RXEN0;
	
	char buf[32];
	while (1) {
		if (fgets(buf, 32, stdin) == NULL)
			break;
		printf("%s", buf);
		
		if(buf[0] == 'S'){
			uint8_t channel = -1;
			float voltage = -1.0f;

			int n = sscanf(buf, "%*c,%hhd,%f\n", &channel, &voltage);
			if (channel != 0 && channel != 1)
				printf("channel must be 0 or 1\n");
			else if (voltage <= 0.0f || voltage >= 5.0f)
				printf("voltage must be between 0.000 and 5.000\n");
			else {
				uint8_t v = 51 * voltage;
				printf("DAC channel %hhd set to %.3f V (%hhdd)\n", channel, voltage, v);
			
				send_dac_voltage(channel, v);
			}
		} else if (buf[0] == 'G') {
			printf("v=%.3f V\n", read_adc(0));
		} else if (buf[0] == 'W') {
			uint8_t channel, freq, cycles;
			sscanf(buf, "%*c,%hhd,%hhd,%hhd", &channel, &freq, &cycles);
			
			printf("Generating %hhd sine wave cycles with f=%hhd Hz on DAC channel %hhd",
				cycles, freq, channel);
			
			double dt = 880000.0 / 64.0 / freq;
			
			for (int i = 0; i < cycles; ++i) {
				for (int j = 0; j < 64; ++j) {
					send_dac_voltage(channel, sin_table[j]);
					_delay_us(dt);
				}
			}
		}
	}
}

/* sscanf
 *   https://www.nongnu.org/avr-libc/user-manual/group__avr__stdio.html#ga67bae1ad3af79809fd770be392f90e21
 */

