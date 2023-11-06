print "Gives you two coins. Half-block version, only when you touch coin itself."

; Based on
; Pixel perfect spike
; by MarioFanGamer

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallSide

MarioBelow:
MarioSide:
MarioInside:
MarioHead:
WallRun:
WallSide:
MarioAbove:
MarioCorner:
    PHY
	LDA $98
	AND #$0F
	ASL
	TAY
	LDA $9A
	AND #$0F
	ASL
	TAX
	REP #$20
	LDA SpikeHitbox,y
	AND Bitflags,x
	SEP #$20
	BEQ .NotTouched
	LDA #$01   ; coin sound
    STA $1DFC 
	LDA #$02   ; give two coins
	STA $13CC
	%erase_block()
	%glitter()				; > Create glitter effect.
	PLY
	RTL
.NotTouched:
    ; You can put a second code here if you want, too. E.g. LDA #$02
	;                                                       STA $19
	PLY
SpriteV:
SpriteH:
Cape:
Fireball:
RTL

Bitflags:
dw $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
dw $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

SpikeHitbox:
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111
dw %0000000011111111