!destroy	= 1				;1 = destroy after use, 0 = don't destroy
!power 		= $A0			; How much the block will boost you, possible values are $80-$FF
!sfx		= $09			;sfx to play
!sfx_bank	= $1DFC			;sfx bank to use

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV
JMP SpriteH : JMP MarioCape : JMP MarioFireball : JMP TopCorner
JMP BodyInside : JMP HeadInside : JMP WallFeet : JMP WallBody

MarioAbove:
TopCorner:
	LDA #!power
	STA $7D
	LDA #!sfx
	STA !sfx_bank|!addr
if !destroy == 1
	%create_smoke()
	%erase_block()
endif
RTL

SpriteV:
SpriteH:
MarioSide:
BodyInside:
HeadInside:
MarioCape:
MarioFireball:
WallFeet:
WallBody:
MarioBelow:
RTL

print "When touched from above, this block shoots the player up into the air a defined height."