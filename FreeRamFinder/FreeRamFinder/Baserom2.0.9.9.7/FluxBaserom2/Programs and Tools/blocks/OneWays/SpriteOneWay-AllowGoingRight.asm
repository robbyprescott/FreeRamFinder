; By HammerBrother
; Simplified by SJC

print "Solid for sprites ONLY (block-interactable sprites) when they go left, but allows right"

db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP TopCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

SpriteH:
	LDA !B6,x		;\if moving right, then return
	BEQ +			;|
	BPL Return		;/
	+
	LDA !14C8,x		;\If sprite not carryable, ignore code below
	CMP #$09		;|
	BNE +			;/
	;Prevent pulling dropped sprites in the direction opposite of 1-way:
	;
	;$0A-$0B = sprite X pos the block is touching (Much like $9A-$9B)
	;$0C-$0D = Sprite Y pos the block is touching (Much like $98-$99)
	LDA !E4,x		;\Sprite X position
	STA $00			;|
	LDA !14E0,x		;|
	STA $01			;/
	REP #$20
	LDA $0A			;
	AND #$FFF0		;>round down to nearest 16th pixel (divide by 16, round down, then multiply by 16), this is the grid block position
	SEC			;\Move push boundary 2 pixels left
	SBC #$0002		;/
	CMP $00			;>Compare with sprite's x position
	SEP #$20
	BPL Return		;>If block is too far to the right (sprite to the left) far enough, don't push sprite.
	
	LDA $0A			;\Teleport sprite to the front of the block.
	AND #$F0		;|
	CLC			;|
	ADC #$0A		;|
	STA !E4,x		;|
	LDA $0B			;|
	ADC #$00		;|
	STA !14E0,x		;/
	+
solid:
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr		;/
	RTL
SpriteV:
MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
MarioBody:
MarioHead:
WallFeet:
WallBody:
Cape:
Fireball: 
Return:
	RTL