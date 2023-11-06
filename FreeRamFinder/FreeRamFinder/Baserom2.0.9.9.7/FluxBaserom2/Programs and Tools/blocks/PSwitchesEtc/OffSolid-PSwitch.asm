db $37

JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid

OnSolid:
	LDA $14AD
	BEQ OffAir
	LDY #$01		
	LDA #$30
	STA $1693	
	RTL	
OffAir:
	LDY #$00		
	LDA #$25
	STA $1693
	RTL

print "A regular on-off block, which only becomes solid when the p-switch is activated"