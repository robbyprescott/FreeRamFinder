; by SJandCharlieTheCat

!Tile = $02D6 ; $130 for normal block

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
    LDY #$00	;act like tile 130
	LDA #$25
	STA $1693
    RTL
SpriteV:
SpriteH:
    LDY #$00	;act like tile 130
	LDA #$25
	STA $1693
	RTL
Fireball:
    LDA $170B|!addr,x
    BEQ +
    STZ $170B|!addr,x
	LDA #$10 ; magic sound. 07 for dry bones
    STA $1DF9 
    %create_smoke()
	PHX					; \ Is this needed?
	REP #$10				; |
	LDX #!Tile				; | Change into Map16 tile.
	%change_map16()				; |
	SEP #$10				; |
	PLX					; /	
    RTL
+
Return:
RTL

print "When hit by a Mario fireball, will change into an ice block (with ice physics). Can be used to change into any other block, though."