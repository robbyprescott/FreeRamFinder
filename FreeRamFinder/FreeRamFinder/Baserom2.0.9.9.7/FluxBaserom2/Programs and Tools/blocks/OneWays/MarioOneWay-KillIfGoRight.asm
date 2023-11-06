; Kinda janky, but whatever
; Act as 25

!kill = 0	; if this is set the block will kill Mario instead of hurting him.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:

TopCorner:
MarioAbove:
MarioSide:

BodyInside:
HeadInside:

LDA $7B			;\Must be going up.
BMI Return
if !kill
    JSL $00F606
    else
    PHY
    JSL $00F5B7
    PLY
    endif
RTL

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
RTL


print "A one-way for Mario that only allows him to go left through it, and will kill him if he tries to go right."