;~@sa1
	TAX
	LDA $98
	AND #$F0 ; up sixteen pixels
	SEC
	SBC #$10
	STA !D8,x
	LDA $99
	SBC #$00
	STA !14D4,x
	LDA $9A
	AND #$F0
	STA !E4,x
	LDA $9B
	STA !14E0,x
	RTL
