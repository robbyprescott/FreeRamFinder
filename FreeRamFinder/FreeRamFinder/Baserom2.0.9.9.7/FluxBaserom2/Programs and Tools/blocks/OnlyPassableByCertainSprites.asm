!MarioActsLike	= $0025

; By MarioE. Very minor contributions, SJC.
; Add sprites to let pass at SpriteTableStart: or CustomSpriteTableStart:

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

!NumberOfSpritesToCheck		= SpriteTableEnd-SpriteTableStart-1				;	don't change this!
!NumberOfCustomSpritesToCheck	= CustomSpriteTableEnd-CustomSpriteTableStart-1			;	don't change this!


SpriteTableStart:						;	edit these values (sprites that won't be affected)
db $00,$01,$FF,$FF
SpriteTableEnd:

CustomSpriteTableStart:						;	and these values (custom sprite number, makes it not do thing if touch)
db $FF,$FF,$FF,$FF
CustomSpriteTableEnd:

SpriteV:
SpriteH:
	LDA !7FAB10,x
	AND #$08
	BNE .customsprite

	LDA !9E,x

	PHX
	LDX.b #!NumberOfSpritesToCheck

.loop
	CMP SpriteTableStart,x
	BEQ .nothing

	DEX
	BPL .loop

.back
	PLX
	
	LDY #$01	        ;act like tile 130
    LDA #$30
    STA $1693

	RTL

.nothing
	PLX
	RTL

.customsprite
	LDA !7FAB9E,x

	PHX
	LDX.b #!NumberOfCustomSpritesToCheck

.loop2
	CMP CustomSpriteTableStart,x
	BEQ .nothing

	DEX
	BPL .loop2

	BRA .back

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:
    LDY.b #!MarioActsLike>>8
    LDA.b #!MarioActsLike
    STA $1693
MarioCape:
MarioFireball:	
Return:
	RTL

print "This will only be solid for certain sprites, but will allow others to go through. Set the exceptions in the file. (Currently only allows sprites 00 and 01 to pass: naked koopas.)"