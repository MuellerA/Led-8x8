;;; ========================================================================
;;; led-8x8.asm
;;; (c) Andreas Müller
;;;     see LICENSE.md
;;; ========================================================================

	.if __MCU__ == 45
	.include "ports.attiny45.inc"
	.elseif __MCU__ == 328
	.include "ports.atmega328p.inc"
	.endif

	LEDCNT = 64
	LedPrt = PORTB
	LedDdr = DDRB
	LedPin = PINB
	LedIdx = 0

	RamLedAddr = RAMSTART + 0x400
	RamLedSize = LEDCNT * 3
	RamBallAddr = RamLedAddr + RamLedSize
	RamBallSize = 30 ; MemBallSize * MemBallCount

	.global Main
Main:
	_RamBallAddrL = 10
	_RamBallAddrH = 11
	_RamLedAddrL  = 12
	_RamLedAddrH  = 13

	sbi LedDdr, LedIdx

	ldi r16, hi8(RamBallAddr)
	mov _RamBallAddrH, r16
	ldi r16, lo8(RamBallAddr)
	mov _RamBallAddrL, r16
	ldi r16, hi8(RamLedAddr)
	mov _RamLedAddrH, r16
	ldi r16, lo8(RamLedAddr)
	mov _RamLedAddrL, r16

	rcall BallInit		; (BallAddr)
MainLoop:
	rcall BallMove		; (RamBallAddr)
	rcall BallToLed		; (RamBallAddr, RamLedAddr)
	rcall FlushLed		; (RamLedAddr)
	rcall Delay

	rjmp MainLoop

;;; ========================================================================
;;; BallToLed
;;; In:
;;; r10	RamLedAddr
;;; r12	RamBallAddr
BallToLed:
	_RamBallAddr = 10
	_RamLedAddr  = 12
	_ByteCnt = 16
	_X = 17
	_Y = 18
	_Tmp = 19
	_Tmp2 = 20

	push ZH
	push ZL
	push YH
	push YL
	push _Tmp
	push _X
	push _Y

	movw ZL, _RamLedAddr
	ldi _ByteCnt, 3 * LEDCNT
	clr _Tmp
BallToLed1:
	st Z+, _Tmp
	dec _ByteCnt
	brne BallToLed1

	movw ZL, _RamLedAddr
	movw YL, _RamBallAddr
	rcall BallToLed2
	movw ZL, _RamLedAddr
	adiw YL, MemBallSize
	rcall BallToLed2
	movw ZL, _RamLedAddr
	adiw YL, MemBallSize
	rcall BallToLed2

	pop _Y
	pop _X
	pop _Tmp
	pop YL
	pop YH
	pop ZL
	pop ZH
	ret

BallToLed2:
	ldd _X, Y + mX
	ldd _Y, Y + mY

	lsr _X
	lsr _X
	lsr _X
	lsr _X
	lsr _X

	lsr _Y
	lsr _Y
	mov _Tmp, _Y
	lsr _Y
	lsr _Y
	lsr _Y
	andi _Tmp, 0x38

	or _Tmp, _X
	mov _Tmp2, _Tmp
	lsl _Tmp
	add _Tmp, _Tmp2

	add ZL, _Tmp
	brcc BallToLed2a
	inc ZH
BallToLed2a:

	_Green = 20
	_Red   = 21
	_Blue  = 22
	ldd _Green, Y + mGreen
	ldd _Red  , Y + mRed
	ldd _Blue , Y + mBlue

	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue

	lsr _Green
	lsr _Green
	lsr _Green
	lsr _Red
	lsr _Red
	lsr _Red
	lsr _Blue
	lsr _Blue
	lsr _Blue

	cpi _X, 0x00
	breq BallToLed2a1
	sbiw ZL, 3
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	adiw ZL, 3
BallToLed2a1:
	cpi _X, 0x07
	breq BallToLed2a2
	adiw ZL, 3
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	sbiw ZL, 3
BallToLed2a2:
	cpi _Y, 0x00
	breq BallToLed2a3
	sbiw ZL, 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	adiw ZL, 3 * 8
BallToLed2a3:
	cpi _Y, 0x07
	breq BallToLed2a4
	adiw ZL, 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	sbiw ZL, 3 * 8
BallToLed2a4:
	lsr _Green
	lsr _Red
	lsr _Blue

	cpi _X, 0x00
	breq BallToLed2a5
	cpi _Y, 0x00
	breq BallToLed2a5
	sbiw ZL, 3 + 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	adiw ZL, 3 + 3 * 8
BallToLed2a5:
	cpi _X, 0x07
	breq BallToLed2a6
	cpi _Y, 0x07
	breq BallToLed2a6
	adiw ZL, 3 + 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	sbiw ZL, 3 + 3 * 8
BallToLed2a6:
	cpi _X, 0x07
	breq BallToLed2a7
	cpi _Y, 0x00
	breq BallToLed2a7
	sbiw ZL, -3 + 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	adiw ZL, -3 + 3 * 8
BallToLed2a7:
	cpi _X, 0x00
	breq BallToLed2a8
	cpi _Y, 0x07
	breq BallToLed2a8
	adiw ZL, -3 + 3 * 8
	std Z + 0, _Green
	std Z + 1, _Red
	std Z + 2, _Blue
	sbiw ZL, -3 + 3 * 8
BallToLed2a8:

	ret

;;; ========================================================================
;;; FlushLed
;;; In
;;; r12 _RamLedAddr
;;;
	_RamLedAddr = 12
	_ByteCnt  = 16
	_BitCnt   = 17
	_Data     = 18

	.macro nops cnt=2
	nop
	.if \cnt-1
	nops \cnt-1
	.endif
	.endm

FlushLed:
	push ZH
	push ZL
	push _Data
	push _BitCnt
	push _ByteCnt

	movw ZL, _RamLedAddr
	ldi _ByteCnt, 3 * LEDCNT
ByteLoop:
	ld _Data, Z+		; 3
	ldi _BitCnt, 0x08	; 1
BitLoop:
	lsl _Data		; 1
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

	dec _ByteCnt		; 1
	brne ByteLoop		; 2|1

	pop _ByteCnt
	pop _BitCnt
	pop _Data
	pop ZL
	pop ZH
	ret

;;; ========================================================================
;;; Delay
Delay:

	push r16
	push r17
	push r18

	ldi r18, 2
	ldi r17, 0x80
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
