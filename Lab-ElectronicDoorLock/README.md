## Introduction 
For this lab we are tasked with creating a simple electronic door lock system using a seven-segment LED display (5161AS), shift register (SN74HC595), rotary pulse generator (RPG-Panasonic EVE-GA1F2012B Encoder), pushbutton switch, and Arduino Uno (ATmega328p). We used a hardware debounce and Assembly language to program the microcontroller to satisfy all provided conditions. 

## Schematic 
The hardware approach for lab 3 was very similar to that of lab 2. Like lab 2, we use a SN74HC595 shift register and 5161AS seven-segment display. However, for this lab, we only use one of each and add an additional component: A rotary pulse generator (RPG). In order to connect the RPG to the microcontroller, we needed to implement a hardware debounce and current limiting resistors (10kΩ). For our hardware debounce we used 0.01μF capacitors and 10kΩ resistors. We connected the A channel to pin 7 on the Arduino which corresponds to port D. We connected the B channel to pin 6 on the Arduino which also corresponds to port D. To connect the button to the microcontroller, we followed the same procedure as lab 2 using a hardware debounce made up of two resistors (10kΩ and 100kΩ) and a 0.1μF capacitor to create a low pass filter. We connected the button to pin 8 which corresponds to pin 0 of port B. The seven-segment display is connected to the microcontroller the same way as in lab 2 with current limiting resistors (1kΩ) and pins A-DP connected to QA-QH on the shift register. 

## Discussion

|  Seven-Segment Display	 | |  |
| ------------ |----------------- | -------------------- |	
| | Start display with ‘-‘ | X | 
| | Increment display ‘0-F’	⮽| X | 
| |	Stop incrementing when F is reached	⮽| X | 
|	| Stop decrementing when is reached | X | 
| |	Decrement display ‘F-0’	| X | 
| |	Flash ‘.’ When the correct code is inputted	| X | 
| |	Flash ‘_’ when an incorrect code is inputted	| X | 

