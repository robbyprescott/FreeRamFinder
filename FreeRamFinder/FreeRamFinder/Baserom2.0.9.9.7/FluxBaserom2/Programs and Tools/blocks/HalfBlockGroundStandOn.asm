
db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

!Height = 8
!solid = 1

MarioHead:
	RTL
MarioCorner:
	JMP Air
MarioBelow:
	RTL

MarioAbove:

MarioBody:
	LDA $90
	AND #$0F
	CMP #($10-!Height)
	BMI Air

	if !solid = 1
	STZ $7D

	LDA #$01
	STA $1471

	STZ $1491
	;STZ $72


	REP #$20
	LDA $98
	AND #$FFF0
	SEC
	SBC #$0010+!Height
	STA $96
	SEP #$20

	LDA $187A|!addr
	BEQ +
	REP #$20
	LDA $96
	SEC
	SBC #$0010
	STA $96
	SEP #$20

	+

	LDY #$00
	LDA #$25
	STA $1693
	endif
	RTL
MarioSide:	
	LDA $1471
	BNE Air
	LDA $90
	DEC #2
	AND #$0F
	CMP #($10-!Height)
	BMI Air
	RTL


Air:
	SEP #$20
	LDY #$00
	LDA #$25
	STA $1693
	RTL





Return:
	RTL

Fireball:
	LDA $98
	INC #2
	AND #$0F
	CMP #($10-!Height)
	BMI Air
	RTL

SpriteV:
	LDA $0F
	CMP #$03
	BEQ Return

	REP #$20
	LDA $0C
	AND #$FFF0
	CLC
	ADC #$0008
	STA $00
	SEP #$20

	LDA !1656,X
	AND #$0F
	ASL #2
	CLC
	ADC #$02
	PHX
	TAX
	LDA $0190F7,X
	PLX

	STA $02
	STZ $03

	LDA !14D4,x
	XBA
	LDA !D8,x

	REP #$20
	STA $06
	CLC
	ADC $02
	CMP $00
	SEP #$20
	BCC Air

	REP #$20
	SEC
	SBC $00
	EOR #$FFFF
	INC
	CLC
	ADC $06
	SEP #$20
	STA !D8,x
	XBA
	STA !14D4,x
	STZ !AA,x
	LDA !1588,x
	ORA #$04
	STA !1588,x
	JMP Air
	RTL
SpriteH:
	REP #$20
	LDA $0C
	AND #$FFF0
	CLC
	ADC #$0009
	STA $00
	SEP #$20

	LDA !1656,X
	AND #$0F
	ASL #2
	CLC
	ADC #$02
	PHX
	TAX
	LDA $0190F7,X
	PLX

	STA $02
	STZ $03

	LDA !14D4,x
	XBA
	LDA !D8,x

	REP #$20
	CLC
	ADC $02
	CMP $00
	SEP #$20

	BCS +
	JMP Air
	+
	RTL

Cape:
WallFeet:
WallBody:
RTL

print "This functions as a true solid half-tile (ground) block for Mario and sprites. Not extensively tested."