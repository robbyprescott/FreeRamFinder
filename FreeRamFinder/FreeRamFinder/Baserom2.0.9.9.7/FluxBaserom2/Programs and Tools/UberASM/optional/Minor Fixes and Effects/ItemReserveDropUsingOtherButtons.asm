main:
    LDA #$01
    STA $0DF9 ; disables select from activating vanilla item box drop
	LDA $16 
	AND #$08 ; press up
	BEQ Return
	JSL $028008 ; whole item drop routine
	Return:
	RTL