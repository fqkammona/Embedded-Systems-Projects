## Introduction 
In this lab, our task was to design, build, and code a timer using two 7-segment LED displays (5161AS), two shift registers (SN74HC595), two pushbuttons, and an Arduino Uno. We used hardware debounce and Assembly language to program the ATmega328p microcontroller to satisfy the provided conditions. 

## Schematic  
![Lab-Stopwatch-Figure1-Schematic.png](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-Stopwatch-Figure1-Schematic.png)


Figure 1 shows the circuit designed for this lab. The microcontroller collects inputs from both pushbuttons and sends three signals (Serial Input, Shift Register Clock, and Register Clock) to the first SN74HC595 shift register and two signals (Shift Register Clock and Register Clock) to the second SN74HC595 shift register. The first shift register (shown on the left) is connected to the first 7-segment display (shown on the left) using the required 1kΩ current limiting resistance. The shift registers’ outputs, labeled QA-QH are connected to the 7-segment display matching the corresponding pins on the 7-segment display. The second SN74HC595 (shown on the right) receives its’ serial input from the first shift registers’ QH’ output. The second SN74HC595 is otherwise connected to the microcontroller and the second 7-segment display (shown on the left) is the same as the first. For this lab, we implanted a hardware debounce for the two pushbuttons using two resistors (100k and 10k) and a 0.1μF capacitor. The circuit is connected to a 5V power source and is complete with a 0.1pF decoupling capacitor. 

## Discussion

| Pushbutton A |  |  |
| ------------ |----------------- | -------------------- |
| | Increment counter on release | X |	⮽
| | Stop incrementing at 25 | X |
| | Reset counter to 00 on release of a ≥ 1 second press | X | 
| Pushbutton B | | | 
| | Start timer when released | X |
| Hardware Debounce | | |
| | Accurately detect when the button is pressed | X |⮽
| 7-segment display (1) | | |
| | Increment display 0-2 when 9 is reached on display 2 | X |
| | Decrement display 2-0 when 0 is reached on display 2 | X |
| | Flash ‘-‘when the countdown is complete | X | 
| 7-segment display (2) | | | 
| | Increment display 0-9 | X | 	⮽
| | Return to 0 when 9 is reached on increment | X |	⮽
| | Stop at 5 when 2 is on display 1 | X |
| | Decrement display 9-0 | X | 
| | Return to 9 when 0 is reached on decrement | X | ⮽
| | Flash ‘-‘when the countdown is complete | X | 
| Display Routine| | |	
| | 500ms delay | X |
| | 1s delay | X | 
| | Display routine | X | 

Figure 2 lists the specifications our lab was required to meet, broken into sections by component.  

### Hardware Debounce
Instead of using a software debounce, we chose to implement a hardware debounce as this was something we were more familiar with. The debounce works using a combination of a 100kΩ resistor, a 10kΩ resistor, and a 0.1μF capacitor. The microcontroller recognizes the button is pressed when the input goes low or is zero. While the button is not pressed, the capacitor becomes charged and the microcontroller sees a voltage from VCC  going through the two resistors. The microcontroller sees this as a logic 1. When the button is pressed, the power supply is now directly connected to ground and, without the capacitor, the microcontroller would see a logic 0. However, when the button is pressed, the capacitor begins discharging and the microcontroller still sees a logic 1. The microcontroller only sees a logic zero once the capacitor has completely discharged. This prevents the microcontroller from recognizing the noise associated with the press of the button. When the button is open again, the microcontroller does not immediately see a logic 1 because the capacitor will need to be charged again. The values of the resistors and capacitor were determined using the time constant of the circuit to determine an appropriate rise time of the signal. We began by choosing a reasonable capacitor value (0.1μF) that we could model our resistors around. From this, we needed to calculate two separate time constants. When the switch is closed, the capacitor sees a resistance of 10kΩ. This is an RC circuit, so the time constant is calculated as follows:

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

These rise times allow for the microcontroller to accurately identify when the button is pressed. 

