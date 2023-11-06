;similar to the stopper, but this doesn't stop mario instantly,
;nor it would snap mario into the center of the block, if
;mario hits this, mario will be effected by gravity and the
;freeram flags are reset, gently stopping him (exactly
;like the sprite version when mario "runs out of momentum").
;behaves $025
db $42
JMP main : JMP main : JMP main : JMP ret : JMP ret : JMP ret
JMP ret : JMP main : JMP main : JMP main

incsrc cannon_defs.txt

main:
	STZ !freeram_dir
	STZ !freeram_interact
ret:
	RTL
print "Cancels out Mario's cannon mode, but not instantly."