init:
;LDA !FreeRAM
;BEQ Return
;LDA #$05 
;STA $1DF9 ; midway sound
PHY
	if read1($009B42) == $02 ; Check if the SRAM+ patch is applied
		PHB
		REP #$30
			LDX.w #$1EA2
			LDY.w #$1F49
			LDA.w #140		; > How many bytes to transfer
			MVN $7E,$7E
		SEP #$30
		PLB
	endif
	JSL $009BC9 ; causes issues if in block form
	PLY
Return:	
RTL