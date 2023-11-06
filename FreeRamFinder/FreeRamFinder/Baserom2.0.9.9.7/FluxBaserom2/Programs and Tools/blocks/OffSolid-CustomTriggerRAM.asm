db $37

JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid : JMP OnSolid
JMP OnSolid : JMP OnSolid

OnSolid:
    LDA $7FC0FC ; ExAnimation
	AND #$01
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

print "An on-off block which only becomes solid when the switch is turned off, but which is triggered by a different switch and RAM address ($7FC0FC) than the normal $14AF switch."