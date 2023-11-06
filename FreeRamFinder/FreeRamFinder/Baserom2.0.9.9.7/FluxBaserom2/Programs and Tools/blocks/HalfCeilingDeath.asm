
db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

!solid = 1


MarioCorner:
MarioAbove:
	RTL

MarioBelow:
MarioHead:

	LDA $90
	AND #$0F
	CMP #$09
	BPL Air

	LDA $7D
	BPL Air

    JSL $00F606
	LDA #$06
	STA $7D
	LDA #$01
	STA $1DF9|!addr
	BRA Air

MarioBody:
MarioSide:

	LDA $90
	AND #$0F
	CMP #$08
	BMI Air
	RTL

Air:
	SEP #$20
	LDY #$00
	LDA #$25
	STA $1693
	RTL



Fireball:
	LDA $98
	AND #$0F
	CMP #$0A
	BPL Air
	RTL

Return:
	RTL

SpriteV:
	LDA $0F
	CMP #$02
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
	ADC #$03
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
	BCS Air

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
	ORA #$08
	STA !1588,x
	JMP Air
	RTL
SpriteH:
	REP #$20
	LDA $0C
	AND #$FFF0
	CLC
	ADC #$0007
	STA $00
	SEP #$20

	LDA !1656,X
	AND #$0F
	ASL #2
	CLC
	ADC #$03
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

	BCC +
	JMP Air
	+
	RTL

Cape:
WallFeet:
WallBody:
RTL

print "This functions as a true half-tile death block for Mario from below. Should also have half-block solid interaction for sprites, but not extensively tested."