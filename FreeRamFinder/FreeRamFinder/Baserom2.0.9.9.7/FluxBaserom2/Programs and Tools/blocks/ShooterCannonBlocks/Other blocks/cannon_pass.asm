;If launched mario hits this block, will let him pass.
;otherwise it is solid (useful for "cannon-only" places)
;behaves $130 (so mario cannot drop carryable sprites *in* walls)
db $42
JMP main : JMP main : JMP main : JMP ret : JMP ret : JMP ret
JMP ret : JMP main : JMP main : JMP main

incsrc cannon_defs.txt

main:
	LDA !freeram_dir
	BEQ ret
	LDY #$00
	LDA #$25
	STA $1693|!addr

ret:
	RTL
print "Passable if mario is launched."