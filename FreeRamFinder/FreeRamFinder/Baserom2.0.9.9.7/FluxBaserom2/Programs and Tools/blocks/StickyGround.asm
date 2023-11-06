; A block that halts the player from above.
;	by quietmason

; to prevent Mario from turning around while on the block, change to 1.
!disableTurnaround = #$0

db $42
JMP return : JMP MarioAbove : JMP return
JMP return : JMP return : JMP return : JMP return
JMP MarioAbove : JMP return : JMP return

MarioAbove:
	LDA $72			;\ if the player's in the air,
	BNE return		;/ skip interaction, since we're not actually on top
	
	LDA $D1			;\
	STA $94			;| store x position of the current frame
	LDA $D2			;| to the next frame
	STA $95			;/

    STZ $7A			;\ clear x speed
	STZ $7B			;/

	LDA !disableTurnaround
	BNE clearLR

	; changing direction
	LDA $76
	BEQ facingLeft

	; here, we're facing right
	LDA $15			;\
	AND #$02		;| if L isn't being pressed, break
	BEQ clearLR 	;/

	LDA #$00		;\ L is being pressed, so
	STA $76			;/ flip Mario to face left
	JMP clearLR

facingLeft:
	LDA $15			;\
	AND #$01		;| if R isn't being pressed, break
	BEQ clearLR		;/

	LDA #$01		;\ R is being pressed, so
	STA $76			;/ flip Mario to face right

clearLR:
	LDA $15			;\
	LSR #2			;| clear L and R inputs
	ASL #2			;| (don't need to update $16)
	STA $15			;/

return:
	RTL

print "A block that the player will stick to while standing on, being unable to move left or right, and can only escape by jumping."
