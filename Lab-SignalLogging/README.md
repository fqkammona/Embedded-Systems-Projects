## Introduction 
The objective of this lab was to gain some experience with C-based programming of AVR microcontrollers, serial interface protocols (I2C, RS232,..), ADC, and DAC. In this lab, I built a remotely controllable analog signal measurement and generation system using the built-in A/D converter of the ATmega328P controller and the MAX518. The MAX518 is an external two channel digital to analog converter with an I2C interface, which allows communication between multiple devices. 

My microcontroller has an RS232 interface that is connected to my computer, allowing me to be able to trigger analog voltage measurements and set the output voltage for both channel 1 and channel 0 of the DAC. The system implements two commands, ‘G’ and ‘S’, that will be input into the Arduino’s serial monitor. The ‘G’ command gets a single voltage measurement from ADC and the ‘S’ command allows the user to set DAC output voltage on channels 0 and 1.

## Schematic 
The figure below shows the connections between the microcontroller and the MAX518. As shown in the schematic I used two pull-up resistors that were 4.7k ohms. 

![Schematic](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/6d616839-c68a-446e-97c9-d7879c7093a0)

Figure One: Microcontroller and MAX518 connections

## Discussion 
For the code, I decided to use the USART, Universal Synchronous and Asynchronous serial Receiver and Transmitter, which is a highly flexible serial communication device. Using USART allowed me to transmit and receive bytes from the input or output register. To do so I needed to calculate the baud rate and UBRR, UART baud rate register, which I did using the formulas found in table one. UBRR is used to set USART, allowing me to generate transmission at a specified speed. Once UART has been initialized it can now perform reading and writing tasks. Using the ATMega328P datasheet and figure two, which also comes from the datasheet, we can see the TxB is the transmit data buffer register and RxB is the receive data buffer register. Both buffers share the same input-output address, which is referred to as UDR (USART data request).

| Equation for calculating Baud Rate | BAUD = Fclk / (16 * (UBR + 1)) |
| ---------- | -------------------- |
| Equation for Calculating UBR Value  | UBR = (Fclk / (BAUD * 16)) - 1 |
