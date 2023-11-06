; by ASMagician Maks

; Edited by SJandCharlieTheCat, to work well with 1F0s, etc.

!Instakill = 1 ; change to 1 to not just damage Mario (e.g. when big), but always kill. (Need to add star check.)
!ActsLike	= $0130	;Acts Like number which should be used for non-Mario block interactions
!BlockSprite = 1   ;By default, vine will eat through it. Set as 1 to change.
;!ActsLikeMario	= $012F	;Acts Like number which should be used for Mario

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody


SpriteV:
SpriteH:
if !BlockSprite = 1
LDA !9E,x
CMP #$79   ;  vine
BEQ MarioBelow
endif

LDY.b #!ActsLike>>8
LDA.b #!ActsLike
STA $1693|!addr
BRA Return

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:

    if !Instakill
    JSL $00F606
    else
    PHY
    JSL $00F5B7
    PLY
    endif
MarioCape:
MarioFireball:
Return:
RTL

print "Kills Mario instantly, even if on Yoshi."