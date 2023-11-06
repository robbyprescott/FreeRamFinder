; Kinda janky if lowest slope point intersects with normal ground

; Autoslide block.
;  Best used with slopes, of course, because it also locks Mario's left/right movement.
!true = 1 : !false = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; OPTIONS
; Disable left/right inputs while on the block.
!disableLR	=	!true

; Disable jumping while on the block.
!disableJ	=	!false

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code below, don't touch unless you know what you're doing.
db $37
JMP Return : JMP Above : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
JMP Above : JMP Above : JMP Return
JMP Return : JMP Return

Above:
	LDA $8D
	BEQ Return
	LDA #$1C
	STA $13ED|!addr
	if !disableLR
		LDA #$03
		TRB $15
	endif
	if !disableJ
		LDA #$80
		TRB $16
		TRB $18
	endif
Return:
	RTL

print "Slope that automatically forces Mario to slide. You can set this to disable jumping while sliding on it, too."