; Modified by SJandCharlieTheCat
; Applied silent OW hex edit to get this to work properly

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
%glitter()
RTL
MarioBody:
MarioHead:
LDA #$FF	;freeze
STA $9D		;all sprites on screen....
LDA #$FF	;course clear
STA $1493	;mode
LDA #$0B	; boss end music       
STA $1DFB   ;
DEC $13C6	;prevent mario from walking
%erase_block()
SpriteV:
SpriteH:
Fireball:
Cape:
RTL    		;do nothing on sprite/fireball/cape contact 

print "ORB."