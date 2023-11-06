; Sprite only triangle
; Revision of HammerBro one-way blocks by SJandCharlieTheCat
; Will work in layer 2 levels

!SolidOtherDirection = 0   ; set to 1 if you want the non-sloped part of the triangle
                           ; to act as solid for sprites when kicked toward it, instead of as air



db $37


JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP TopCorner : JMP MarioBody : JMP MarioHead
JMP WallFeet : JMP WallBody

SpriteH:
	LDA !B6,x		;\if moving right, then return
	BEQ +			;|
	BPL Bounce		;/
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
	BPL Bounce		;>If block is too far to the right (sprite to the left) far enough, don't push sprite.
	
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
    if !SolidOtherDirection = 1
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr		;/
	else
	LDY #$00		;\become solid
	LDA #$25		;|
	STA $1693|!addr		;/
	endif
	RTL
Bounce:
    LDA !D8,x          ;sprites reset their y speed when on ground so this snippet make the sprite rise by 2 pixels so y speed is changeable 
    SEC
    SBC #$02
    STA !D8,x
	
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
	
    LDA !14C8,x                
    CMP #$0A                ; | kicked state
    BCC Return        ; /  
    LDA #$BD   ; sprite bounce height
    STA !AA,x                ; /
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

print "Sprite only triangle, will bounce kicked sprites if they're going rightward"