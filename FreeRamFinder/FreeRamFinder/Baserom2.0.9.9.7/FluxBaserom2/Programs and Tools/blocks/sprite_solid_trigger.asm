!Trigger = $14AD ; $14AF for on/off

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody


SpriteV: 
SpriteH:
MarioFireball:
    LDA !Trigger|!addr
	BNE Return
    LDY #$01
	LDA #$30
	STA $1693|!addr
MarioBelow: 
MarioAbove: 
MarioSide:
TopCorner: 
BodyInside: 
HeadInside:
WallFeet: 
WallBody:
MarioCape:
Return:
    RTL

print "Solid for sprites, but allows Mario to pass. Fireballs won't pass."