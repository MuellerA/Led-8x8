;;; ========================================================================
;;; led-8x8.asm
;;; (c) Andreas Müller
;;;     see LICENSE.md
;;; ========================================================================

	.if __MCU__ == 45
	.include "ports.attiny45.inc"
	.elseif __MCU__ == 85
	.include "ports.attiny85.inc"
	.elseif __MCU__ == 328
	.include "ports.atmega328p.inc"
	.endif

	LedPrt = PORTB
	LedDdr = DDRB
	LedPin = PINB
	LedIdx = 0

	_Zero = 1
	_LedMatrixAddrLo = 16
	_LedMatrixAddrHi = 17

	.global RndVal
	RndVal = RAMSTART
	FuncSel = RndVal + 2
	LedMatrixAddr = FuncSel + 2

;;; ========================================================================
;;; ISR_INT0
;;; ========================================================================
	.global ISR_INT0
ISR_INT0:
	;; no need to push - gets reinitialized in Main

	;; poor mans debounce
	ldi 18, 0x20
	clr 17
	clr 16
ISR_INT0Delay:
	dec 16
	brne ISR_INT0Delay
	dec 17
	brne ISR_INT0Delay
	dec 18
	brne ISR_INT0Delay

	ldi   17, lo8(RAMEND)    	
	out   SPL, 17            	; Stack Pointer Low [0x3d]
	ldi   17, hi8(RAMEND)    	
	out   SPH, 17            	; Stack Pointer High [0x3e]
	ldi   17, 0
	out   SREG, r17           	; Status Register [0x3f]

	ldi 16, 1<<6
	out 0x3a, 16		; GIFR, INTF0

	rjmp MainInt0
	
;;; ========================================================================
;;; void main()
;;; ========================================================================
	.global Main
Main:
	sbi LedDdr, LedIdx

	ldi YL, lo8(FuncSel)
	ldi YH, hi8(FuncSel)
	ldi ZL, lo8(MainTable)
	ldi ZH, hi8(MainTable)
	st Y, ZL
	std Y+1, ZH

MainInt0:
	
	;; setup GCC registers
	clr _Zero
	;; R0, T scratch
	;; R18-27,30-31 call-clobbered
	;; r2-17,28,29 call-saved

	;; find led function
	ldi YL, lo8(FuncSel)
	ldi YH, hi8(FuncSel)

	ld ZL, Y
	ldd ZH, Y+1
	lpm XL, Z+
	lpm XH, Z+

	mov 0, XL
	or 0, XH
	brne Main1

	ldi ZL, lo8(MainTable)
	ldi ZH, hi8(MainTable)
	lpm XL, Z+
	lpm XH, Z+
Main1:
	st Y, ZL
	std Y+1, ZH

	movw ZL, XL

	;; LedMatrix RAM address
	ldi _LedMatrixAddrLo, lo8(LedMatrixAddr)
	ldi _LedMatrixAddrHi, hi8(LedMatrixAddr)

	sei
	icall

MainSleep:	
	sleep
	rjmp MainSleep

MainTable:
	.word pm(Balls)
	.word pm(Pump0)
	.word pm(Pump1)
	.word pm(Flow)
	.word pm(ConstColRed)
	.word pm(ConstColGreen)
	.word pm(ConstColBlue)
	.word pm(ConstColWhite1)
	.word 0x0000		; last
	
Balls:	
	movw r24, _LedMatrixAddrLo
	rcall _ZN13LedMatrixBallC1Ev	; LedMatrixBall::LedMatrixBall()
	movw r24, _LedMatrixAddrLo
	rjmp _ZN13LedMatrixBall3RunEv 	; LedMatrixBall::Run()

Pump0:
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x00
	rcall _ZN4PumpC1Eh		; Pump::Pump(0)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN4Pump3RunEv	 	; Pump::Run()

Pump1:
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x01
	rcall _ZN4PumpC1Eh		; Pump::Pump(1)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN4Pump3RunEv	 	; Pump::Run()

