;
; lab3.asm
;
; Created: 2/26/2023 2:23:02 PM
; Author : fqkammona
;
.include "m328Pdef.inc"
.cseg
.org 0

.equ RPG_A = 6 ; PD6 -- Used for RPG Channel A 
.equ RPG_B = 7 ; PD7 -- Used for RPG Channel B

; put code here to configure I/O lines as output & connected to SN74HC595
cbi DDRB,0   ; PB0 (on board it's 8) is now INPUT, This pin is used for the button  

sbi DDRB,1   ; PB1 (on board it's 9) is now output, This pin is used for SER (serial input)
sbi DDRB,2   ; PB2 (on board it's 10) is now output, This pin is used for SRCLK (serial clock)
sbi DDRB,3	 ; PB3 (on board it's 11) is now output, This pin is used for RCLK (registor clock) 
sbi DDRB,5	 ; PB5 (on board it's 13) is now output, This pin is used for the led display 

cbi DDRD, RPG_A	 
sbi PIND, RPG_A	 
cbi DDRD, RPG_B	 
sbi PIND, RPG_B

; r16 --> Display number/Letter 
; r18 --> Counter for array 
; r19 --> The numbers that have been addded 
; r20 --> Used to set the starting value 
; r21 --> Temporary variables for delay 
; r22 --> Temporary vaules for delay 
; r23 --> Input coming from RPG 
; r24 --> Holds the rotations 
; r25 --> Used to compare if a state change has happened  
; r26 --> Used to keep track of the timer_delay  
; r29 --> Used for looping through timerdelay  

; Display Options 
;--------------------------------------------------------------------
.equ dot = 0x80			; Dot 
.equ dash = 0x40		; Dash 
.equ underScore = 0x08	; Underscore  
.equ numberD = 0x5E		; D
.equ numberEight = 0x7F ; Eight
.equ numberOne = 0x06	; One 
.equ numberNine = 0x6F	; Nine

map:
.db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

ldi r24, 0b11000000
ldi r20, 0x63
out TCCR0B, r20		

clt		; Clears T Flag 
clr r0	; Clears r0 

; start main program
;--------------------------------------------------------------------
rjmp reset
mainLoop:
	rcall stateChange

	sbis PINB, 0
	rjmp buttonOneLoop

	rjmp mainLoop

; Code compares input to lock number  
; r19 is used to track how many numbers have been entered and then calls different branches
; to check if the correct digit has been entered. If the correct digit has been entered then we 
; rjmp back to main if else then the T flag will be set and then we rjmp to main. Once the 
; final digit has been entered then check_lock is called to check if the T flag has been set. 
; If it has then incorrect_lock will be called if else then the correct_lock will be called. 
;--------------------------------------------------------------------
; lockNumber = 0xD8D19 
compare_Lock:
	cpi r19, 0x01
	breq compareN1

	cpi r19, 0x02
	breq compareN2

	cpi r19, 0x03
	breq compareN3

	cpi r19, 0x04
	breq compareN4
	
	cpi r19, 0x05
	breq compareN5	

; SET is used to set the T flag 
compareN1:
	cpi r16, numberD
	breq mainLoop
	SET				
	rjmp mainLoop

compareN2:
	cpi r16, numberEight
	breq mainLoop
	SET 
	rjmp mainLoop

compareN3:
	cpi r16, numberD
	breq mainLoop
	SET 
	rjmp mainLoop

compareN4:
	cpi r16, numberOne
	breq mainLoop
	SET 
	rjmp mainLoop

compareN5:
	cpi r16, numberNine 
	breq check_Lock
	SET 
	rjmp check_Lock

check_Lock:
	BRBS 6, incorrect_Lock		; If T flag has been set branch to incorrect_Lock 
	rjmp correct_Lock

; State Change 
; This section is used to keep track of state changes and to determine weather
; the rotation detected was clockwise or counter clockwise. 
;--------------------------------------------------------------------
stateChange:
	in r23, PIND
    andi r23, 0b11000000	; Take the first two bits 
	
	lsr r23					; Shifts all the bits to the right 
	lsr r23
	lsr r23
	lsr r23
	lsr r23	
	lsr r23

	mov r25, r24
	andi r25, 0b00000011	; Take the last two bits 

	cp r25, r23				
	breq stateChange_end	; If r25 and r23 are the same then no state change has happened 
	
	; state Change Found
	lsl r24					; Shifts all bits to the left 
	lsl r24
	or r24, r23				; Add in r23 to r24 

	cpi r24, 0b11010010     ; Check if r24 equals cw 
	brne stateChange_if_ccw ; If r24 doesn't equal cw then go to stateChange_if_ccw

	cpi r18, 0x0f			; Check to make sure r18 doesn't go over F 
	breq stateChange_fi		

	inc r18					; If r24 equals cw then increament r18
	rjmp stateChange_fi     

stateChange_if_ccw:
	cpi r24, 0b11100001		; Check if r24 equals ccw 
	brne stateChange_end	; If r24 doesn't equal ccw then r24 doesn't equal ccw or cw so go to stateChange_end 

	cpi r18, 0x00			; Check if r18 equals 0 
	breq stateChange_fi		
	
	cpi r18, 0x00
	brlt stateChange_fi		; If r18 less than
	dec r18					; If r24 equals ccw then decreament r18

stateChange_fi:
	rcall index_to_digit
	rcall display

stateChange_end:
	ret 

; Button
; ButtonOneLoop is used to track if the button has been held for longer than 2 seconds. 
; If it has then reset is called if not then add_Number is called. add_Number increaments 
; r19 and then rjmps to compare_Lock 
;--------------------------------------------------------------------
buttonOneLoop:
	ldi r29, 20				; 100ms * 20 = 2 second 
	
	buttonOne:
		sbis PINB, 0
		sbic PINB, 0
		rjmp add_Number 
		
		ldi r26, 0x63		; 100ms 
		rcall timer_delay

		dec r29
		brne buttonOne
	rjmp buttonOneHold
	
	buttonOneHold:			; If button is held longer than 2 seconds reset on release 
		sbis PINB,0
		rjmp buttonOneHold
	rjmp reset

add_Number:
	inc r19
	rjmp compare_Lock 

; Results 
;--------------------------------------------------------------------
incorrect_Lock: 
	ldi r16, underScore
	rcall display 

	ldi r29, 90				; 100ms * 90 = 9 second 
	loop9Second:
		ldi r26, 0x63		; 100ms 
		rcall timer_delay
		dec r29
		brne loop9Second 
	rjmp reset 

correct_Lock:
	sbi PORTB, 5			; LED high for correct 
	ldi r16, dot
	rcall display 
	
	ldi r29, 50				; 100ms * 50 = 5 second 
	loop5Second:
		ldi r26, 0x63		; 100ms   
		rcall timer_delay
		dec r29
		brne loop5Second 
	rjmp reset 

; Change on Array  
;--------------------------------------------------------------------
index_to_digit: ; index <- r18, digit -> r16
	ldi ZH, high(map << 1)
	ldi ZL, low(map << 1)
	add	ZL, r18
	adc ZH, r0
	lpm r16, Z
	ret

; Reset Code 
;--------------------------------------------------------------------
reset:
	ldi r16, dash 
	cbi PORTB, 5  ; Turn led off 
	rcall display ; Display dash
	ldi r18,-1    ; Reset counter to -1
	ldi r19,0x00  ; Reset the amount of numbers entered
	clt		      ; Clears T Flag 
	rjmp mainLoop

; Delay section 
;--------------------------------------------------------------------
timer_delay:
	ldi r21, 0x03
	out TCCR0B, r21
	rcall delay
	dec r26
	brne timer_delay
	ret 

delay:
	in	r21, TCCR0B		; Save configuration
	ldi r22, 0x00		; Stop timer 0
	out TCCR0B, r22

	in r22, TIFR0		; Clears overflow 
	sbr r22, 1<<ToV0	; Clear TOVO, write logic 1
	out TIFR0, r22

	out TCCR0B, r21		; Restart timer

	wait:
		in r22, TIFR0	; r22 <-- TIFRO 
		sbrs r22, TOV0	; Checks overflow flag
		rjmp wait
		ret 

; Display Section	
;--------------------------------------------------------------------
display: 
	; backup used registers on stack
	push r16
	push r17
	in r17, SREG
    push r17
	ldi r17, 8			; loop --> test all 8 bits
loop1:
	rol r16				; Rotate left trough Carry
	BRCS set_ser_in_1	; Branch if Carry is set
	cbi PORTB,1			; SER is set to 0 
	rjmp end
set_ser_in_1:
	sbi PORTB,1			; SER is set to 1
end:
	; Code to generate SRCLK pulse
	sbi PORTB,2			; SRCLK set to 1 
	cbi PORTB,2			; SRCLK set to 0 
	nop
	sbi PORTB,2
	; Code to generate RCLK pulse
	dec r17
	brne loop1
	sbi PORTB,3			; RCLK set to high 
	cbi PORTB,3			; RCLK set to low
	nop
	sbi PORTB,3
	; Restore registers from stack
	pop r17
	out SREG, r17
	pop r17
	pop r16
	
	ret
.exit