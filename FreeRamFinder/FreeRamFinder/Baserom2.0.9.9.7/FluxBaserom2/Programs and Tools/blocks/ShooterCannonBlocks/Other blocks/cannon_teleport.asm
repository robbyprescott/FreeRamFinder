;If launched mario hits this block, will teleport
;mario to another level (good for transition from
;the the level to the sky if aiming up)
;behaves $025
db $42
JMP main : JMP main : JMP main : JMP ret : JMP ret : JMP ret
JMP ret : JMP main : JMP main : JMP main

incsrc cannon_defs.txt

main:
	LDA !freeram_dir	;\not launched mario = return
	BEQ ret			;/
	LDA #$06		;\
	STA $71			;| Teleport the player
	STZ $88			;|
	STZ $89			;/
	;STZ !freeram_dir	;>remove semicolon if you don't
				;want the player remain "cannon mode"
				;on the next level
ret:
	RTL
print "Teleport if mario is cannon mode."