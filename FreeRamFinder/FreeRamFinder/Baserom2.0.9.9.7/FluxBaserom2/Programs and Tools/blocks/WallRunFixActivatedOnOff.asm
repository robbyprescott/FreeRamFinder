db $37 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody ; when using db $37


WallFeet:	; when using db $37
WallBody:

LDA $19
CMP #$02 ; cape check
BNE Return
LDA $16
AND #$40 ; press Y or X
BEQ Return
LDA $14AF
EOR #$01
STA $14AF

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
RTL

print "On/off switch which can be activated by cape while wall-running. (A patch otherwise disabled this.) Can set to other act-as, too. You can copy the relevant code to other blocks if needed, too."
