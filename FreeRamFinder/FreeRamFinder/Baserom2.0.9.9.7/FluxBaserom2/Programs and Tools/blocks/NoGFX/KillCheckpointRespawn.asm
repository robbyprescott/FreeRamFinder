print "Kills your checkpoint."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Checkpoint Tweak Blocks - by dtothefourth
;
; This block clears the checkpoint
;
; Requires the retry patch by worldpeace
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

db $42 ; enable corner and inside offsets
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP BodyInside : JMP HeadInside

if !sa1
	!freeram_checkpoint = $40B40C
else
	!freeram_checkpoint = $7FB40C
endif

MarioBelow:
MarioSide:
MarioCorner:
HeadInside:
BodyInside:
MarioAbove:
	LDA #$00
	STA $13CE|!addr

	LDA $13BF|!addr
	CMP #$25
	BCC +
	CLC
	ADC #$DC
	+
	STA $7FB403
	LDA #$00
	ADC #$00
	-
	STA $7FB404

	LDA $13BF|!addr
	ASL
	TAX
	LDA #$00
	STA !freeram_checkpoint,x
	STA !freeram_checkpoint+1,x 
MarioFireBall:
SpriteV:
SpriteH:
MarioCape:
	RTL
	