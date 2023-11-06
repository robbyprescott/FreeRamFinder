;this cannon block will launch mario leftwards.
;behaves $025
db $42
JMP ret : JMP ret : JMP ret : JMP ret : JMP ret : JMP ret
JMP ret : JMP ret : JMP main : JMP main

incsrc cannon_defs.txt

main:
	%Collision12x16()	;\If too far, don't trigger block
	BCC ret				;/
	LDA $187A|!addr	;\if mario carrying something/on yoshi
	ORA $1470|!addr	;|
	ORA $148F|!addr	;|
	BNE ret			;/return
	LDA !freeram_interact	;\if mario prior launched
	BNE ret			;/then return
	LDA #!cannon_sfx_num		;\sfx (bullet bill shoot)
	STA !cannon_bank	;/
	LDA #$06		;\so mario cannot be stuck in cannon
	STA !freeram_interact	;/
	LDA #$07		;\set direction
	STA !freeram_dir	;/
	LDA #$FF		;\so he looks like he's in the cannon
	STA $78			;/
	LDA $9A			;\center player horizontally
	AND #$F0		;|
	STA $94			;|
	LDA $9B			;|
	STA $95			;/

	LDA $19			;\if mario is small
	BEQ small_mario		;/then center vertically differently

	LDA $98			;\center player vertically
	AND #$F0		;|
	SEC : SBC #$0A		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;|
	RTL			;|
small_mario:			;|
	LDA $98			;|
	AND #$F0		;|
	SEC : SBC #$10		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;/
ret:
	RTL
print "Automatically launches the player leftwards."