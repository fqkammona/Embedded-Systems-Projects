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
