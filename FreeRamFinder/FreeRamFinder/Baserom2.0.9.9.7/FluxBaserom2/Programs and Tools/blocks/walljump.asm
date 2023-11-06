
print "A simple wall-jump block"


!sound = $02
!soundbank = $1DF9|!addr

db $42
JMP return : JMP return : JMP MarioSide : JMP return : JMP return : JMP return : JMP return
JMP MarioSide : JMP return : JMP return


MarioSide:
	;~ air check
	LDA $72
	BEQ return

	;~ check if jump buttons are pressed
	LDA $16
	BMI .jumpWhere
	LDA $18
	BMI .jumpWhere

	RTL

.jumpWhere
	LDA $93
	BEQ .jumpLeft
	
	;~ jump right
	JSL .jump
	LDA #$30
	STA $7B
	RTL

.jumpLeft:
	JSL .jump
	LDA #$D0
	STA $7B
	RTL

.jump:
	;~ set x speed
	LDA #$B0
	STA $7D

	;~ jump sound
	LDA #!sound
	STA !soundbank

	;~ gfx
	JSL $01AB9E|!bank
	LDA #$0B
	STA $72

	;~ stop spin
	;~ STZ $140D

	RTL

return:
	RTL
