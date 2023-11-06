; By SJC

!Height = $90
!AddressCheck = 0 ; if set to 1, will only start bouncing on trigger
!Address = $14AF

main:
	LDA $77
	AND #$04
	BEQ .return
	if !AddressCheck
	LDA !Address|!addr
	BEQ .return
	endif
	LDA #!Height
	STA $7D
	LDA #$08 ; boing
	STA $1DFC
.return
	RTL;