![Oscilloscope](https://github.com/fqkammona/Embedded-Systems-Projects/blob/main/Lab-Images/Lab-Stopwatch-Oscilloscope.png)

Figure 3: Oscilloscope Reading of Button Debounce

### 7-segment Displays
The displays oversee displaying 0-25. They are connected to the microcontroller with current limiting resistors calculated using Ohm’s law and the information given in the datasheet. It is listed in the datasheet that the 7-segment LED displays can withstand a maximum current of 30mA. Using VCC as 5V we can calculate the correct resistance values using Ohm’s law: 

`V=IR`
`5V=(30mA)*R`
`R ≅ 167Ω`

This provides the 7-segment with the maximum current allowed. We chose to be conservative and used 1kΩ resistors. To increment the displays, we used many different routines and registers in order to compare values and determine what needed to be displayed. For the display, we used three registers: R18 keeps track of what number the display should be on, R24 contains the hex to display a number, and R21 takes a copy of R20 to display. For the second display, we used three registers for the same purpose as the first display, R19, R20, and R16, respectively. When button 1 is pressed, we enter a routine that times how long the button is pressed (buttonOneLoop). This loop first initializes the counter for the button (R29) to zero and continues to another loop (buttonOne). This loop checks if the button is pressed for one second or more by incrementing R29 every 100ms that the button is pressed in a row. If the contents of R29 reach 0x0A then we branch to another routine (setReset) which continuously checks if the button is pressed and when pressed goes to the routine to set displays to zero (reset). After the displays are zero, both R18 and R19 are reset to zero and we jump back to the main loop. If the button is pressed for less than one second then we jump to the routine to increment the counter (isPresssed). In isPressed, we first increment the counter or the second display. Then we compare the value of the counter to zero. If the counter is zero, we must determine what the first display should be so we branch to a routine to determine this (displayFind). In this routine, we compare the value of R18 to one. If one, we branch to displayOne which loads R24 with the hex to display one. That value is then copied to R21 and we jump to the display routine. If it is not one, we compare R18 to two. If it is, we branch to displayTwo which loads R24 with the hex to display two. This value is copied to R21 once again and jumps to the display routine. After this, we jump to d0 which changes the second display. In this routine, we load R20 with the hex to display two, copy that value to R16, call the display, then jump back to the main loop to check the buttons once again. If the first button is pressed for less than 1 second, we will again end up in the isPressed routine. R19 is incremented again, and we compare the value to one. If the counter is one, we branch to a d1, which follows the same technique as d0 in order to display 1 on the second display with the correct hex value. FIGURE 4 shows the complete list of hex values to display the correct number to the display.

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

Figure 4: Display Truth Table

The routine isPressed follows this logic for 2,3,4,5. When R19 reaches 6, we branch to displayNumberSix since the timer is only allowed to count to 25. In this routine, we compare R18 to 0 or 1 we continue to d6 to display 6. If the counter is neither we simply call the display again which continues to display the last numbers that were displayed, 25. The routines d6-d7 follow the same routine as d1. When the counter reaches a value of 9, we first copy the contents of R19 to R23. We then reset R19 to zero and increment R18. Then we compare R23 to 9 and continue to d9. After this, nothing else occurs until we either press the first button for more than 1 second or we press the second button to begin the countdown. When button 2 is pressed jump to buttonTwo. In buttonTwo, we continuously check if the second button is pressed. When it is we jump to a routine to check the value of the R19. If this value is zero, that means the countdown is either complete or the timer was reset, and we go back to the main loop. If R19 is a different value, we jump to startCountDown. This routine follows a similar logic as isPressed, but in an opposite fashion. We first decrement the contents of R19 and then call a 1-second display. Next, we compare the value of R19 to zero and branch to dCount0 if true. In dCount0 we follow the same logic as d0 to display 0 and then jump back to startCountDown. We continue comparing the contents of R19 and branching to the corresponding routine, dCount0-dCount8. When the counter equals 9, we first copy the contents to R23. Then, we load R19 with 0x0A, then decrement R18. We compare R23 to zero and if true, we go to displayFindCount. In this routine, we compare R18 to 0-2. If it is less than 0, we branch to loopEndDisplay. This routine loads a register (R27) with 4 then enters a loop that displays a dash, followed by a 500ms delay, then display nothing, followed by another 500ms delay. We then decrement R27. We leave this loop once R27 is zero and return to zeros on the display. We can then set the counter again. Going back to displayFindCount, if R18 is zero we branch to displayZeroCount which follows the same code as d0. This is the same for R18 equal to one and R18 equal to 2. After this, we jump to dCount9 to continue the countdown.  

### Display Routine
The process to create the correct delays was similar to that of Lab 1. A code snippet was developed to test what different values would provide the correct number of cycles to have a certain delay. We had three different delay routines for 100ms, 500ms, and 1s.  The 100ms delay contains two loops that take 1.6 million cycles to complete resulting in a 100ms delay. The 500ms delay calls the 100ms delay five times and the 1s delay calls the 500ms delay two times. For the microcontroller to send the right signals to the shift registers, we pushed R21, R16, and R17 onto the stack. R17 was loaded with 8 bits in order to test what bits will be set. We then rotate the contents of R 16 to the left. If the carry bit is set, we branch to set_ser_in_1. This sets the serial input to 1. We continue to end1 which generates the serial clock to pulse and then decrement the contents of R17 in order to test the next bit. We branch back to loop1 to again rotate the contents of R16. If the carry bit is not set, then the serial input is set to zero and end1 is reached again and the serial clock is pulsed. When R17 reaches zero, we enter loop2 and reset R17 to 8. This Loop functions exactly the same as loop1, only it tests the bits of R21. After all 16 bits of R16 and R21 are tested, we generate the register clock and restore the registers from the stack. At this point, both displays have received accurate signals and are displaying the correct numbers. We then return to our last line in the program. 

## Conclusion
The most difficult part of this lab was becoming familiar with the software. Assembly language requires a different way of thinking to work. Once the language became more familiar, completing all the requirements took time but was not difficult. The hardest part of the hardware setup was the number of connections that needed to be made in a small space. All connections need to be closely checked and secured so they would not become lost when the circuit was moved from place to place. Overall, this lab was an excellent introduction to the benefits that assembly language offer and was a good representation of combining software and hardware. 

### Appendix
Beichel, R. (2023). Embedded Systems Lab 2 [PowerPoint Slides]. 
https://uiowa.instructure.com/courses/197396/files/22152027/download?download_frd=1

Microchip Technologies (2020). AVR Instruction Set Manual. 
https://ww1.microchip.com/downloads/en/DeviceDoc/AVR-Instruction-Set-Manual-DS40002198A.pdf

Pighixxx (2013). Pinout of ARDUINO Board and ATMega328PU. 
https://www.circuito.io/blog/arduino-uno-pinout/

Texas Instruments (2015).Nx4HC595 8-Bit Shift Registers With 3-State Output Registers 
https://www.ti.com/lit.ds/scls041j.pdf?ts=1677119179466&ref_url=https%253A%252F%Fwww.google.com%252F
















