; This will allow you to toggle layer 2 foreground GFX with L or R. 
; (Will kill any layer 2 BG by default.)
; Make sure to put layer 3 on subscreen. (Or add this to Uber.)

; Obviously use the relevant level mode (e.g. 01) to be able to
; place your layer 2 foreground. Be sure to also set the 
; BG scrolling to constant if you want layer 2 to act the
; same as layer 1

!UseSelect = 0 ; Change to 1 to use select button to toggle instead
!CantToggleWhenPaused = 0

nmi:
    ; Add !CantToggleWhenPaused check
	if !UseSelect
	LDA $15
	AND #$20
	else
    LDA $17 ; If L or R held
	AND #$30
	endif
	BNE enable
    rep #$20
    lda $0D9D|!addr
    and #$FDFD
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