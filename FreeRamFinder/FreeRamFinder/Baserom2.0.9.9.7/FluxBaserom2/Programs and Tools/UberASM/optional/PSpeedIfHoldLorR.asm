; By SJC
; Side effect: you'll always auto-grab items if you have p-speed, 
; even if you let go of Y

main:
	LDA $17 ; held
	AND #$30
	BEQ NotHeld
	LDA #$40 ; this effectively makes an L or R hold a Y/X hold, too.
	TSB $15  ; Otherwise you're forced to hold Y, too, in order to actually get instant p-speed.
	LDA #$70
    STA $13E4
	BRA End
NotHeld:
	;STZ $13E4
End:	
    RTL