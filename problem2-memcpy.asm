	.org $080D
	.segment "STARTUP"
	.segment "INIT"
	.segment "ONCE"
	.segment "CODE"
		
	;; KERNAL
	CHROUT = $FFD2
	MEMORY_COPY = $FEE7

	;; zero page "registers"
	ZP_r0 = $02
	ZP_r1 = $04
	ZP_r2 = $06
	
	;; PETSCII
	NEWLINE = $0D

	ZP_FA = $22
	ZP_FB = $26
	ZP_FS = $32
	ZP_FC = $36
	ZP_X = $3A
	
	jmp start
	
start:
	clc

	;; FA = 1
	stz ZP_FA
	stz ZP_FA+1
	stz ZP_FA+2
	lda #1
	sta ZP_FA+3

	;; FB = 1
	stz ZP_FB
	stz ZP_FB+1
	stz ZP_FB+2
	lda #1
	sta ZP_FB+3

	;; FS = 0 - This stores the fibonacci sum, but only for even values
	stz ZP_FS
	stz ZP_FS+1
	stz ZP_FS+2
	stz ZP_FS+3

	;; kernel registers - setting static values/zeroing high bytes
	stz ZP_r0+1
	stz ZP_r1+1
	stz ZP_r2+1
	lda #4
	sta ZP_r2

while:
	;; IF FB is even, we need to add to the fib sum
	bbs0 ZP_FB+3, oddvalue
	clc
	lda ZP_FB+3
	adc ZP_FS+3
	sta ZP_FS+3
	lda ZP_FB+2
	adc ZP_FS+2
	sta ZP_FS+2
	lda ZP_FB+1
	adc ZP_FS+1
	sta ZP_FS+1
	lda ZP_FB
	adc ZP_FS
	sta ZP_FS

oddvalue:
	;; FB was odd
	;; copy FB to FC, for temp storage. We'll use this later to copy back to FA (26 cycles+memcpy)
	lda #ZP_FB
	sta ZP_r0
	lda #ZP_FC
	sta ZP_r1
	jsr MEMORY_COPY

	;; Add FA to FB to get next fib number
	clc
	lda ZP_FB+3
	adc ZP_FA+3
	sta ZP_FB+3
	lda ZP_FB+2
	adc ZP_FA+2
	sta ZP_FB+2
	lda ZP_FB+1
	adc ZP_FA+1
	sta ZP_FB+1
	lda ZP_FB
	adc ZP_FA
	sta ZP_FB
	
	;; copy the last greatest fib number to FA (FC -> FA)
	lda #ZP_FC
	sta ZP_r0
	lda #ZP_FA
	sta ZP_r1
	jsr MEMORY_COPY

	;; print current fib number
	lda ZP_FB
	jsr print_hex
	lda ZP_FB+1
	jsr print_hex
	lda ZP_FB+2
	jsr print_hex
	lda ZP_FB+3
	jsr print_hex
	lda #NEWLINE
	jsr CHROUT
	
	;; if FB < 4,000,000 then goto oddvalue
	;; $3d0900 = 4000000
	sec
	lda #$00
	sbc ZP_FB+3
	sta ZP_X+3
	lda #$09
	sbc ZP_FB+2
	sta ZP_X+2
	lda #$3D
	sbc ZP_FB+1
	sta ZP_X+1
	lda #0
	sbc ZP_FB
	sta ZP_X
	bbr7 ZP_X, while

	;; while end

	;; print FS (fib sum)
	lda ZP_FS
	jsr print_hex
	lda ZP_FS+1
	jsr print_hex
	lda ZP_FS+2
	jsr print_hex
	lda ZP_FS+3
	jsr print_hex
	lda #NEWLINE
	jsr CHROUT

	
	rts
	
	

print_hex:
	pha			; push original A to stack
	lsr
	lsr
	lsr
	lsr			; A=A >> 4
	jsr print_hex_digit
	pla			; pull original A back from stack
	and #$0F		; A=A & 0b00001111
	jsr print_hex_digit
	rts

print_hex_digit:
	cmp #$A
	bpl @letter
	ora #$30 		; PETSCII numbers: 1=$31, 2=$32, 3=$33, etc
	bra @print
	@letter:
	clc
	adc #$37		; PETSCII letters: A=$41, B=$42, etc

	@print:
	jsr CHROUT
	rts
