; custom gravity uberasm by tjb
; changes mario's gravity by a configurable amount.
; by default, sets the gravity to 2/3 of the vanilla gravity.

!higrav = 0		; set this to 1 if you want high gravity instead of low gravity.

GravityChange:
	db $02, $01	; first value is without holding A/B, second is with holding A/B
	; this is effectively subtracted from/added to the vanilla gravity values of $06, $03. (ROM addr $00D7A5)
	; by default (-$02, -$01), this results in an effective gravity of $04, $02.

main:
	LDA $1407|!addr		; \ don't mess with gravity if... mario is flying,
	ORA $9D			; | mario's movement is locked,
	ORA $13D4|!addr		; | the game is paused,
	ORA $74			; | mario's on a net/vine,
	ORA $75			; | mario's swimming,
	ORA $1493|!addr		; | or the level is over.
	BNE .ret		; /

	LDA $72			; \ don't mess with gravity if player is on the ground.
	BEQ .ret		; /

	LDA $187A|!addr		; \ if on yoshi...
	BEQ +			; |
	LDA $141E|!addr		; | don't mess with gravity if yoshi has wings.
	BNE .ret		; |
	+			; /

	LDX #$00		; \ set X to #$00 if not holding A/B
	LDA $15			; | or #$01 if holding A/B
	BPL +			; |
	INX			; |
	+			; /

	LDA $7D
if !higrav == 0
	SEC
	SBC GravityChange,X
	BVC +			; \ if that caused an underflow,
	LDA #$80		; | clamp to #$80
	+			; /
else
	BMI +			; if mario is falling
	CMP $00D7AF,X		; \ at terminal velocity,
	BCC +			; |
	LDA $00D7AF,X		; | cap mario's falling speed
	CLC			; | using the vanilla cap of #$40 + total gravity
	ADC $00D7A5,X		; /
	+
	CLC
	ADC GravityChange,X
endif
	STA $7D

.ret:
	RTL
