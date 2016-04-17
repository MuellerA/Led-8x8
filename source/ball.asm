;;; ========================================================================
;;; ball.asm
;;; (c) Andreas Müller
;;;     see LICENSE.md
;;; ========================================================================

;;; struct Ball
;;; {
;;;   uint8 x, y;    // [0], [1]        0..255
;;;   uint8 dx, dy;  // [2], [3]        -16 .. -5, +5 .. +16
;;;   uint8 g, r, b; // [4], [5], [6]   0..128
;;;   uint8 dg, dr, db // [7], [8], [9] -16 .. -5, +5 .. +16
;;; }

	.if __MCU__ == 45
	.include "ports.attiny45.inc"
	.elseif __MCU__ == 328
	.include "ports.atmega328p.inc"
	.endif
	
;;; RAM
	
	ballA = 0x00
	ballB = 0x0a
	ballC = 0x14

	.global MemBallSize
	.global MemBallCount

	MemBallCount = 3
	MemBallSize = 10
	
	.global mX
	.global mY
	.global mGreen
	.global mRed
	.global mBlue
	mX  = 0
	mY  = 1
	mDX = 2
	mDY = 3
	mGreen  = 4
	mRed    = 5
	mBlue   = 6
	mDGreen = 7
	mDRed   = 8
	mDBlue  = 9

;;; ========================================================================
;;; Init
;;; In:
;;; r10	_RamBallAddr
;;; Out:
	.global BallInit
BallInit:
	_RamBallAddr = 10
	_Size = 16
	_Tmp = 0

	push ZH
	push ZL
	push YH
	push YL
	push _Size
	push _Tmp

	movw YL, _RamBallAddr
	ldi ZH, hi8(BallInitData)
	ldi ZL, lo8(BallInitData)
	ldi _Size, MemBallSize * MemBallCount

BallInitLoop:
	lpm _Tmp, Z+
	st Y+, _Tmp
	dec _Size
	brne BallInitLoop

	pop _Tmp
	pop _Size
	pop YL
	pop YH
	pop ZL
	pop ZH
	ret

BallInitData:
	.byte 0x42, 0x46,   0x05, 0xf1,   0x12, 0x52, 0x13,   0x05, 0x08, 0xf3
	.byte 0xd7, 0xdd,   0x0c, 0xf4,   0x53, 0x1c, 0x61,   0x05, 0x08, 0xf3
	.byte 0xaa, 0x77,   0x08, 0xfa,   0x11, 0x60, 0x22,   0x05, 0x08, 0xf3

;;; ========================================================================
;;; BallMove
;;; In:
;;; r10	RamBallAddr
	.global BallMove
BallMove:
	_Rnd = 0
	_RamBallAddr = 10
	_Val = 16
	_Delta = 17
	_Tmp = 18

	push YH
	push YL
	push _Tmp
	push _Delta
	push _Val

	movw YL, _RamBallAddr
	rcall BallMove1
	adiw YL, MemBallSize
	rcall BallMove1
	adiw YL, MemBallSize
	rcall BallMove1
	
	pop _Val
	pop _Delta
	pop _Tmp
	pop YL
	pop YH
	ret

BallMove1:
	ldd _Val, Y + mX
	ldd _Delta, Y + mDX
	rcall BallMoveXY
	std Y + mX, _Val
	std Y + mDX, _Delta

	ldd _Val, Y + mY
	ldd _Delta, Y + mDY
	rcall BallMoveXY
	std Y + mY, _Val
	std Y + mDY, _Delta

	ldd _Val, Y + mGreen
	ldd _Delta, Y + mDGreen
	rcall BallMoveCol
	std Y + mGreen, _Val
	std Y + mDGreen, _Delta
	
	ldd _Val, Y + mRed
	ldd _Delta, Y + mDRed
	rcall BallMoveCol
	std Y + mRed, _Val
	std Y + mDRed, _Delta
	
	ldd _Val, Y + mBlue
	ldd _Delta, Y + mDBlue
	rcall BallMoveCol
	std Y + mBlue, _Val
	std Y + mDBlue, _Delta
	
	ret

BallMoveXY:
	cpi _Val, 0x10
	brcc BallMoveXY1
	rcall RandomXY
	mov _Delta, _Rnd
	rjmp BallMoveXY2
BallMoveXY1:
	cpi _Val, 0xf1
	brlo BallMoveXY2
	rcall RandomXY
	com _Rnd
	mov _Delta, _Rnd
BallMoveXY2:
	add _Val, _Delta

	ret

BallMoveCol:
	cpi _Val, 0x10
	brcc BallMoveCol1
	rcall RandomXY
	lsr _Rnd
	lsr _Rnd
	mov _Delta, _Rnd
	rjmp BallMoveCol2
BallMoveCol1:
	cpi _Val, 0x71
	brlo BallMoveCol2
	rcall RandomXY
	lsr _Rnd
	lsr _Rnd
	lsr _Rnd
	lsr _Rnd
	com _Rnd
	mov _Delta, _Rnd
BallMoveCol2:
	add _Val, _Delta

	ret
	
;;; ========================================================================
;;; RandomXY (+5..+15)
;;; In:
;;; r10	RamBallAddr
;;; Out:
;;; r0	random
RandomXY:
	_Rnd = 0
	_Tmp = 16

	push _Tmp
	
	rcall RandomSum
	ldi _Tmp, 0x0f
	and _Tmp, _Rnd
	cpi _Tmp, 0x05
	brcc RandomXY1
	ldi _Tmp, 0x05
RandomXY1:
	mov _Rnd, _Tmp
	
	pop _Tmp
	ret
	
;;; ========================================================================
;;; RandomSum
;;; In:
;;; r10	RamBallAddr
;;; Out:
;;; r0	random[0..255]
RandomSum:
	_RamBallAddr = 10
	_Tmp = 16
	_Size = 17
	_Rnd = 0

	push YH
	push YL
	push _Tmp
	push _Size

	movw YL, _RamBallAddr
	
	ldi _Size, MemBallSize * MemBallCount
RandomSumLoop:	
	ld _Tmp, Y+
	
	ror _Tmp
	neg _Tmp
	ror _Tmp
	add _Rnd, _Tmp

	dec _Size
	brne RandomSumLoop
	
	pop _Size
	pop _Tmp
	pop YL
	pop YH
	ret

