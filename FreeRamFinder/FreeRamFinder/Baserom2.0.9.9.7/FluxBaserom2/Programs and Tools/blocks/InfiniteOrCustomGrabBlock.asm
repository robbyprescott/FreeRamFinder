; Sample block to spawn the custom throw block
; Just set to act 130 and copy throw block GFX in map16


db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

!Sprite = #$AC

BodyInside:
MarioBelow:
MarioAbove:
HeadInside:
MarioSide:


	PHY

	LDA $16
	AND #$40
	BEQ EndSpawn

	LDA $148F|!addr
	BNE EndSpawn

	JSL $02A9DE
	BMI EndSpawn

	LDA !Sprite
	PHX
	TYX
	STA !7FAB9E,x
	PLX

	
	LDA $94
	STA !E4,y
	LDA $95
	STA !14E0,y
	LDA $96
	STA !D8,y	
	LDA $97	
	STA !14D4,y	
	PHX
	TYX
	JSL $07F7D2|!bank8
	LDA #$08
	STA !7FAB10,x
	JSL $0187A7|!bank8
	PLX

	LDA #$01
	STA !14C8,y

	LDA #$0B
	STA !151C,y

	PHX
	REP #$10
	LDX #$0025
	%change_map16()
	SEP #$10
	PLX

	EndSpawn:
	PLY
	RTL



TopCorner:



SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "A normal grab-block, except there will be no timer for the carried sprite to make it disappear after a while. Can also be set to spawn other carryable things."