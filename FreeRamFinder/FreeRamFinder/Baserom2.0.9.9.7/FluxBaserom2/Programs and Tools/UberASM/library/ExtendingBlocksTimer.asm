
; Turns 16 bytes of freeram into automatically decrementing timer. To use with the !use_multiple_timer option

; !timer = $0F5E|!addr		; Table of 16 individual timers

main:
	LDX #$0F
-	LDA $0F5E,x  ; timer RAM
	BEQ .blocktimernext
	DEC
	STA $0F5E,x  ; timer RAM
.blocktimernext
	DEX : BPL -
	RTL