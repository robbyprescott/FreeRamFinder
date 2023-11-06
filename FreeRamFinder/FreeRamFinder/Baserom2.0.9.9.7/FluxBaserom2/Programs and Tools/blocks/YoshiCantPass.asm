!ZeroYoshiSpeed = 1		; If set, Yoshi will be immediately set to 0 speed. Useful for preventing Yoshi from getting through the block under any circumstances.

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
HeadInside:
	LDA $187A ; Yoshi check
	BEQ OffAir
	LDY #$01		
	LDA #$30
	STA $1693	
	RTL	
OffAir:
	LDY #$00		
	LDA #$25 
	STA $1693
	RTL

;WallFeet:	; when using db $37
;WallBody:

SpriteV:
SpriteH:
TXA					;/
INC A				;| Check if the sprite touching the block is Yoshi.
CMP $18E2|!addr		;\
BNE Return
if !ZeroYoshiSpeed
STZ !B6,x			; 0 Yoshi's speed if define is set.
endif
LDA $187A|!addr		; Return if not riding Yoshi.
BEQ Return

MarioCape:
MarioFireball:
Return:
RTL

print "Yoshi can't pass through this block, whether you're mounted on him or whether you try to yeet him through the block"