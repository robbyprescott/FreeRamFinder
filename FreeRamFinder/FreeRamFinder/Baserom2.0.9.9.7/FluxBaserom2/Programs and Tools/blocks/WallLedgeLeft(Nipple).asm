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
	LDA $15          ;\If not hold right, return
	AND.b #%00000001 ;|
	BEQ .Return      ;/

	LDA $9A          ;\
	AND #$F0         ;|>Center within 16x16 grid (round down)
	ORA #$02         ;|>Number of pixels right from center of block to
	CMP $94          ;| to stand on.
	BEQ +            ;|>If equal to the position, allow standing
	BPL .Return      ;>If block too far to the right or mario far left, return
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
