!SFX = $22
!Port = $1DFC

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP MarioAbove : JMP MarioAbove : JMP MarioAbove

MarioAbove:
MarioBelow:
MarioSide:
	LDA #$02 ; changed from 01
	STA $0100|!addr
	;LDA #!SFX
	;STA !Port|!addr
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
	RTL

print "Brings the player back to the title screen when touched."