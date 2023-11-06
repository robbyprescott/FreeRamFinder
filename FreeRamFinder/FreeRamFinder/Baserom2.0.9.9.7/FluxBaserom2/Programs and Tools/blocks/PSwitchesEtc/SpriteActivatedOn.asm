print "An on/off switch only activated by sprites. Customizable. (Add check for kicked sprites.)"

!ShakeEffect = 1
!Solid = 0

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside 

SpriteH:
SpriteV:
	LDA $14AF	;\If switch already pressed, return act as $25
	BNE return	;/

	INC $14AF
	LDA #$0B
	STA $1DF9	;sound number
	if !ShakeEffect
	LDA #$20
	STA $1887	;earthquake effect
	endif
Solid:
    if !Solid
	LDY #$01
	LDA #$30
	STA $1693
	endif
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
MarioFireball:
MarioCape:
return:
	RTL