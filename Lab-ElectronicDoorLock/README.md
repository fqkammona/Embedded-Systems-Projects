## Introduction 
For this lab we are tasked with creating a simple electronic door lock system using a seven-segment LED display (5161AS), shift register (SN74HC595), rotary pulse generator (RPG-Panasonic EVE-GA1F2012B Encoder), pushbutton switch, and Arduino Uno (ATmega328p). We used a hardware debounce and Assembly language to program the microcontroller to satisfy all provided conditions. 

## Schematic 
![Lab-ElectronicDoorLock-Figure%201-Schematic.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-ElectronicDoorLock-Figure%201-Schematic.png)


Figure 1: Lab 3 Circuit Diagram

The hardware approach for lab 3 was very similar to that of lab 2. Like lab 2, we use a SN74HC595 shift register and 5161AS seven-segment display. However, for this lab, we only use one of each and add an additional component: A rotary pulse generator (RPG). In order to connect the RPG to the microcontroller, we needed to implement a hardware debounce and current limiting resistors (10kΩ). For our hardware debounce we used 0.01μF capacitors and 10kΩ resistors. We connected the A channel to pin 7 on the Arduino which corresponds to port D. We connected the B channel to pin 6 on the Arduino which also corresponds to port D. To connect the button to the microcontroller, we followed the same procedure as lab 2 using a hardware debounce made up of two resistors (10kΩ and 100kΩ) and a 0.1μF capacitor to create a low pass filter. We connected the button to pin 8 which corresponds to pin 0 of port B. The seven-segment display is connected to the microcontroller the same way as in lab 2 with current limiting resistors (1kΩ) and pins A-DP connected to QA-QH on the shift register. 

## Discussion

|  Seven-Segment Display	 | | |
| ------------ |----------------- | -------------------- |	
| | Start display with ‘-‘ | X | 
| | Increment display ‘0-F’ | X | 
| |	Stop incrementing when F is reached	| X | 
|	| Stop decrementing when is reached | X | 
| |	Decrement display ‘F-0’	| X | 
| |	Flash ‘.’ When the correct code is inputted	| X | 
| |	Flash ‘_’ when an incorrect code is inputted | X | 
|	| Display ‘-‘ when reset | X | 
| Rotary Pulse Generator  | | |
|	| Send an accurate signal for a clockwise turn | X | 
|	| Send an accurate signal for a counterclockwise turn	| X | 
| Pushbutton	| | | 
| | Save value on display to test for accuracy of code when pressed for less than one second | X | 
| |	Reset saved code when pressed for more than one second | X | 
| Hardware Debounce		
|	| Accurately detect when the button is pressed | X | ⮽
| |	Accurately detect when RPG is turned | X | 
| Timer	| | |	
| |	100ms delay	| X | 
| Display Routine	| | |	
| |	Display Routine	| X | 

FIGURE 2 lists the specifications our lab was required to meet, broken into sections by component.

### Seven-Segment Display
The seven-segment display oversees displaying characters 0-9, then A-F, for 16 characters in total. The display is connected to the microcontroller with current limiting resistors calculated using Ohm’s law and the information given in the datasheet. It is listed in the datasheet that the seven-segment LED displays can withstand a maximum current of 30mA. Our target current is 5mA. Using VCC as 5V we can calculate the correct resistance using Ohm’s law:
`V=IR`
`5V=(5mA)*R`
`R ≅ 1000Ω`

This provides the seven-segment display with enough current to light while staying away from the maximum. To change the display, we used many different registers and routines to compare values and determine what needs to be displayed. We used three different registers in order to accomplish this. One to keep track of what array element to display, one to display the character, and one to set the starting value. The first thing we do in our main program is jump to a reset routine. This routine loads a register with the value needed to display a dash and turns off the LED on the Arduino. It also resets the counter for the display to -1 and resets the number of characters that have been entered as well as clears the T flag in the status register. After the reset, our program enters a state routine to evaluate what the microcontroller is reading from the RPG. We read in all the bits from port D and look specifically at the first two bits. These two bits are connected to the RPG channels. We put these bits into two separate registers and compare them. If the two bits are the same, then no state change has occurred, and our program returns to the main program to check for a button press. If no button press has occurred then we again check if the state has changed. If a state change has been detected, we then determine what kind of change has occurred. If the state change is clockwise, we compare the value of the register keeping track of the array element to F. If the character is an F, then we branch to another routine to find the correct array element and to display that array element. If the character is not F, then we increment the register for the array counter. If the state change is counterclockwise, we enter a similar routine to check if the value is 0. If the value is zero, then we branch to a routine to display 0 once again. If its not zero then we decrement the counter. Figure 4 shows the truth table to calculate what hex value will display what character. 

