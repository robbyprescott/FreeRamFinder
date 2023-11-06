print "A tiny wall ledge that will only let you stand on it as long as you're holding the correct d-pad direction against the wall."

;Act as $025

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioAbove:
TopCorner:

WallLedge:
	LDA $73          ;\If crouching, return
	BNE .Return      ;/
	LDA $15          ;\If not hold left, return
	AND.b #%00000010 ;|
	BEQ .Return      ;/

	LDA $9A          ;\Block relative to player X+3
	AND #$F0         ;|
	SEC              ;|
	SBC #$03         ;|>Number of pixels left from center of block to
	CMP $94          ;| to stand on.
	BMI .Return      ;>If block too far to the right or mario far left, return
+
	LDY #$01         ;\Act as a ledge
	STZ $1693        ;/
.Return
MarioBelow:
MarioSide:
BodyInside:
HeadInside:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
	RTL