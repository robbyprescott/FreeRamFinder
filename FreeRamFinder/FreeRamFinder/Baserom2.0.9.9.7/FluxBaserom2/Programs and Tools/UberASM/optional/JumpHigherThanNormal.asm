; By SJC
; Need to add spin jump too

!Height = $A0 ; the lower the number, the higher the jump
!LuigiCheck = 0 ; only jump higher if Luigi
!StartAsLuigi = 0

init:
    if !StartAsLuigi
    STZ $0DA0
    LDA #$01
	STA $0DB3
	endif
    RTL

main:
    if !LuigiCheck
	LDA $0DB3
	CMP #$01
    BNE .return
	endif
	LDA $77
	AND #$04
	BEQ .return
	LDA $16
	AND #$80
	BEQ .return	
	LDA #$35
	STA $1DFC
	LDA #!Height
	STA $7D
.return
	RTL;