| # | DP | G | F | E | D | C | B | A | Hex |
| - | -- | - | - | - | - | - | - | - | --- |
| 0 |	0  | 0 | 1 | 1 | 1 | 1 | 1 | 1 | 0X3F|
| 1 |	0  | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 0X06|
| 2 | 0  | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 0X5B|
| 3	| 0	 | 1 | 0 | 0 | 1 | 1 | 1 | 1 | 0X4F|
| 4	| 0	 | 1 | 1 | 0 | 0 | 1 | 1 | 0 | 0X66|
| 5	| 0	 | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 0X6D|
| 6	| 0	 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 0X7D|
| 7 |	0	 | 0 | 0 | 0 | 0 | 1 | 1 | 1 | 0X07|
| 8	| 0  | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0X7F|
| 9	| 0  | 1 | 1 | 0 | 1 | 1 | 1 | 1 | 0X6F| 
| A	| 0	 | 1 | 1 | 1 | 0 | 1 | 1 | 1 | 0X77|
| b	| 0	 | 1 | 1 | 1 | 1 | 1 | 0 | 0 | 0X7C|
| C | 0  | 0 | 1 | 1 | 1 | 0 | 0 | 1 | 0X39|
| d | 0	 | 1 | 0 | 1 | 1 | 1 | 1 | 0 | 0X5E|
| E	| 0	 | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 0X79|
| F	| 0	 | 1 | 1 | 1 | 0 | 0 | 0 | 1 | 0X71|
| -	| 0	 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0X40|
| _	| 0  | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0X08|
| .	| 1	 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0X80|

Figure 3: Seven-Segment LED Display Truth Table

### Rotary Pulse Generator
In order for the microcontroller to read the correct value from the RPG and detect the correct sequence for a turn, we loaded all the bits in port D to a register and performed an and immediate instruction. We then shifted all the bits to the right and compared that value to the value that was previously registered. If this value was the same, then we knew that no rotation was detected by the RPG.  Since only one bit in the pattern changes at once, we know that if channel A is first to detect a change, then we know that a clockwise turn has occurred. If channel B is first to see a change, than a counterclockwise turn has occurred. 

### Pushbutton
The pushbutton is used to lock in the current display character and to reset the code entered. If the pushbutton is pressed for less than one second, then the character currently being displayed is locked into memory. If it is held for more than two seconds, the display is reset to a dash and the memory is wiped. To check the duration of the button press, we utilized the timer of the microcontroller. First we check in the main program if a button press has been detected. If it has then we jump to the button routine. In this routine, we load a register with a value of 20. We then check if the button was pressed again. If it is then we jump to a routine that saves the number of the display. In this routine, we increment the register used to keep track of how many characters have been saved so far, then we jump to another routine that compares the character entered to that of our code. Our assigned lock number was D8D19. In this routine we check first how many characters have been entered. If this is the first time a character to be entered, we branch to another routine that compares the value of the display to the letter D. If it equal, we jump back to the main loop to continue. If it is not equal, then we set the T flag in the status register, then jump to the main loop. We continue this logic for each character that is entered and compare each character to the corresponding character that should be entered. Once the fifth character is entered we branch to a final routine that checks if the code is correct. We check the sixth bit in the status register. This bit is the T flag. If it is set, then we branch to a routine that displays an underscore for 9 seconds, indicating the wrong code has been entered. If the T flag is never set, then we branch to a routine that lights the LED on the Arduino and displays a dot for 5 seconds, indicating a correct code has been entered. 

### Hardware Debounce
Instead of a software debounce for the button and RPG we chose to implement a hardware debounce for both. The debounce for the button works using a combination of a 100kΩ resistor, 10kΩ resistor and a 0.1μF capacitor. The microcontroller recognizes the button is pressed when the input goes low or is zero. While the button is not pressed, the capacitor becomes charged and the microcontroller sees a voltage from VCC  going through the two resistors. The microcontroller sees this as a logic 1. When the button is pressed, the power supply is now directly connected to ground and, without the capacitor, the microcontroller would see a logic 0. However, when the button is pressed, the capacitor begins discharging and the microcontroller still sees a logic 1. The microcontroller only sees a logic zero once the capacitor has completely discharged. This prevents the microcontroller from recognizing the noise associated with the press of the button. When the button is open again, the microcontroller does not immediately see a logic 1 because the capacitor will need to be charged again. The values of the resistors and capacitor were determined using the time constant of the circuit to determine an appropriate rise time of the signal. We began by choosing a reasonable capacitor value (0.1μF) that we could model our resistors around. From this we needed to calculate two separate time constants. When the switch is closed, the capacitor sees a resistance of 10kΩ. This is an RC circuit, so the time constant is calculated as follows:
`τ=R1*C`
`τ=(10k)*(1μF)`
`τ=1ms`

Now that we know the time constant, we can calculate the rise time by multiplying it by 2.2. That gives us:
`tr=2.2ms`

This is the time it takes for the button to reach a logic zero. We must also calculate the time it takes for the capacitor to become charged again and for the microcontroller to see a logic 1. When the button is opened again, the capacitor now sees a resistance of 110k. The time constant is calculated as follows: 
`τ=(R1+R2)*C`
`τ=(110k)*(1μF)`
`τ=11ms`

