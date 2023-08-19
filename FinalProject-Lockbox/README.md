## Introduction
  In an effort to address the increasing number of texting-and-driving accidents occurring annually, I designed a lockbox specifically for drivers' phones. The concept involved having users place their phone in the box and, utilizing the LCD screen, RGB display, and button, select their destination. Upon confirmation, the box would securely lock the phone inside and only unlock once it detected coordinates matching the chosen destination.
## Implementation
  From the outset, my strategy for this project involved tackling each component individually, testing and verifying both software and hardware before progressing to the subsequent component or task. The table below outlines the sequence of tasks and the associated hardware and software objectives required for their completion. A more detailed discussion of the methods used for validating each task's success prior to moving forward can be found in the Experimental Methods section. For a comprehensive list of all components and related information, please refer to the References subsection.

| Task       | Hardware Description | Software Description |
| ---------- | -------------------- | -------------------- |
| LCD Screen | Successfully hardware the component.  | Find a library that allows all functions, such as clear and write to the display, to be used. |
| RPG and Pushbutton | Debounce needed for both components.  |Use interrupts to indicate changes made to the state and updated the lcd with corresponding state. | 
| GPS | Solder header pins to the component. | Create a function to successfully parse in the NMEA messaging system. |
| Solenoid | Use components, TIP120 and 1N4001 to safely hardware the solenoid. | Create a simple program that locks and unlocks the solenoid to verify the hardware. | 

  As illustrated above, my initial task focused on the LCD component. I discovered an excellent library by Joerg Wunsch and utilized the hd44780.c, hd44780.h, lcd.c, and lcd.h files from that library to configure and program the LCD. Originally, Wunsch's library was designed for an LCD with only one line of display, so I modified the logic to accommodate my LCD, which featured two lines of display. The LCD offered eight different display options for user interaction, as depicted in Figure 2 below. Overall, both hardware and software aspects of this task were relatively straightforward, and I completed them within a day, using resistor values of 1K and 10K for the LCD screen.

![LCD-interface](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/c0dc07cb-c783-4258-a234-bfb438802f1d)
Figure 2: LCD Interface

The subsequent task involved incorporating the RPG and pushbutton. The hardware
aspect was relatively simple, and the debounce of both components can be seen in Figure 3 below. This task was slightly more challenging due to the need for implementing pin change interrupts in C. However, by referring to the ATmega328P datasheet, I successfully employed PCICR, PCIE0, and PSMSK0 to utilize the interrupts. Upon the occurrence of an interrupt, the rpg_statechange and button_pressed functions would be called, and within these functions, logic was incorporated to identify which component was being used.

![Verification-Of-Pushbutton](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/bb24f522-fe37-4bb0-a650-0fee4d071d7a)
Figure 3: Verification of pushbutton debounce and the RPG debounce

Proceeding to the third task, I focused on the GPS component. After soldering header pins, I used a 10K resistor value for the enable pin to set it to high, provided ground and power connections, and then worked with the Tx and Rx pins. For testing with the serial monitor, which will be discussed further in the next section, I connected the Arduino's Tx port to the GPS component's Tx pin and the Rx port to the Rx pin. However, when using the GPS component outdoors, I had to switch the pins.

For the software aspect of this task, I initially attempted to use a library but was unsuccessful. As a result, I developed my own functions to achieve the desired objectives for this component. I created a custom function to parse the NMEA sentence received from the GPS, successfully extracting latitude and longitude data, along with their respective degrees and directions. While additional information such as speed and altitude could have been utilized, they were not pertinent to my project goals. Nevertheless, such supplementary data offer numerous possibilities for enhancing my product in the future.

![Solenoid-Schematic ](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/3f3331a9-e305-403c-90bd-ca87cb5252e6)
Figure 4: Solenoid Schematic

The final task entailed implementing the solenoid, which, in contrast to the previous task, involved more complex hardware than software. For the software, all that was required was specifying the output port and applying logic to set the port high and low. The hardware, on the other hand, demanded greater effort because the component required at least 9 volts to be powered, necessitating the use of the Vin port on my ATmega328P.

I employed a TIP120 MOSFET, a 1N4001 diode, and a 2.2K resistor to regulate the current and power flowing in and out of the component, ensuring that the rest of the circuit, which had a maximum of 5 volts, was not affected. The schematic above was provided by Adafruit, the company from which I purchased both the solenoid and GPS components. Figures 5 and 6 showcase the software flow diagram and the complete schematic of my project.

![Software-Flow-Diagram](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/8d496584-fd7f-434d-916f-35170de90ae4)
Figure 5: Software Flow Diagram

![Schematic](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/205133ae-bf06-4b6c-860d-6b3ee9fd8926)
Figure 6: Schematic of Project

## Experimental Methods
Testing user interface components, such as the LCD, RPG, and pushbutton, was relatively simple and easy to verify. As anticipated, new components like the GPS and solenoid required more time and effort for verification and handling. To test the GPS, I employed the serial monitor input USART, which enabled me to examine my logic without needing to go outside and wait for the component to acquire a fix and provide data. This approach allowed me to debug my logic efficiently, resolve minor bugs, and identify other issues without wasting time outdoors. The figure below displays successful results from the serial monitor.

