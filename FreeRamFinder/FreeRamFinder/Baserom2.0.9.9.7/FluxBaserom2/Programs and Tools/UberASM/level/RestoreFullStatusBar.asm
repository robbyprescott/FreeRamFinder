; If you just want the timer, use TimerInLevel.asm instead of this Uber
; (If $0DEC is enabled, it'll skip the actual counter functions; but this isn't enabled by default)

!GFXflag = $0E06
		

load:
    lda #$01
	sta !GFXflag
	rtl