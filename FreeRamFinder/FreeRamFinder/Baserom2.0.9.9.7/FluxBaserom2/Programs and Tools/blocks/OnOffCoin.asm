db $37

JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid

OnSolid:
	LDA $14AF
	BEQ OffAir		
	LDY #$00		
	LDA #$2C
	STA $1693	
	RTL	
OffAir:
	LDY #$00		
	LDA #$25
	STA $1693
	RTL

print "An on/off coin, toggled by the normal on/off switch. (Starts off.)"