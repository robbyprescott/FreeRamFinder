; Only toggled on press

main:
	LDA $18
	AND #$30
	BEQ +
		LDA $14AF|!addr
		EOR #$01
		STA $14AF|!addr
		LDA #$0B
		STA $1DF9
	+
	RTL