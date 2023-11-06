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
	%erase_block()
	%glitter()				; > Create glitter effect.
SpriteV:
SpriteH:
Cape:
Fireball:
RTL

print "This block is simply erased when Mario touches it. It's used for several purposes in the baserom: a 1F0 that disappears after you touch it; disappearing indicators, etc."