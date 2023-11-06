db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

SpriteV:
SpriteH:
Cape:
Fireball:
RTL
MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioBody:
MarioHead:
LDA #$70
STA $13E4
WallFeet:
WallBody:
RTL



print "Gives instant p-speed"