; Use in conjunction with the ChangeMusic block

!song = #$12 ; Match number
!freeRAM = $1926|!addr			

init:
main:
	;LDA $9D
	;ORA $13D4|!addr
	LDA !freeRAM ; No reset RAM, match in block
	BEQ .return
	LDX !freeRAM			;\ load the song
	LDA !song
	STA $1DFB|!addr			;| put it in music slot
	STA !freeRAM+1			;/
.return
	RTL