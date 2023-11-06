print "A block that will change a kicked sprite's state from kicked to stationary / carryable."

;; By Abdu

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

;WallFeet:	; when using db $37
;WallBody:


MarioCape:
MarioFireball:
RTL

SpriteV:
SpriteH:
    LDA !14C8,x ;\ Check if the sprite is kicked
    CMP #$0A    ;|
    BNE +       ;/ if not then return
    DEC         ; decrease A by 1 so now its 9 which is stationary / carryable state
    STA !14C8,x ; store sprite state.
    +
RTL
print "Will change the sprite's state from kicked to stationary / carryable."