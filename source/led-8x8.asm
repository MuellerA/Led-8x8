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

	LedPrt = PORTB
	LedDdr = DDRB
	LedPin = PINB
	LedIdx = 0

	_Zero = 1
	_LedMatrixAddrHi = 17
	_LedMatrixAddrLo = 16

	.global RndVal
	RndVal = RAMSTART
	LedMatrixAddr = RndVal + 2

;;; ========================================================================
;;; void main()
;;; ========================================================================
	.global Main
Main:
	sbi LedDdr, LedIdx
	
	;; setup GCC registers
	clr _Zero
	;; R0, T scratch
	;; R18-27,30-31 call-clobbered
	;; r2-17,28,29 call-saved

	;; LedMatrix RAM address
	ldi _LedMatrixAddrHi, hi8(LedMatrixAddr)
	ldi _LedMatrixAddrLo, lo8(LedMatrixAddr)

	;; LedMatrix constructor()
	movw r24, _LedMatrixAddrLo
	rcall _ZN9LedMatrixC1Ev
MainLoop:
	;; void LedMatrix.Update()
	movw r24, _LedMatrixAddrLo
	rcall _ZN9LedMatrix6UpdateEv

	rcall SendData

	rcall Delay

	rjmp MainLoop

;;; ========================================================================
;;; void SendData()
;;; ========================================================================
	_Data = 13
	_ByteCnt = 14
SendData:
	;; unsigned char* LedMatrix.Data()
	movw r24, _LedMatrixAddrLo
	rcall _ZNK9LedMatrix4DataEv
	movw YL, r24

	;; unsigned short LedMatrix.Size()
	movw r24, _LedMatrixAddrLo
	rcall _ZN9LedMatrix4SizeEv
	mov _ByteCnt, r24

SendDataLoop:
	ld _Data, Y+
	tst _Data
	breq SendDataSixZeros

SendDataSixXXX:
	;; void LedMatrix.GetCol(unsigned char)
	movw r24, _LedMatrixAddrLo
	mov r22, _Data
	rcall _ZNK9LedMatrix6GetColEh

	dec _ByteCnt
	brne SendDataLoop
	ret

SendDataSixZeros:
	clr r24
	rcall SendDataByte
	rcall SendDataByte
	rcall SendDataByte
	rcall SendDataByte
	rcall SendDataByte
	rcall SendDataByte

	dec _ByteCnt
	brne SendDataLoop
	ret

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
