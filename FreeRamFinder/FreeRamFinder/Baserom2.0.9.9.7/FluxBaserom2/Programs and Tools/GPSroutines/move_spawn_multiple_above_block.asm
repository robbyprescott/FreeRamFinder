;~@sa1

!VerticalDistance = $30 ; default $10 is only a single tile above Mario. Add $10 more for each full tile length extra.

	TAX
	LDA $98
	AND #$F0 ; up sixteen pixels
	SEC
	SBC #!VerticalDistance
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