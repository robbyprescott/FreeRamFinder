; by ASMagician Maks

; Edited by SJandCharlieTheCat, to work well with 1F0s, etc.


!ActsLike = $0025	;Acts Like number which should be used for non-Mario block interactions
!ActsLikeMario	= $0130	;Acts Like number which should be used for Mario
!AllowFireballs = 1

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody ; when using db $37

SpriteV:
SpriteH:
MarioFireball:
MarioCape:
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
     LDY.b #!ActsLikeMario>>8
     LDA.b #!ActsLikeMario
     STA $1693|!addr
Return:
     RTL

print "Solid for Mario, but allows sprites to pass. If you don't like the look of the normal yellow sprite-pass block, I've also included a block graphic in the same style as the red light switch, set to act the same as this (see 6C8)."