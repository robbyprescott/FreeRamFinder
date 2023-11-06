db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside


BodyInside:
MarioBelow:
MarioAbove:
HeadInside:
MarioSide:


	PHY

	LDA $15
	ORA $16
	AND #$40
	BEQ EndSpawn

	LDA $148F|!addr
	BNE EndSpawn

	JSL $02A9DE
	BMI EndSpawn

	LDA #$53	; throwblock sprite
	STA !9E,y

	
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
	JSL $07F7D2
	PLX

	LDA #$0B
	STA !14C8,y

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

print "A normal solid grab-block, except you don't have to stop and press Y in order to grab it. Instead, you'll automatically pick it up simply if you're HOLDING Y. However, looks like the spawned throwblock also has an infinite timer."