db $37

JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid

OnSolid:
	LDA $14AF
	BNE OffAir
	LDY #$01		
	LDA #$30
	STA $1693	
	RTL	
OffAir:
	LDY #$00		
	LDA #$25 
	STA $1693
	RTL

print "A regular on-off block, solid when the switch is on"