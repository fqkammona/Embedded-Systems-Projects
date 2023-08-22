## Introduction 
The objective of this lab was to gain some experience with C-based programming of AVR microcontrollers, serial interface protocols (I2C, RS232,..), ADC, and DAC. In this lab, I built a remotely controllable analog signal measurement and generation system using the built-in A/D converter of the ATmega328P controller and the MAX518. The MAX518 is an external two channel digital to analog converter with an I2C interface, which allows communication between multiple devices. 

My microcontroller has an RS232 interface that is connected to my computer, allowing me to be able to trigger analog voltage measurements and set the output voltage for both channel 1 and channel 0 of the DAC. The system implements two commands, ‘G’ and ‘S’, that will be input into the Arduino’s serial monitor. The ‘G’ command gets a single voltage measurement from ADC and the ‘S’ command allows the user to set DAC output voltage on channels 0 and 1.

## Schematic 
The figure below shows the connections between the microcontroller and the MAX518. As shown in the schematic I used two pull-up resistors that were 4.7k ohms. 

![Lab-SignalLogging-Figure1-Schematic.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-SignalLogging-Figure1-Schematic.png)


Figure One: Microcontroller and MAX518 connections

## Discussion 
For the code, I decided to use the USART, Universal Synchronous and Asynchronous serial Receiver and Transmitter, which is a highly flexible serial communication device. Using USART allowed me to transmit and receive bytes from the input or output register. To do so I needed to calculate the baud rate and UBRR, UART baud rate register, which I did using the formulas found in table one. UBRR is used to set USART, allowing me to generate transmission at a specified speed. Once UART has been initialized it can now perform reading and writing tasks. Using the ATMega328P datasheet and figure two, which also comes from the datasheet, we can see the TxB is the transmit data buffer register and RxB is the receive data buffer register. Both buffers share the same input-output address, which is referred to as UDR (USART data request).

| Equation for calculating Baud Rate | BAUD = Fclk / (16 * (UBR + 1)) |
| ---------- | -------------------- |
| Equation for Calculating UBR Value  | UBR = (Fclk / (BAUD * 16)) - 1 |

![Lab-SignalLogging-Figure2-USART-block-diagram.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-SignalLogging-Figure2-USART-block-diagram.png)

Figure Two: USART block diagram

Using the library stdio.h I was able to implement the macro FDEV_SETUP_STREAM which allows a user-supplied file buffer and all data initialization to happen during start-up. In the miscellaneous section under the AVR/GNU linker in toolchain I added the flags: -Wl,-u,vfprintf -Wl,-u,vfscanf -lprintf_flt -lscanf_flt, which in addition to the library allowed me to use printf which I enable at the start of main. Other libraries not mentioned can be found below in table two. 

Once all the initializations have been established, I was able to move on to working on the different commands. The G command uses the read_adc function, which converts the analog voltage to a digital signal and returns the number as a float. To do the conversion ADCRA is used, after writing a logical one to the ADSC bit in ADCSRA the conversion starts at the following rising edge of the ADC clock cycle. The conversion continues happening until ADIF is set and once it is the ADSC is cleared simultaneously. When the conversion is complete, a 10-bit result is stored in the ADC data registers, ADCH and ADCL. Once the data registers are filled the number is multiplied by 5 and then divided by 1023. 

The other command that the system implements is the S command, which sets the DAC output voltages. I used a char array called buf and function sscanf to break apart the input string and get the desired channel and voltage given. Using a set of if else statements I was able to verify that the input given meets the requirements. Those being that the channel had to be either 0 or 1 and the voltage needed to be between 0 and 5 volts. For this command I utilized the I2C master library and the twimaster both by Peter Fleury. Fleury recommends using resistor values of 4.7K ohms which as stated before in the schematic section is what I used. Doing so allowed me to use the I2C commands and functions. To define the DAC address I used the MAX517-MAX519 datasheet. 

| Library | Function |
| ------- | -------- |
| ctype.h	| Functions that perform various operations on characters. |
| stdint.h | This header defines a set of integral type aliases with specific width requirements, along with macros specifying their limits and macro functions to create values of these types. |
| stdio.h |	Allows the use of the standard streams stdin, stdout, and stderr and several macros such as fdev_setup_stream(), and different functions for performing input and output. |
| string.h | The string functions perform string operations on NULL-terminated strings.|
| math.h | Declares basic mathematics constants and functions. |
| avr/io.h | This header file includes the appropriate IO definitions for the device | 
| util.delay.h | Convenience functions for busy-wait delay loops |
| util/twi.h	| Contains bit mask definitions for use with the AVR TWI interface |
| i2master.h	| Basic routines for communicating with I2C slave devices. |

## Conclusion 
From this lab, I gained experience with C-based programming of AVR microcontrollers, serial interface protocols (I2C, RS232,..), ADC, and DAC. I was able to build a remotely controllable analog signal measurement and generation system using the built-in A/D converter of the ATmega328P controller and the MAX518. I utilized USART to facilitate communication through the computer’s serial port using RS-232C protocol and I was able to use the I2Cmaster library to create communication between the microcontroller and the MAC518 digital-to-analog converter. 



