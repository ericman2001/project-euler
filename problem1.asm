	.org $080D
	.segment "STARTUP"
	.segment "INIT"
	.segment "ONCE"
	.segment "CODE"
		
	;; KERNAL
	CHROUT = $FFD2

	;; PETSCII
	NEWLINE = $0D

	;; threes sum
	T_INC = $22
	T_SUM = $24

	;; fives sum
	F_INC = $28
	F_SUM = $30

	;; fifteens sum
	X_INC = $34
	X_SUM = $36
	
	jmp start
	
start:
	sec
	
	;; load 1000 into counters, we're counting dowN
	;; 268125
	lda #$E8		; lda #$E8, 1000; #$64, 100
	sta T_INC+1
	lda #$03
	sta T_INC
	lda T_INC+1
	sbc #1
	sta T_INC+1
	lda T_INC
	sbc #0
	sta T_INC

	sec
	lda #$E8		; lda #$E8, 1000; #$64, 100
	sta F_INC+1
	lda #$03
	sta F_INC
	lda F_INC+1
	sbc #5
	sta F_INC+1
	lda F_INC
	sbc #0
	sta F_INC

	sec
	lda #$E8		; lda #$E8, 1000; #$64, 100
	sta X_INC+1
	lda #$03
	sta X_INC
	lda X_INC+1
	sbc #10
	sta X_INC+1
	lda X_INC
	sbc #0
	sta X_INC
	
	stz T_SUM
	stz F_SUM
	stz X_SUM
	stz T_SUM+1
	stz F_SUM+1
	stz X_SUM+1
	stz T_SUM+2
	stz F_SUM+2
	stz X_SUM+2
	stz T_SUM+3
	stz F_SUM+3
	stz X_SUM+3

	
threes:
	clc
	lda T_INC+1
	adc T_SUM+3
	sta T_SUM+3
	lda T_INC
	adc T_SUM+2
	sta T_SUM+2
	lda #0
	adc T_SUM+1
	sta T_SUM+1
	lda T_INC
	adc #0
	sta T_SUM

	sec
	lda T_INC+1
	sbc #3
	sta T_INC+1
	tax
	lda T_INC
	sbc #0
	sta T_INC
	cpx #0
	bne threes
	cmp #0
	bne threes



fives:	
	clc
	lda F_INC+1
	adc F_SUM+3
	sta F_SUM+3
	lda F_INC
	adc F_SUM+2
	sta F_SUM+2
	lda #0
	adc F_SUM+1
	sta F_SUM+1
	lda #0
	adc F_SUM
	sta F_SUM

	sec
	lda F_INC+1
	sbc #5
	sta F_INC+1
	tax
	lda F_INC
	sbc #0
	sta F_INC
	cpx #0
	bne fives
	cmp #0
	bne fives

fifteens:
	
	clc
	lda X_INC+1
	adc X_SUM+3
	sta X_SUM+3
	lda X_INC
	adc X_SUM+2
	sta X_SUM+2
	lda #0
	adc X_SUM+1
	sta X_SUM+1
	lda #0
	adc X_SUM
	sta X_SUM

	sec
	lda X_INC+1
	sbc #15
	sta X_INC+1
	tax
	lda X_INC
	sbc #0
	sta X_INC
	cpx #0
	bne fifteens
	cmp #0
	bne fifteens


output:
	clc
	lda T_SUM
	jsr print_hex
	lda T_SUM+1
	jsr print_hex
	lda T_SUM+2
	jsr print_hex
	lda T_SUM+3
	jsr print_hex

	lda #NEWLINE
	jsr CHROUT

	lda F_SUM
	jsr print_hex
	lda F_SUM+1
	jsr print_hex
	lda F_SUM+2
	jsr print_hex
	lda F_SUM+3
	jsr print_hex

	lda #NEWLINE
	jsr CHROUT

	lda X_SUM
	jsr print_hex
	lda X_SUM+1
	jsr print_hex
	lda X_SUM+2
	jsr print_hex
	lda X_SUM+3
	jsr print_hex

	lda #NEWLINE
	jsr CHROUT


	clc
	lda T_SUM+3
	adc F_SUM+3
	sta F_SUM+3
	lda T_SUM+2
	adc F_SUM+2
	sta F_SUM+2
	lda T_SUM+1
	adc F_SUM+1
	sta F_SUM+1
	lda T_SUM
	adc F_SUM
	sta F_SUM

	clc
	jsr print_hex
	lda F_SUM+1
	jsr print_hex
	lda F_SUM+2
	jsr print_hex
	lda F_SUM+3
	jsr print_hex

	lda #NEWLINE
	jsr CHROUT

	sec
	lda F_SUM+3
	sbc X_SUM+3
	sta X_SUM+3
	lda F_SUM+2
	sbc X_SUM+2
	sta X_SUM+2
	lda F_SUM+1
	sbc X_SUM+1
	sta X_SUM+1
	lda F_SUM
	sbc X_SUM
	sta X_SUM

	clc
	jsr print_hex
	lda X_SUM+1
	jsr print_hex
	lda X_SUM+2
	jsr print_hex
	lda X_SUM+3
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
