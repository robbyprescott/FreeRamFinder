!Trigger = $14AF
!StartsOff = 1 ; Change to 1 to start off, and only appear on trigger
!CantToggleWhenPaused = 1

nmi:
    ; Add !CantToggleWhenPaused check
	if !StartsOff
	LDA !Trigger
	BNE enable
    else
	LDA !Trigger 
	BEQ enable
	endif
	rep #$20
    lda $0D9D|!addr
    and #$FBFB ; layer 2 is #$FDFD
    sta $212C
	;sta $212E
    sep #$20
    rtl
	
	enable:
    ; to enable:
    rep #$20
    lda $0D9D|!addr
    sta $212C
	;sta $212E
    sep #$20
	rtl