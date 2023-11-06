print "A door toggled by the on/off switch, or whatever other trigger you want. (With an UberASM, you could also set this to appear when all sprites on-screen are destroyed, etc.)"

!FreeRAM = $14AF ; change to $1420 for Yoshi coins, and set value as whatever ($05 for conditional door)
!Value = $01

db $42

JMP Return : JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP MarioInside : JMP Return

MarioInside:
    LDA !FreeRAM
	CMP #!Value
	BNE Return
	LDA $16			;\  Only enter the door if you press up.
	AND #$08		; |
	BEQ Return		;/ 
	LDA #$0F		;\  Enter door SFX
	STA $1DFC|!addr	;/
	
	%teleport_direct() ; uses screen exit, + pose/animation??
	Return:
	RTL

print "Otherwise normal door that uses the set screen exit, but Mario can enter when touching any part of it, instead of the tiny vanilla door's hitbox"