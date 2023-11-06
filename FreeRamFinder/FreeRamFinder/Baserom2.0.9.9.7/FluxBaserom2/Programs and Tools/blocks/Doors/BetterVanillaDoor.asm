db $42

JMP Return : JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP MarioInside : JMP Return

MarioInside:
	LDA $16			;\  Only enter the door if you press up.
	AND #$08		; |
	BEQ Return		;/ 
	LDA #$0F		;\  Enter door SFX
	STA $1DFC|!addr	;/
	
	%teleport_direct() ; uses screen exit, + pose/animation??
	RTL

Return:
RTL

print "Otherwise normal door that uses the set screen exit, but Mario can enter when touching any part of it, instead of the tiny vanilla door's hitbox"