Now that we know the time constant, we can calculate the rise time by multiplying it by 2.2. That gives us:
`tr=24.2ms`

These rise times allow for the microcontroller to accurately identify when the button is pressed. FIGURE 4 shows the signal read from the button with the debounce.

![Lab-ElectronicDoorLock-Figure4-Debounce.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-ElectronicDoorLock-Figure4-Debounce.png)


The debounce for the RPG works the same way. For our capacitor value, we chose 0.01μF capacitors and used 10kΩ resistors. This hardware debounce was used for both channels on the RPG. When the channel is closed, the RPG sees a resistance of 10kΩ. We can then calculate the time constant for this: 
`τ=R1*C`
`τ=(10k)*(0.01μF)`
`τ=100μs`

Now that we know the time constant, we can calculate the rise time by multiplying it by 2.2. That gives us:
`tr=220μs`

This is the time it takes for the microcontroller to recognize that the RPG has started the sequence to turn. We must also calculate the time it takes for the microcontroller to recognize that the RPG has completed a full turn. When this happens, the RPG sees a resistance of 20kΩ. We can then calculate the time constant for this:
`τ=(R1+R2)*C`
`τ=(20k)*(0.01μF)`
`τ=200μs`

Now we can calculate the rise time:
`tr=440μs`

This is the time it takes for the microcontroller to recognize the turn has been completed. FIGURES 5 AND 6 show the clockwise and counterclockwise turns of the RPG.

![Lab-ElectronicDoorLock-Figure5-RPGturnOn.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-ElectronicDoorLock-Figure5-RPGturnOn.png)


Figure 5: RPG Clockwise Turn on Oscilloscope

![Lab-ElectronicDoorLock-Figure6-RPGCounterclockwise.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-ElectronicDoorLock-Figure6-RPGCounterclockwise.png)

Figure 6: RPG Counterclockwise Turn on Oscilloscope

### Timer
The timer was the most challenging part of the lab to understand. Once implemented, though, it was a very valuable resource. For this lab we needed delays of two seconds, five seconds, and nine seconds. To achieve these delays, we decided to create a simple delay of 100ms and then loop through this delay any number of times in order to achieve the needed delay. To calculate what value needed to be loaded into TCCR0B, we needed to determine a pre-scaler value and use that to calculate the correct starting value. Given that our microcontroller uses a 16MHz clock, we knew that we needed to have a pre-scaler value of 3. This gives us a tMAX of:
`tmax=(1/fclk)*256`
`tmax=(1/16MHz)*256`
`tmax=1.04ms`

Now that we have a tMAX we can calculate what value needs to be loaded into the TCNT0:
`Tclk=(1/(fclk/256))`
`Tclk=1.6ms`
`n=t/Tclk`
`n=100ms/1.6ms`
`n=63`

### Display Routine
For the microcontroller to send the right signals to the shift register, we two registers onto the stack. One was loaded with 8 bits in order to test what bits will be set. We then rotate the contents of the other to the left. If the carry bit is set, we branch to set_ser_in_1. This sets the serial input to 1. We continue to end1 which generates the serial clock to pulse and then decrement the contents of the tester register in order to test the next bit. We branch back to loop1 to again rotate the contents of the other register. If the carry bit is not set, then the serial input is set to zero and end1 is reached again and the serial clock is pulsed. When the tester register reaches zero, we generate the register clock and restore the registers from the stack. At this point, the display has received an accurate signal and is displaying the correct character. We then return to our last line in the program. 

## Conclusion
The most difficult part of this lab was figuring out how to use the timer and how to have the RPG interact with the microcontroller. Once the mechanics of the timer were understood, it came in very handy for many different delays and saved space in our code. This lab, though short, gave us a better understanding of the complexities of the microcontroller and how to utilize its features.

### Appendix
Beichel, R. (2023). Embedded Systems Lab 2 [PowerPoint Slides]. 
https://uiowa.instructure.com/courses/197396/files/folder/PPT?preview=22354741

Beichel, R. (2023). Embedded Systems Lab 2 [PowerPoint Slides]. 
https://uiowa.instructure.com/courses/197396/files/folder/PPT?preview=22430238

Microchip Technologies (2020). AVR Instruction Set Manual. 
https://ww1.microchip.com/downloads/en/DeviceDoc/AVR-Instruction-Set-Manual-DS40002198A.pdf

Pighixxx (2013). Pinout of ARDUINO Board and ATMega328PU. 
https://www.circuito.io/blog/arduino-uno-pinout/

Texas Instruments (2015).Nx4HC595 8-Bit Shift Registers With 3-State Output Registers 
https://www.ti.com/lit.ds/scls041j.pdf?ts=1677119179466&ref_url=https%253A%252F%Fwww.google.com%252F 



