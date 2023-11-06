;If launched mario hits this block, will shatter the block
;and mario will Pierce through them. (useful for puzzle levels
;that require mario to cannon himself, then backtrack.
;behaves $130
db $42
JMP main : JMP main : JMP main : JMP ret : JMP ret : JMP ret
JMP ret : JMP main : JMP main : JMP main

incsrc cannon_defs.txt

main:
	LDA !freeram_dir	;\not launched mario = solid
	BEQ ret			;/
	LDY #$00		;\Pierce the block (not to stop
	LDA #$25		;|mario).
	STA $1693|!addr	;/
	LDA #$0F		;\fix Shatter pieces not being centered.
	TRB $98			;|
	TRB $9A			;/
	%shatter_block()
ret:
	RTL
print "Shatters if launched mario hits it."