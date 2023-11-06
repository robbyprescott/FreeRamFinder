print "Gives you two coins."


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
    LDA #$01   ; coin sound
    STA $1DFC 
	LDA #$02   ; give two coins
	STA $13CC
	%erase_block()
	%glitter()				; > Create glitter effect.
SpriteV:
SpriteH:
Cape:
Fireball:
RTL

