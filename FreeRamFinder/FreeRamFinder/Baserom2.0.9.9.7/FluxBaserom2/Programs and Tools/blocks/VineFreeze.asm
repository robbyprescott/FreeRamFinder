print "When hit from below, will slow down growing vine speed. Can't remember if you have to use this with an Uber or not."

!RAMToSetAndReset = $14AF

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
LDA !FreeRAM
BNE Return
;LDA #$FF ; #$F0 normal
;STA $0DFE 
LDA #$01
STA !RAMToSetAndReset

MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
Return:
RTL

