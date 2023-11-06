print "Teleports you to the next level UP when touched. Can be changed to down."

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioCorner:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
MarioBody:
MarioHead:
					
REP #$20
LDA $010B
INC ; DEC for down
JSL TeleportToLevel
SEP #$20
RTL

TeleportToLevel:
	STA $00
	STZ $88
	
	SEP #$30
	PHX

	LDX $95
	PHA
	LDA $5B
	LSR
	PLA
	BCC +
	LDX $97
	
+	LDA $00
	STA $19B8|!addr,x
	LDA $01
	STA $19D8|!addr,x

	LDA #$06
	STA $71
	
	PLX
	Return:
	RTL
		
SpriteV:
SpriteH:
Fireball:
Cape:
RTL    		;do nothing on sprite/fireball/cape contact 



