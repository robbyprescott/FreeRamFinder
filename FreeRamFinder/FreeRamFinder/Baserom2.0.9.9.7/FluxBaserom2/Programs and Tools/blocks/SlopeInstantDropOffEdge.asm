;;Slope Fix - BTSD version
;; - by edit1754

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball : JMP TopCorner : JMP HeadInside : JMP BodyInside

MarioBelow:
MarioAbove:
SpriteV:
TopCorner:
		LDY.b #$01
		LDA.b #$D8
		STA.w $1693|!addr
MarioCape:
		RTL

MarioSide:
SpriteH:
MarioFireball:
HeadInside:
BodyInside:
		LDY.b #$01
		LDA.b #$30
		STA.w $1693|!addr
		RTL

print "Allows for an instant dropoff from a gradual or normal slope, without having to place another tile with a flat top first."