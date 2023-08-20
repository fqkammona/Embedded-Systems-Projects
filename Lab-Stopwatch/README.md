## Introduction 
In this lab, our task was to design, build, and code a timer using two 7-segment LED displays (5161AS), two shift registers (SN74HC595), two pushbuttons, and an Arduino Uno. We used hardware debounce and Assembly language to program the ATmega328p microcontroller to satisfy the provided conditions. 

## Schematic  
![Schematic](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/e000169a-b5ba-4a72-ad86-97c69dd76db6)

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









