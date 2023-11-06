; SJC modification of code 
; by RussianMan. You'll simply fall down from where you are on the vine/net.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!Sound = $35	; If you want a sound; commented out by default
!Bank = $1DFC	;

main:
LDA $9D			;obviously don't do things when freeze flag is set
ORA $13D4|!addr		;or game is paused
BNE .Re			;

LDA $74			;and when not climbing, return
BEQ .Re			;

BIT $18			;if not pressing A
BPL .Re			;return

;LDA #!Sound	;spinjump sound effect
;STA !Bank|!addr	;

STZ $74			;No more climbing

.Re
RTL			;