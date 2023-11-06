!SprNum = $56		;number of sprite portion of mushroom block


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

BIT $15 ; 16
BVC return
JSL $02A9DE|!bank
BMI return

PHX
LDA #!SprNum
SEC
%spawn_sprite()
TAX

LDA #$08
STA !7FAB10,x
LDA #$0B
STA !14C8,x

LDA #$01
STA $1470|!addr
PLX

%erase_block()
RTL

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
return:
RTL

HeadInside:
	LDA $16			;\  Only enter the door if you press up.
	AND #$08		; |
	BEQ Return		;/ 
	LDA #$0F		;\  Enter door SFX
	STA $1DFC|!addr	;/
	
	%teleport_direct() ; uses screen exit, + pose/animation??
	Return:
	RTL


print "Otherwise normal door that uses the set screen exit, but Mario can enter when touching any part of it, instead of the tiny vanilla door's hitbox"