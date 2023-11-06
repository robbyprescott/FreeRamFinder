!NumberOfCoins = $02 
!ActsLikeWhenNotEnoughCoins = $0130
!NewActsLike = $0025

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

LDA $0DBF   ; Load coins
CMP #!NumberOfCoins  ; Check if enough
BCS Return  ; If >=, Enough

LDY.b #!ActsLikeWhenNotEnoughCoins>>8
LDA.b #!ActsLikeWhenNotEnoughCoins
STA $1693
RTL

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
LDY.b #!NewActsLike>>8
LDA.b #!NewActsLike
STA $1693
RTL

print "Solid for Mario unless he has the defined number of coins."
