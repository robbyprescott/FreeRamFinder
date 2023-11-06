print "Will spawn a throwblock into your hands whenever you grab it (as many times as you want). As the name suggests, if you use it with the ThrowblockSpawnerOnlyAllowsOneThrowblockOnscreen.asm UberASM, it won't allow you to spawn more than one throwblock at a time from these (or allow more than one throwblock anywhere else on screen)."

 
;behaves $130
db $42
JMP return : JMP main : JMP main : JMP return : JMP return : JMP return
JMP return : JMP main : JMP main : JMP main



!last_timer = $FF	;a timer before the throwblock evaporates at #$03,
			;decrements every 2 frames.

main:
	LDA $16		;\if not pressing dash
	AND #$40	;|
	BEQ return	;/return
	LDA $0E23
	ORA $1470	;\if already holding something or on yoshi
	ORA $148F	;|then return.
	ORA $187A	;|
	BNE return	;/

	LDA #$08				;\"picking something up"
	STA $1498				;/pose timer
	LDA #$53				;\Spawn throw block
	CLC
	%spawn_sprite()
	TAX
	LDA #$0B		;\carried sprite
	STA $14C8,X		;/ 
	LDA #!last_timer	;\set countdown timer
	STA $1540,x		;|
	STA $C2,x		;/
	LDA $190F,X		;\
	BPL return		;| Something about getting stuck in walls?
	LDA #$10		;|
	STA $15AC,X		;/
	TXA 
	%move_spawn_into_block()
return:
RTL