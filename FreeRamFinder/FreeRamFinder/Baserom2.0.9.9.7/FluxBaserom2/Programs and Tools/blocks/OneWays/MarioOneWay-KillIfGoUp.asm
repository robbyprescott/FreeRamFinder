; Kinda janky, but whatever
; Act as 25

!kill = 0	; if this is set the block will kill Mario instead of hurting him.

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
LDA $7D			;\Must be going up.
BPL Return
if !kill
    JSL $00F606
    else
    PHY
    JSL $00F5B7
    PLY
    endif
+
TopCorner:
MarioAbove:
MarioSide:

BodyInside:
HeadInside:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
RTL


print "A one-way for Mario that only allows him to go down through it, and will kill him if he tries to go up."