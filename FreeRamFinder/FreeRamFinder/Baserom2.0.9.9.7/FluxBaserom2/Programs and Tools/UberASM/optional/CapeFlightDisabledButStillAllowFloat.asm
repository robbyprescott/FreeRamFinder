; When you get p-speed and jump, you'll still
; get a little mini- flight takeoff (but still float only)

; $149F also active when full speed jump even without cape

main:
    LDA $19
	CMP #$02
	BNE Return
	STZ $149F|!addr
	Return:
	RTL