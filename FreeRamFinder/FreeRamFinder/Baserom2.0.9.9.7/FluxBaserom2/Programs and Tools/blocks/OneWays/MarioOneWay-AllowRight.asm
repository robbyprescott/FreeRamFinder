print "One-way block for Mario only, which allows him to go right (but not back left)."

;behaves $25

!using_boost	= 0		;>if you are using boost blocks, set this to 1
				;so mario cannot glitch through them in the opposite
				;direction

print "Solid if Mario goes left"
db $37
JMP return : JMP return : JMP Check : JMP return : JMP SpriteH : JMP return
JMP MarioFireBall : JMP return : JMP Check : JMP Check : JMP wall : JMP Check

wall:
	LDA $13E3|!addr
	CMP #$06
	BEQ solid
	RTL
Check:			;>so mario wouldn't "vibrate" should there be a boost next to it.
if !using_boost > 0		;>if this statement is true, then include this:
	LDA $7B			;\if the player is going to the left
	CMP #$CA		;|very fast..
	BCS playeroneway	;|
	CMP #$80		;|
	BCC playeroneway	;/
	REP #$20		;\..prevent the boosted player from going through
	LDA $9A			;|this block in the opposite direction.
	AND #$FFF0		;|
	CLC : ADC #$000D	;|
	STA $94			;|
	SEP #$20		;|
	STZ $7B			;/
	RTL
playeroneway:
endif
	REP #$20		;\compare mario's position and the block
	LDA $9A			;|(so it won't solid if mario moves
	AND #$FFF0		;|left while directly inside the block)
	CLC : ADC #$0009	;|
	CMP $94			;|
	SEP #$20		;|
	BCS return		;/
	BRA solid
	RTL
MarioFireBall:
	LDA $1747|!addr,x		;\solid to left-moving fireballs
	BMI solid		;/
	RTL
SpriteH:
	RTL
solid:
	LDY #$01		;\become solid
	LDA #$30		;|
	STA $1693|!addr		;/
return:
	RTL