![Monitor](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/ce96a687-0991-4d17-ab2d-28b1bb6cfa6a)
Figure 7: Testing using Serial Monitor

While implementing and testing the solenoid, I decided to construct it on a separate
breadboard and test it individually. Considering that the solenoid requires up to 12 volts with a minimum of 9 volts, and the rest of the circuit operates at a maximum of 5 volts, I adopted this approach to avoid damaging components and to facilitate debugging potential issues. To evaluate the board, I developed a simple Arduino program that locked and unlocked the solenoid every two seconds. The figures below depict the successful testing of the solenoid and the code utilized.

![Solenoid](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/237f7c18-a4b2-4fab-8f4a-ed60503894cb)
Figure 8: Testing Solenoid

![Arduino-code](https://github.com/fqkammona/Embedded-Systems-Projects/assets/109518919/ebdec85f-5792-48f1-9744-00902ba00feb)
Figure 9: Arduino code for Solenoid testing

After successfully implementing and testing the solenoid, I integrated it and its associated
components into the main circuit and incorporated the relevant code into the primary C program. With these steps completed, it was time to initiate the final tests, incorporating all components and code.

## Results
The figures show in the image file demonstrate the successful operation of setting the destination to the Seamans Center, securing the box, arriving at the correct location, and unlocking the box.

## Discussion of Results
I successfully achieved all the goals I set for this project, and the performance exceeded my expectations. Initially, I considered implementing a keypad function, but it seemed unnecessary and excessive for the project's intended purpose. My current limitations involved mobility, as it was challenging to transport and test my project. To enhance this project, I would first address the need for a more efficient power source.

## Conclusion
I successfully integrated various components to develop a lockbox for phones, aimed at preventing texting while driving. By creating this product from scratch and independently conducting research and developing hardware and software, I gained valuable knowledge. Through this process, I became adept at reading datasheets, understanding the interplay between components, and identifying potential issues arising from power supply constraints.

### Acknowledgements
For my implementation of the LCD open-source code from Joerg Wunsch was used and modified to work for my application.

### References
Circuito. (n.d.). Arduino Uno pinout diagram. Retrieved from
https://images.prismic.io/circuito/8e3a980f0f964cc539b4cbbba2654bb660db6f52_arduino-uno-pinout-diagram.png?auto=compress,format

Gids, P. (n.d.). NMEA data. Retrieved from http://aprs.gids.nl/nmea/#rmc

#### Datasheets
Adafruit Industries. (n.d.). Adafruit Ultimate GPS. 
Retrieved from https://cdn-learn.adafruit.com/downloads/pdf/adafruit-ultimate-gps.pdf
Adafruit Industries. (n.d.). Solenoid driver. 
Retrieved from https://cdn-blog.adafruit.com/uploads/2012/08/solenoid_driver.jpg

Diodes Incorporated. (n.d.). 1N4001 - 1N4007 datasheet. Retrieved from
https://www.diodes.com/assets/Datasheets/ds28002.pdf

Fairchild Semiconductor. (n.d.). TIP120 datasheet. Retrieved from
https://pdf1.alldatasheet.com/datasheet-pdf/view/54789/FAIRCHILD/TIP120.html

MediaTek Inc. (n.d.). PMTK command packet. Retrieved from https://cdn-shop.adafruit.com/datasheets/PMTK_A11.pdf

Microchip Technology Inc. (n.d.). ATmega328P datasheet. Retrieved from
https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf

#### Software libraries used
AVRDUDES. (n.d.). Stdiodemo. Retrieved from https://github.com/avrdudes/avr-libc/tree/main/doc/examples/stdiodemo

#### Parts Table
| Name:                     | Description: | Source: | Quantity: | Price: |
| ------------------------- | ------------ | ------- | --------- | ------ |
| 12 V Lock-style Solenoid	| Locks/Unlocks the box	| Adafruit | 1 |	$14.95 | 
| Atmega328p Arduino Uno	  | To program keypad, LCD display, and RPG |	Kit	| 1 |	$0.00 | 
| LCD Display (LCD1602A)	  | Displays menu options	| Kit |	1 |	$0.00 |
| RPG	                      | Select from menu options | Kit | 1 | $0.00 | 
| Pushbutton	| Locks in menu option	| Kit |	1 |	$0.00 |
| Breadboard	| Circuit components | Electronic Shop | 1 | $22.00 |
| Wires, Resistors, Capacitors | Circuit component | Kit | NA |	$0.00 |
| GPS Receiver (WAAS)	| Used to track locations |	Adafruit | 1	| $30.00 |
| Mosfet TIP120	|	| Electronic Shop	| 1 |	$1.00 |
| Diode 1N4001	| |	PEI Kit| 	1 |	$0.00 |
| GPS Active Antenna 28dB | To cut down the time to find a fix | Electronic Shop	| 1	| $7.98 | 

