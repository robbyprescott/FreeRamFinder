; Routine to get the index to the level number of the
;  tile mario is on on the overworld.

; Use: enter with A/X/Y 16-bit.
; Returns: the index to the tile at $7ED000 in X.

here:

	PHA
	LDX.w $0DD6|!addr
	LDA.w $1F1F|!addr,X
	AND.w #$000F
	STA $00
	LDA.w $1F21|!addr,X
	AND.w #$000F
	ASL
	ASL
	ASL
	ASL
	STA $02
	LDA.w $1F1F|!addr,X
	AND.w #$0010
	ASL
	ASL
	ASL
	ASL
	ORA $00
	STA $00
	LDA.w $1F21|!addr,X
	AND.w #$0010
	ASL
	ASL
	ASL
	ASL
	ASL
	ORA $02
	ORA $00
	TAX
	LDA.w $0DD6|!addr
	AND.w #$00FF
	LSR
	LSR
	TAY
	LDA.w $1F11|!addr,Y
	AND.w #$000F
	BEQ +
	TXA
	CLC
	ADC.w #$0400
	TAX
 +	PLA
	RTL