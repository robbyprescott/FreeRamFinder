; SJC: Note that because of the way this is set up, it won't ever act solid for Mario, if you have i-frames.
; So I've set it to insta-kill by default.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Pixel perfect spike
;	by MarioFanGamer
; Okay, the spike isn't entirely pixel perfect since it's
; build on top of the interaction point system but (meaning
; gaps aren't considered but you get the deal that it's still
; more accurate than a rectangular hitbox, though it also
; isn't solid as a result.
;
; The direction is determined by the lowest two bits of the
; Map16 tile number i.e. divide the value by 4 and take the
; remainder.
; Insert it as a range e.g. "200-203 pixel_perfect_spike.asm"
; as only then the Map16 number is taken into account.
;
; Directions are:
;	0 = Upwards
;	1 = Downwards
;	3 = Right
;	2 = Left
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!HurtRoutine = !KillPlayer	; Can be HurtPlayer or KillPlayer

!HurtPlayer = $00F5B7|!addr
!KillPlayer = $00F606|!addr

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallSide

MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioInside:
MarioHead:
WallRun:
	PHY
	LDA $03
	AND #$03
	ASL
	TAX
	JSR (SpikePtrs,x)
	REP #$20
	LDA SpikeHitbox,y
	AND Bitflags,x
	SEP #$20
	BEQ .NotTouched
	JSL !HurtRoutine
.NotTouched:
	PLY

WallSide:
RTL
SpriteV:
SpriteH:
    LDY #$10	;act like tile 130
	LDA #$30
	STA $1693
Cape:
Fireball:
RTL

SpikePtrs:
dw .Downwards
dw .Upwards
dw .Right
dw .Left

.Downwards:
	LDA $98
	AND #$0F
	ASL
	TAY
	LDA $9A
	AND #$0F
	ASL
	TAX
RTS

.Upwards:
	LDA $98
	AND #$0F
	EOR #$0F
	INC
	ASL
	TAY
	LDA $9A
	AND #$0F
	ASL
	TAX
RTS

.Right:
	LDA $9A
	AND #$0F
	EOR #$0F
	INC
	ASL
	TAY
	LDA $98
	AND #$0F
	ASL
	TAX
RTS

.Left:
	LDA $9A
	AND #$0F
	ASL
	TAY
	LDA $98
	AND #$0F
	ASL
	TAX
RTS

Bitflags:
dw $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
dw $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001

SpikeHitbox:
dw %0000000110000000
dw %0000000110000000
dw %0000001111000000
dw %0000001111000000
dw %0000011111100000
dw %0000011111100000
dw %0000111111110000
dw %0000111111110000
dw %0001111111111000
dw %0001111111111000
dw %0011111111111100
dw %0011111111111100
dw %0111111111111110
dw %1111111111111111
dw %1111111111111111
dw %1111111111111111

print "A spike with pixel perfect interaction. Unfortunately can't be used as a Mario solid. Set to insta-kill Mario by default, but you can change this."