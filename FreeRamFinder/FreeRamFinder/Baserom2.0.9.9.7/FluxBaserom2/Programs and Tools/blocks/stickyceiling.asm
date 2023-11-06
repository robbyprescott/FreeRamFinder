print "This is a block that the player and enemies will stick to when they jump into it from below."

db $42

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioHead : JMP MarioBody

ClippingY:
db $18,$10,$10,$0D

MarioBelow:
	LDA $7D		; This block is only active for Mario when his Vertical Speed is negative.
	BPL Return	; (AKA Going upwards)

	EOR #$FF
	LSR
	LSR
	LSR		; Get the amount of pixels that Mario's Y speed makes him shift.
	LSR		; This must be stored for later.
	INC		;
	STA $00		; $00 is scratch RAM that will temporarily be used to store
	STZ $13DC|!addr	; Mario's displacement from the block.
	PHX
	LDX #$00
	LDA $73
	BNE Ducking	;
	LDA $19		; Get statusses which affect Mario's "top" clipping value.
	BNE NoPowerUp	;
Ducking:
	INX 
NoPowerUp:
	LDA $187A|!addr
	BEQ NoYoshi
	INX
	INX
NoYoshi:
	LDA ClippingY,x	; Load a value depending on Mario's status (big, ducking, on yoshi, etc)
	PLX
	CLC
	ADC $00		; Add that to the displacement value.
	STA $00	

	LDA $98		;-------------
	SEC		;
	SBC #$20
	STA $98		; Starting from the block's position - #$20...
	LDA $99
	SBC #$00
	STA $99

	LDA $98
	CLC
	ADC $00		; Then add the value from $0F
	STA $96		; ($0F = displacement from the top of the block)
	LDA $99
	ADC #$00
	STA $97

	LDA $15
	BPL DropSpeed	; If holding the B button,
	LDA #$A4	; Sets Mario's Y speed to something negative.
	STA $7D
	BRA Return

	DropSpeed:
	STZ $7D		; If not holding the B button, set Y Speed to 0.

Return:
	RTL

SpriteV:

	LDA !AA,x
	BPL Return
	
	EOR #$FF
	LSR
	LSR
	LSR
	LSR
	INC
	STA $0F
	
	LDA $98
	SEC
	SBC #$10
	STA $98
	LDA $99
	SBC #$00
	STA $99

	LDA !D8,x
	CLC
	ADC $0F
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x
	
	LDA !14C8,x
	CMP #$09
	BEQ GoUp
	CMP #$0A
	BEQ GoUp
	RTL
	
GoUp:
	LDA #$E0
	STA !AA,x
	RTL
	
MarioHead:
MarioBody:
MarioSide:
MarioCorner:
MarioAbove:
Cape:
Fireball:
SpriteH:
	LDY #$10	;act like tile 130
	LDA #$30
	STA $1693
    RTL