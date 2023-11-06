main:
    LDA $0E00 ; 
	BNE	GiveMeBackThePipe ; unless $0E00 set...
	LDA #$5E ; Allows upside down slopes in other tilesets (0 and 7)
	STA $82
	BRA End
	GiveMeBackThePipe:
	LDA #$C8 ; restore
	STA $82
	End:
	LDA #$E5
	STA $83
	RTL