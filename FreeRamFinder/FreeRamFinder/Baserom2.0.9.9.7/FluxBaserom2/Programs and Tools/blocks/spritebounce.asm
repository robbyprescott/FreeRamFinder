; By dogemaster, barely modified by SJC

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP TopCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

SpriteV:
    LDA !D8,x          ;sprites reset their y speed when on ground so this snippet make the sprite rise by 2 pixels so y speed is changeable 
    SEC
    SBC #$02
    STA !D8,x
	
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
 
    LDA !14C8,x                ; \ The address thingy that has the value if something is alive and other shit
    CMP #$08                ; | alive state
    BCC Return        ; /  
    LDA #$A8   ; sprite bounce height
    STA !AA,x                ; /
    RTL
SpriteH:
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
Cape:
Fireball: 
Return:
RTL

print "A block that bounces sprites up, but doesn't affect Mario."