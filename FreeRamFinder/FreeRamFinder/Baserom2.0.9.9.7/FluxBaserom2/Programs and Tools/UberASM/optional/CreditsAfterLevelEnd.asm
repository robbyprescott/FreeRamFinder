; by SJandCharlieTheCat
; Warp right at peace sign to prevent jank later in sequence

init: 
STZ $1493
STZ $1492
RTL

main:
	LDA $1493 
	CMP #$28 ; Timer, triggers at peace sign
	BNE +
	
	LDA #$08  ; credits trigger
    STA $13C6
    LDA #$18
    STA $0100
+   RTL