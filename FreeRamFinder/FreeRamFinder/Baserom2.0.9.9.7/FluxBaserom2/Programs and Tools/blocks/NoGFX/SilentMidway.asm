print "Silent midway checkpoint."

; by KevinM

!retry_freeram = $7FB400
!retry_freeram_checkpoint = $7FB40C


db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

MarioCorner:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
MarioBody:
MarioHead:
    lda $13BF|!addr
    cmp #$25 : bcc +
    clc : adc #$DC
+   sta !retry_freeram+3
    lda #$08 : adc #$00 : sta !retry_freeram+4

    ldx $13BF|!addr
    lda $1EA2|!addr,x : ora #$40 : sta $1EA2|!addr,x
    txa : asl : tax
    rep #$20
    lda !retry_freeram+3 : sta !retry_freeram_checkpoint,x
    sep #$20
    %erase_block()
    rtl
SpriteV:
SpriteH:
Fireball:
Cape:
    rtl    		;do nothing on sprite/fireball/cape contact 

