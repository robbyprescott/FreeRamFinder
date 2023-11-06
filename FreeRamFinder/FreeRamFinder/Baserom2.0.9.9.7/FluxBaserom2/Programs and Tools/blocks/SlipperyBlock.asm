print "Makes the level have ice physics while touching it."

!Slippery = $7E0ED3 ; FreeRAM must match SlipperyReset.asm, original $7FB500

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

BodyInside:
MarioAbove:
TopCorner:
    LDA #$03
    STA !Slippery
MarioBelow:
MarioSide:
HeadInside:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
RTL