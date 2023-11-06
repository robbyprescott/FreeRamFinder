main:
	LDA $77
	AND #$04
	BEQ .return
	LDA $140D|!addr
	BEQ .return
	LDA #$90
	STA $7D
.return
	RTL;