;if launched mario hits this block, will stop him instantly
;and snaps him to the center of the block. (useful in levels
;that require positioning mario precisely)
;behaves $025
db $42
JMP main : JMP main : JMP main : JMP ret : JMP ret : JMP ret
JMP ret : JMP main : JMP main : JMP main

incsrc cannon_defs.txt

main:
	%Collision12x16()	;\If too far, don't trigger block
	BCC ret				;/
	LDA !freeram_dir	;\so he isn't centered every
	BEQ ret			;/frame
	STZ !freeram_dir
	STZ !freeram_interact
	STZ $7B
	STZ $7D
	LDA $9A			;\center player horizontally
	AND #$F0		;|and vertically (didn't use
	STA $94			;|the big/small check, or mario's
	LDA $9B			;|feet is through the ground while
	STA $95			;|being able to move).
	LDA $98			;|
	AND #$F0		;|
	SEC : SBC #$10		;|
	STA $96			;|
	LDA $99			;|
	SBC #$00		;|
	STA $97			;/
ret:
	RTL
print "Stops cannon Mario instantly/centered."