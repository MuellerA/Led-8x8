;;; generated by ../../BootSetup/BootSetup.rb (2016-05-04 21:42:09 +0200)

	.include "ports.ATtiny85.inc"	

;;; ========================================================================
;;; Interrupt Table
;;; ========================================================================

	.org  0                   	
	rjmp  RESET               	
	rjmp  ISR_INT0            	; INT0
	reti                      	; PCINT0
	reti                      	; Timer1 Compare A
	reti                      	; Timer1 Overflow
	reti                      	; Timer0 Overflow
	reti                      	; EEPROM Ready
	reti                      	; Analog Compare
	reti                      	; Analog Conversion
	reti                      	; Timer1 Compare B
	reti                      	; Timer0 Compare A
	reti                      	; Timer0 Compare B
	reti                      	; WATCHDOG
	reti                      	; USI Start
	reti                      	; USI Overflow

;;; ========================================================================
;;; Boot Setup
;;; ========================================================================

RESET:	ldi   r16, 0x00           	; 0
	out   USICR, r16          	; USI Control Register [0x0d]
	out   USISR, r16          	; USI Status Register [0x0e]
	out   DDRB, r16           	; Port B Data Direction Register [0x17]
	ldi   r17, 0x04           	; 4
	out   PORTB, r17          	; Port B Data Register [0x18]
	ldi   r17, 0x0f           	; 15
	out   PRR, r17            	; Power Reduction Register [0x20]
	out   OCR0B, r16          	; Output Compare Register B [0x28]
	out   OCR0A, r16          	; Output Compare Register A [0x29]
	out   TCCR0A, r16         	; Timer/Counter Control Register A [0x2a]
	out   TCNT0, r16          	; Timer/Counter Register [0x32]
	out   TCCR0B, r16         	; Timer/Counter Control Register B [0x33]
	ldi   r17, 0x22           	; 34
	out   MCUCR, r17          	; MCU Control Register [0x35]
	out   TIFR, r16           	; Timer/Counter Interrupt Flag Register [0x38]
	out   TIMSK, r16          	; Timer/Counter Interrupt Mask Register [0x39]
	ldi   r17, 0x40           	; 64
	out   GIMSK, r17          	; General Interrupt Mask Register [0x3b]

	ldi   r17, 0x80           	
	out   CLKPR, r17          	; Clock Prescale Register [0x26]
	ldi   r17, 0x00           	
	out   CLKPR, r17          	; Clock Prescale Register [0x26]

	ldi   r17, lo8(RAMEND)    	
	out   SPL, r17            	; Stack Pointer Low [0x3d]
	ldi   r17, hi8(RAMEND)    	
	out   SPH, r17            	; Stack Pointer High [0x3e]
	out   SREG, r16           	; Status Register [0x3f]

	rjmp  Main                	