Flow:
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x01
	rcall _ZN4FlowC1Eh		; Flow::Flow()
	movw r24, _LedMatrixAddrLo
	rjmp _ZN4Flow3RunEv	 	; Flow::Run()

ConstColRed:	
	movw r24, _LedMatrixAddrLo
	ldi r22, 0xff
	ldi r20, 0x00
	ldi r18, 0x00
	rcall 	_ZN8ConstColC1Ehhh 	; ConstCol::CosntCol(0xff, 0x00, 0x00)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN8ConstCol3RunEv		; ConstCol::Run()

ConstColGreen:	
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x00
	ldi r20, 0xff
	ldi r18, 0x00
	rcall 	_ZN8ConstColC1Ehhh 	; ConstCol::CosntCol(0x00, 0xff, 0x00)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN8ConstCol3RunEv		; ConstCol::Run()

ConstColBlue:	
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x00
	ldi r20, 0x00
	ldi r18, 0xff
	rcall 	_ZN8ConstColC1Ehhh 	; ConstCol::CosntCol(0x00, 0x00, 0xff)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN8ConstCol3RunEv		; ConstCol::Run()

ConstColWhite1:	
	movw r24, _LedMatrixAddrLo
	ldi r22, 0x3f
	ldi r20, 0x3f
	ldi r18, 0x3f
	rcall 	_ZN8ConstColC1Ehhh 	; ConstCol::CosntCol(0x3f, 0x3f, 0x3f)
	movw r24, _LedMatrixAddrLo
	rjmp _ZN8ConstCol3RunEv		; ConstCol::Run()

;;; ========================================================================
;;; void SendDataByte(unsigned char byte)
;;; ========================================================================
	.macro nops cnt=2
	nop
	.if \cnt-1
	nops \cnt-1
	.endif
	.endm

	.global SendDataByte
	_BitCnt = 22
	_Byte = 24
SendDataByte:
	ldi _BitCnt, 8
BitLoop:
	lsl _Byte		; 1
	brcs B1			; 1 / 2

;;; Bit	HIGH	LOW	16MHz	20MHz
;;;  0 	350ns	800ns	6/13	7/16
;;;  1	700ns	600ns	11/10	14/12

B0:
	sbi LedPrt, LedIdx	; 2
	.if MCUclock == 16000000 ; 16MHz:4
	nops 4
	.elseif MCUclock == 20000000 ; 20MHz:5
	nops 5
	.endif

	cbi LedPrt, LedIdx	; 2
	.if MCUclock == 16000000 ; 16MHz:4
	nops 4
	.elseif MCUclock == 20000000 ; 20MHZ:7
	nops 7
	.endif

	rjmp BitDec		; 2

B1:
	sbi LedPrt, LedIdx	; 2
	.if MCUclock == 16000000 ; 16MHz:9
	nops 9
	.elseif MCUclock == 20000000 ; 20MHz:12
	nops 12
	.endif

	cbi LedPrt, LedIdx	; 2
	.if MCUclock == 16000000 ; 16MHz:2
	nops 2
	.elseif MCUclock == 20000000 ; 20MHZ:5
	nops 5
	.endif

BitDec:	dec _BitCnt		; 1
	brne BitLoop		; 2|1

	ret

;;; ========================================================================
;;; void Nop()
;;; ========================================================================
	.global Nop
Nop:	nop
	nop
	nop
	nop
	ret

;;; ========================================================================
;;; void Delay()
;;; ========================================================================
Delay:

	push r16
	push r17
	push r18

	ldi r18, 0x02
	ldi r17, 0
	ldi r16, 0
DelayLoop:
	dec r16
	brne DelayLoop
	dec r17
	brne DelayLoop
	dec r18
	brne DelayLoop

	pop r18
	pop r17
	pop r16
	ret

;;; ========================================================================
;;; EOF
;;; ========================================================================
