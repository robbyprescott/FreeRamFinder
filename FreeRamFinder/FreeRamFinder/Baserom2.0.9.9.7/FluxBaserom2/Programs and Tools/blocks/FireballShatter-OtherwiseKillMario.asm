; by SJandCharlieTheCat

!Instakill = 1 ; change to 0 to hurt

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

Cape:
RTL
MarioCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
MarioBelow:
MarioAbove:
MarioSide:
    if !Instakill
    JSL $00F606
    else
    PHY
    JSL $00F5B7
    PLY
    endif
    RTL
SpriteV:
SpriteH:
    LDY #$10	;act like tile 130
	LDA #$30
	STA $1693
	RTL
Fireball:
    LDA $170B|!addr,x
    BEQ +
    STZ $170B|!addr,x
	LDA #$17 ; Bowser fireball sound
    STA $1DFC
    %create_smoke()
    %erase_block()
    +
    RTL

print "Death block, but will be destroyed by a Mario fireball."