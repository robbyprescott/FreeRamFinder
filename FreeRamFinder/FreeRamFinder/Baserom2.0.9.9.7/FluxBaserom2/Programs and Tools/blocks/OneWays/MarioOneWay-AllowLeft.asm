print "One-way block for Mario only, which allows him to go left (but not back right)."

;behaves $25

!using_boost	= 0		;>if you are using boost blocks, set this to 1
				;so mario cannot glitch through them in the opposite
				;direction

print "Solid if Mario goes right"
db $37
JMP return : JMP return : JMP Check : JMP return : JMP SpriteH : JMP return
JMP MarioFireBall : JMP return : JMP Check : JMP Check : JMP wall : JMP Check

wall:
	LDA $13E3|!addr
	CMP #$07
	BEQ solid
	RTL
Check:			;>so mario wouldn't "vibrate" should there be a boost next to it.
if !using_boost > 0		;>if this statement is true, then include this:
	LDA $7B			;\if the player is going to the right
	CMP #$35		;|very fast..
	BCC playeroneway	;|
	CMP #$80		;|
	BCS playeroneway	;/
	REP #$20		;\..prevent the boosted player from going through
	LDA $9A			;|this block in the opposite direction.
	AND #$FFF0		;|
	SEC : SBC #$000E	;|
	STA $94			;|
	SEP #$20		;|
	STZ $7B			;/
	RTL
playeroneway:
endif
	REP #$20		;\compare mario's position and the block
	LDA $9A			;|(so it won't solid if mario moves
	AND #$FFF0		;|right while directly *inside* the block)
	SEC : SBC #$0009	;|
	CMP $94			;|
	SEP #$20		;|
	BCC return		;/
	BRA solid
MarioFireBall:
	LDA $1747|!addr,x		;\solid to right-moving fireballs
	BPL solid		;/
	RTL
SpriteH:
	RTL
solid:
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr		;/
return:
	RTL