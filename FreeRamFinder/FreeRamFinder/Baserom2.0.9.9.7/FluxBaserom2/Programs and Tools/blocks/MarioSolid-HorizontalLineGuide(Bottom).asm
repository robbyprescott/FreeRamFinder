!ActsLike = $0093

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpritePass
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:

	LDY #$01
	LDA #$30
	STA $1693
	RTL

SpritePass:

	LDY.b #!ActsLike>>8		; have sprites treat this tile as if it were tile (non-solid)
	LDA.b #!ActsLike
	STA $1693 
        RTL

print "For use with the horizontal line-guide with the line at the bottom (tile 93). Allows line-guided sprites to pass through, but is solid for Mario."