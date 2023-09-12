;
; lab2.asm
;
; Created: 2/4/2023 8:27:45 AM
; Author : fqkammona
;

.include "m328Pdef.inc"
.cseg
.org 0
 
; put code here to configure I/O lines as output & connected to SN74HC595
cbi DDRB,0   ; PB0 (on board it's 8) is now INPUT, This pin is used for the first button  (counter) (Right)
cbi DDRB,1	 ; PB1 (on board it's 9) is now INPUT, This pin is used for the second button  (start/stop ) (Left)


sbi DDRB,2   ; PB2 (on board it's 10) is now output, This pin is used for SER (serial input)
sbi DDRB,3   ; PB3 (on board it's 11) is now output, This pin is used for SRCLK (serial clock)
sbi DDRB,4	 ; PB4 (on board it's 12) is now output, This pin is used for RCLK (registor clock) 

; R16 --> Second display number
; R18 --> Counter for First Display
; R19 --> Counter for Second Display
; R20 --> Load digits to copy to second display
; R21 --> First display number
; R24 --> Load digits to copy to first display
; R27 --> End display count
; R26--> Button 1 count for reset
; R29 -.> Button 1 

; start main program
rjmp reset

; Loop for always checking if button is being pressed 
mainLoop:
	sbis PINB,0 // Skip next instruction if Button 1 is high --> Not pressed
	rjmp buttonOneLoop

	sbis PINB,1 // Skip next instruction if Button 2 is high --> Not pressed
	rjmp buttonTwo // Skip if not pressed 

rjmp mainLoop

finalLoop:
	sbis PINB,0 // Skip next instruction if Button 1 is high --> Not pressed
	rjmp buttonOneEnding
	sbis PINB,1 // Skip next instruction if Button 2 is high --> Not pressed
	rjmp startCountDown
rjmp finalLoop




; Button Section 
;--------------------------------------------------------------------

buttonOneEnding:
	ldi R26, 0 // set count to zero

	buttonOneEndingAgain:	
		sbic PINB, 0 // Skip next instruction if Button 1 is low --> Pressed
		rjmp finalLoop 

		rcall delay_100ms // call 100ms delay
		
		inc R26 
		cpi R26, 0xA // Compare contents of R29 to 0xA 
		breq setReset // Go to setReset if contents of R29 == 0xA (If R29 is 10, Button 1 has been pressed for 1s or longer 

	rjmp buttonOneEndingAgain

rjmp buttonOneEnding

buttonOneLoop:
	ldi R19, 0 // set count to zero

	buttonOne:	
		sbic PINB, 0 // Skip next instruction if Button 1 is high --> Not pressed
		rjmp isPressed // Skip if button 1 is not pressed

		rcall delay_100ms // call 100ms delay
		
		inc R29 
		cpi R29, 0xA // Compare contents of R29 to 0xA 
		breq setReset // Go to setReset if contents of R29 == 0xA (If R29 is 10, Button 1 has been pressed for 1s or longer

	rjmp buttonOne

rjmp buttonOneLoop 

buttonTwo:
	sbic PINB, 1 // Skip next instruction if Button 2 is high--> Not Pressed
	sbis PINB, 1 // Skip next instruction if Button 2 is low --> Pressed 
rjmp buttonTwo // Jump to buttonTwo if the button 2 is not pressed
rjmp checkReset // Jump to startCountDown if Button 2 is pressed

checkReset:
		cpi R19, 0x01 ; Compare second display counter to Zero
		breq mainLoop
rjmp startCountDown

; Reset Functions 
;--------------------------------------------------------------------
setReset:
	sbic PINB, 0 // Skip next instruction if Button 1 is high --> Not pressed
	rjmp reset // Skipped if button is not pressed
rjmp setReset // Continuously check if Button 1 is pressed

reset:
	ldi R16,0x3F ; Start at 0 
	ldi R21,0x3F ; Start at 0 
	rcall display ; Display zeros
	ldi R18,0x00 ; Reset first display counter to 0
	ldi R19,0x01 ; Reset second display counter to 0
rjmp mainLoop

; Counter for button 
;--------------------------------------------------------------------
isPressed:
	inc R19 // Increment the counter for the second display

	cpi R19, 0x01 ; Compare second display counter to Zero
	breq displayFind ; If second display counter is zero --> Branch to displayFind

	cpi R19, 0x02 ; Compare second display counter to one
	breq d1 ; If second display counter is zero --> Branch to displayFind
  
	cpi R19, 0x03 ; Compare second display counter to two
	breq d2 ; If second display counter is two --> Branch to d2

	cpi R19, 0x04 ; Compare second display counter to three
	breq d3 ; If second display counter is three --> Branch to d3

	cpi R19, 0x05 ; Compare second display counter to four
	breq d4 ; If second display counter is four --> Branch to d4
 
	cpi R19, 0x06 ; Compare second display counter to five
	breq d5 ; If second display counter is five --> Branch to d5

	cpi R19, 0x07 ; Compare second display counter to six
	breq displayNumberSix ; If second display counter is six --> Branch to displayNumberSix

	cpi R19, 0x08 ; Compare second display counter to seven 
	breq d7 ; If second display counter is seven --> Branch to d7
  
	cpi R19, 0x09 ; Compare second display counter to eight
	breq d8 ; If second display counter is eight --> Branch to d8
  
	mov R23, R19 ; Copy the contents of R19 to R23
	ldi R19, 0x00 ; set second display counter to zero
	inc R18 ; Increment counter for display one 
	cpi R23, 0xA ; Compare second display counter to nine 
	breq d9 ; If second display counter is nine --> Branch to d9

	rcall display ; Display 
rjmp mainLoop  ; Jump back to mainLoop


; If statements for first display  
;--------------------------------------------------------------------

displayFind: 
	cpi R18, 0x01 ; Compare counter for display one to one  
	breq displayOne ; If counter is one--> display one

	cpi R18, 0x02 ; Compare counter for display one to two
	breq displayTwo ; If counter is two--> display two

	rcall display ; call display
rjmp d0 ; Jump to d0 -->

displayOne:
	ldi R24, 0x06 ; Load R24 with hex to display 1
	mov R21, R24 ; Copy the hex to R21 
	rcall display ; Display 1
rjmp d0 ; Jump to d0 -->

displayTwo:
	ldi R24, 0x5B ; Load R24 with hex to display 2
	mov R21, R24 ; Copy the hex to R21
	rcall display ; Display 2
rjmp d0 ; Jump to d0

; If statements for number 6 
;--------------------------------------------------------------------

displayNumberSix:
	cpi R18, 0x00 ; Compare counter for first display to zero  
	breq d6 ; if counter is zero --> Display six

	cpi R18, 0x01 ; Compare counter for first display to one  
	breq d6 ; if counter is one --> Display six

	rcall display ; Call display
rjmp finalLoop ; Jump to countdown

; If statements for standard display of numbers  
;--------------------------------------------------------------------

d0: ; If count = 0
	ldi R20, 0x3F ; Load R20 with hex to display zero 
	mov R16, R20 ; Copy contents of R20 (hex to display zero) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop 

d1: ; If count = 1
	ldi R20, 0x06 ; Load R20 with hex to display one
	mov R16, R20 ; Copy contents of R20 (hex to display one) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d2: ; If count = 2
	ldi R20, 0x5B ; Load R20 with hex to display two
	mov R16, R20 ; Copy contents of R20 (hex to display two) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d3: ; If count = 3
	ldi R20, 0x4F ; Load R20 with hex to display three
	mov R16, R20 ; Copy contents of R20 (hex to display three) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d4: ; If count = 4
	ldi R20, 0x66 ; Load R20 with hex to display four
	mov R16, R20 ; Copy contents of R20 (hex to display four) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d5: ; If count = 5
	ldi R20, 0x6D ; Load R20 with hex to display five
	mov R16, R20 ; Copy contents of R20 (hex to display five) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d6: ; If count = 6
	ldi R20, 0x7D ; Load R20 with hex to display six
	mov R16, R20 ; Copy contents of R20 (hex to display six) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop 

d7: ; If count = 7
	ldi R20, 0x07 ; Load R20 with hex to display seven
	mov R16, R20 ; Copy contents of R20 (hex to display seven) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d8: ; If count = 8
	ldi R20, 0x7F ; Load R20 with hex to diplay eight
	mov R16, R20 ; Copy contents of R20 (hex to display eight) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

d9: ; If count = 9
	ldi R20, 0x6F ; Load R20 with hex to display nine
	mov R16, R20 ; Copy contents of R20 (hex to display nine) to R16 (Second Display)
	rcall display ; Display
rjmp mainLoop

;--------------------------------------------------------------------

startCountDown:
	dec R19 ; Decrement the counter for the second display
	rcall delay_1s ; Delay 1 second

	cpi R19, 0x01 ; Compare the Second Display Counter to zero
	breq dCount0 ; If counter is zero --> Display zero

	cpi R19, 0x02 ; Compare the Second Display Counter to one
	breq dCount1 ; If counter is one --> Display one
  
	cpi R19, 0x03 ; Compare the Second Display Counter to two
	breq dCount2 ; If counter is two --> Display two

	cpi R19, 0x04 ; Compare the Second Display Counter to three
	breq dCount3 ; If counter is three --> Display three

	cpi R19, 0x05 ; Compare the Second Display Counter to four
	breq dCount4 ; If counter is four --> Display four
 
	cpi R19, 0x06 ; Compare the Second Display Counter to five
	breq dCount5 ; If counter is five --> Display five

	cpi R19, 0x07 ; Compare the Second Display Counter to six
	breq dCount6 ; If counter is six --> Display six

	cpi R19, 0x08 ; Compare the Second Display Counter to seven
	breq dCount7 ; If counter is seven --> Display seven
  
	cpi R19, 0x09 ; Compare the Second Display Counter to eight
	breq dCount8 ; If counter is eight --> Display eight
  
	mov R23, R19 ; Copy the contents of the Second Display Counter to R23
	ldi R19, 0xA ; Set the Second Display Counter to 10
	dec R18 ; Decrement the First Display Counter 
	cpi R23, 0x00 ; Compare the contents of the Second Display Counter to zero
	breq displayFindCount ; If Second Display Counter is zero --> Go to DisplayFindCount

	rcall display
rjmp mainLoop 


displayFindCount:
	cpi R18, 0x00 ; Compare the First Display Counter to zero
	brmi loopEndDisplay

	cpi R18, 0x00 ; Compare the First Display Counter to zero
	breq displayZeroCount ; If the First Display Counter is zero --> Display zero

	cpi R18, 0x01 ; Compare the First Display Counter to one
	breq displayOneCount ; If the First Display Counter is one --> Display one

	cpi R18, 0x02 ; Compare the First Display Counter to two
	breq displayTwoCount ; If the First Display Counter is two --> Display two

	rcall display ; Display first Display
rjmp dCount9 ; Jump to display nine

displayZeroCount:
	ldi R24, 0x3F ; Load R24 with hex to display zero
	mov R21, R24 ; Copy R24 to R21 
	rcall display
rjmp dCount9

displayOneCount:
	ldi R24, 0x06
	mov R21, R24
	rcall display
rjmp dCount9

displayTwoCount:
	ldi R24, 0x5B
	mov R21, R24
	rcall display
rjmp dCount9

dCount0: ; If count = 0
	ldi R20, 0x3F
	mov R16, R20
	rcall display
rjmp startCountDown

dCount1: ; If count = 1
	ldi R20, 0x06
	mov R16, R20
	rcall display
rjmp startCountDown 

dCount2: ; If count = 2
	ldi R20, 0x5B
	mov R16, R20
	rcall display
rjmp startCountDown

dCount3: ; If count = 3
	ldi R20, 0x4F
	mov R16, R20
	rcall display
rjmp startCountDown

dCount4: ; If count = 4
	ldi R20, 0x66
	mov R16, R20
	rcall display
rjmp startCountDown

dCount5: ; If count = 5
	ldi R20, 0x6D
	mov R16, R20
	rcall display
rjmp startCountDown

dCount6: ; If count = 6
	ldi R20, 0x7D
	mov R16, R20
	rcall display
rjmp startCountDown

dCount7: ; If count = 7
	ldi R20, 0x07
	mov R16, R20
	rcall display
rjmp startCountDown

dCount8: ; If count = 8
	ldi R20, 0x7F
	mov R16, R20
	rcall display
rjmp startCountDown

dCount9: ; If count = 9
	ldi R20, 0x6F
	mov R16, R20
	rcall display
rjmp startCountDown

; Final display blinking 
;--------------------------------------------------------------------

loopEndDisplay:
	ldi R27, 4 // Count to  flash dashes/zeros four times (4 seconds) 
		dEndDisplay:
			rcall endDisplay
			dec R27
	brne dEndDisplay // Leave end display when cycled four times 
ret 

endDisplay:

	ldi R16,0x40 // Dash
	ldi R21,0x40 // Dash
	rcall display // Display dashes

	rcall delay_500ms // for 500ms

	ldi R16,0x00 // Zero
	ldi R21,0x00 // Zero 
	rcall display // Display Zeros

	rcall delay_500ms // for 500ms 
ret 

; Delays section 
;--------------------------------------------------------------------

.equ count = 0xA8EB ; assign a 16-bit value to symbol "count"

; Generates a 100ms delay 
delay_100ms:
	push r29
	ldi r30, low(count)   ; r31:r30  <-- load a 16-bit value into counter register for outer loop
	ldi r31, high(count);
	d11:
		ldi   r29, 0xB    ; r29 <-- load a 8-bit value into counter register for inner loop
	d21:
		dec   r29            ; r29 <-- r29 - 1
		brne  d21 ; branch to d2 if result is not "0"
		sbiw r31:r30, 1 ; r31:r30 <-- r31:r30 - 1
		brne d11 ; branch to d1 if result is not "0"
	pop r29
ret ; return

; Generates a 500ms delay 
delay_500ms:
	rcall delay_100ms
	rcall delay_100ms
	rcall delay_100ms
	rcall delay_100ms
	rcall delay_100ms
ret ; return

; Generates 1s delay 
delay_1s:
	rcall delay_500ms
	rcall delay_500ms
ret

;--------------------------------------------------------------------
display: 
	; backup used registers on stack
	push R21
	push R16
	push R17
	in R17, SREG
    push R17
	ldi R17, 8 ; loop --> test all 8 bits

loop1:
	rol R16 ; rotate left trough Carry
	BRCS set_ser_in_1 ; branch if Carry is set
	; put code here to set SER to 0
	cbi PORTB,2  ; SER is set to 0 
	rjmp end1
set_ser_in_1:
	; put code here to set SER to 1
	sbi PORTB,2 ; SER is set to 1 which is 
end1:
	; put code here to generate SRCLK pulse
	;...
	sbi PORTB,3 ; SRCLK set to 1 which is high 
	cbi PORTB,3 ; SRCLK set to 0 which is low 
	dec R17
	brne loop1
	ldi R17, 8

loop2:
	rol R21 ; rotate left trough Carry
	BRCS set_ser_in_2 ; branch if Carry is set
	; put code here to set SER to 0
	cbi PORTB,2  ; SER is set to 0 
	rjmp end2
set_ser_in_2:
	; put code here to set SER to 1
	sbi PORTB,2 ; SER is set to 1 
end2:
	; put code here to generate SRCLK pulse
	;...
	sbi PORTB,3 ; SRCLK set to 1 which is high 
	cbi PORTB,3 ; SRCLK set to 0 which is low 
	dec R17
	brne loop2
	; put code here to generate RCLK pulse
	;...
	sbi PORTB,4 ; RCLK set to high 
	cbi PORTB,4 ; RCLK set to low
	nop
	sbi PORTB,4
	; restore registers from stack
	pop R17
	out SREG, R17
	pop R17
	pop R16
	pop R21
	
	ret
.exit
