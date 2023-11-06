; By HammerBro, modifications by SJC
;This solid block can only be shattered by kicked shells and throwblock

; Note that if a sprite is kicked up against the side or bottom corner of the block, 
; it can sometimes act as solid and kill the throwblock (or only destroy one block if shell)

!SpriteGoesRightThroughWithoutBouncingBack = 1

db $42
JMP return : JMP return : JMP return : JMP SpriteV : JMP SpriteH : JMP return
JMP return : JMP return : JMP return : JMP return


SpriteV:
    LDA $9E,x		;\if not 
	CMP #$04		;|
	BEQ vert		;/return
	CMP #$05		;|
	BEQ vert		;/return
	CMP #$06		;|
	BEQ vert		;/return
	CMP #$07		;|
	BEQ vert		;/return
	CMP #$08		;|
	BEQ vert		;/return
	CMP #$53		;|
	BNE return		;/return
vert:	
	LDA $AA,x		;\if not kicked upwards..
	BPL return		;|
	LDA $14C8,x		;|
	CMP #$09		;|
	BNE return		;/return
	if !SpriteGoesRightThroughWithoutBouncingBack
	LDY #$00
	LDA #$25
	STA $1693
	endif
	LDA $0F		;\so the sprite doesn't go up through the bottom of the block
	PHA		;/and pushed sideways, as if the bottom is behaving 25 but stuck in walls.
	JSL shatterblkh	;>shatter the block.
	PLA		;\and end the "through the block" protection.
	STA $0F		;/
return:
	RTL
SpriteH:
    LDA $9E,x		;\if not 
	CMP #$04		;|
	BEQ horiz		;/return
	CMP #$05		;|
	BEQ horiz		;/return
	CMP #$06		;|
	BEQ horiz		;/return
	CMP #$07		;|
	BEQ horiz		;/return
	CMP #$08		;|
	BEQ horiz		;/return
	CMP #$53		;|
	BNE return		;/return
horiz:
	LDA $B6,x		;\if sprite lacks x speed,
	BEQ return		;/return
	LDA $14C8,x		;\if sprite "dropped"
	CMP #$09		;|
	BEQ shatterblkh		;/shatter the block (and the sprite itself)
	CMP #$0A		;\if not "kicked"
	BNE return		;/then return
	if !SpriteGoesRightThroughWithoutBouncingBack
	LDY #$00
	LDA #$25
	STA $1693
	endif
shatterblkh:
	%sprite_block_position()
	LDA #$38
	STA $1DFC
	%create_smoke()
	%erase_block()
	RTL
	
	print "Solid for Mario, but will be shattered by kicked shells and throwblocks. Kicked shells won't bounce back when they hit it, although you can change this in the settings."