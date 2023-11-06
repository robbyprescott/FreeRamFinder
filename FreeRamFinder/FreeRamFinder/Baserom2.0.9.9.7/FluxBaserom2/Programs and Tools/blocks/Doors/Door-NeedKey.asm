; By MarioFanGamer, simplified by SJandCharlieTheCat
print "A door that you need a key to open."

db $42

JMP Return : JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP MarioInside : JMP Return

MarioInside:
	LDA $16			;\  Only enter the door if you press up.
	AND #$08		; |
	BEQ Return		;/ 
	LDA $8F			;\  Surprise: It's a backup of $72
	BNE Return		;/
	%carry_key()	;\  Does Mario or Yoshi carry a key?
    BMI Wrong		;/
	STZ !14C8,x		;   Consume the key (so that you don't carry it with you if you use a specific patch)
	LDA #$0F		;\  Enter door SFX
	STA $1DFC|!addr	;/
	
	%teleport_direct() ; uses screen exit
	RTL
	
Wrong:
    LDA #$2A			
    STA $1DFC

Return:
RTL