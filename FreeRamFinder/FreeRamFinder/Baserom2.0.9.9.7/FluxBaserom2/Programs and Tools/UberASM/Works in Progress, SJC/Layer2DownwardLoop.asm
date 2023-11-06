main:
	LDA $9D		;\ If sprites locked,
	ORA $13D4|!addr
	BNE .return	;/ branch
	
	LDA $60
	BEQ +
	REP #$20
	INC $96
	SEP #$20
	LDA #$01
	STA $0F00|!addr
	BRA ++
	+
	LDA $0F00|!addr
	BEQ ++
	STZ $0F00|!addr
	LDA #$10
	STA $7D
	REP #$20
	INC $96
	SEP #$20
	++
	
	STZ $1412|!addr	; Disable vertical scroll
	DEC $1468|!addr	; Scroll layer 2 downwards
	
	LDA $1468|!addr	;\ If not time for layer 2 to return,
	BNE .return	;/ branch
	LDA #$C0	;\ Reset layer 2 position
	STA $1468|!addr	;/
	.return
	RTL