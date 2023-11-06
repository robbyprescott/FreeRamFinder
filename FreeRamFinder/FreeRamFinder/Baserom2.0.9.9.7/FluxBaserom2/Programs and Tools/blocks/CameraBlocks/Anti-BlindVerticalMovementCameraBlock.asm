; It's easier to illustrate what this block does visually
; instead of just describing it. See the original SMWC post:
; https://www.smwcentral.net/?p=section&a=details&id=25114

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead

MarioCorner:
MarioBody:
MarioHead:
MarioAbove:
MarioSide:
MarioBelow:
	LDA $72					; \ If the player is in air...
	BEQ Label_0000				; /
	LDA #$80				; \ Set $401406 to #$80
	STA $1406|!addr				; /
Label_0000:					; > --------


SpriteV:
SpriteH:
Cape:
Fireball:
RTL


print "This forces the camera to follow Mario's upward movement when you pass through it, useful for frame-perfect jumps and other times that the camera doesn't scroll up automaticlly"