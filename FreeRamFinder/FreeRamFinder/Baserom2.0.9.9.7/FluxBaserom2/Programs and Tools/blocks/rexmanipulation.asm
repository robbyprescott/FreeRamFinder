!sfx 	  = $07
!sfx_bank = $1DFC
db $42
JMP Return : JMP Return : JMP Return
JMP Sprite : JMP Sprite : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
Sprite:
	LDA !14C8,x			;sprite status
	CMP #$08			;check if sprite is dead
	BCC Return			;do not run the code if sprite is dead
	LDA !9E,x			;check if sprite is a rex
	CMP #$AB			;sprite number for the rex
	BNE Return			;branch if sprite is not a rex
	LDA !C2,x			;load amount of hits
	BEQ	smushRex		;branch if rex is normal
	STZ !C2,x			;else, make smushed rex normal again
	LDA #$2A			;\ Set normal rex clipping.
	STA !1662,x			;/
	BRA destroyBlock
smushRex:
	INC !C2,x
	STZ !1662,x			; Set smushed rex clipping.
destroyBlock:
	%sprite_block_position()
	%erase_block()
	%glitter()
	LDA #!sfx
	STA !sfx_bank|!addr				
Return:
	RTL
print "This block smushes a Rex and makes an already smushed rex normal again. The block destroys itself."