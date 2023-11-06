print "Forces you to drop a carried item, and you can't pick it up again."

!DisablePickingUpAgain = 1
!FreeRAM = $0EB3


db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside



MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
    LDA #$40 ; force let go of X/Y for a frame
    TRB $15
	LDA #$03 ; force let go of left or right for a frame, to prevent auto-kick
    TRB $15
	if !DisablePickingUpAgain
	LDA #$01
	STA !FreeRAM
	endif
	%erase_block()
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
RTL