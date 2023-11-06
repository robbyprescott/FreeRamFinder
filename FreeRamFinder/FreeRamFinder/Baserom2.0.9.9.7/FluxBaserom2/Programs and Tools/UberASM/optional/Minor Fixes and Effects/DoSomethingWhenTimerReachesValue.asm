!Time = $001

main:
	LDA $0F33	;load ones
	CMP.b #!Time&15	;only low nybble
	BNE Return	;if not equal return

	LDA $0F32	;load tens
	CMP.b #!Time>>4&15
	BNE Return

	LDA $0F31
	CMP.b #!Time>>8&15
	BNE Return

;teleport
	LDA #$06
	STA $71
	STZ $89
	STZ $88
	
Return:
	RTL