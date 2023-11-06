; Set to act as 100

!kill = 0	; if this is set the block will kill Mario instead of hurting him.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioAbove:
TopCorner:
LDA $72
BNE +
if !kill
    JSL $00F606
    else
    PHY
    JSL $00F5B7
    PLY
    endif
+
MarioBelow:
MarioSide:

BodyInside:
HeadInside:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "A one-way for Mario that only allows him to go up through it, and will kill him if he tries to go down."