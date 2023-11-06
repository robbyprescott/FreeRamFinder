; SJC modification of code 
; by RussianMan. 


!YSpeed = $B0		; $B6 for spin jump (see Thomas' physics patch for values)

!Sound = $35	; 
!Bank = $1DFC	;

main:
LDA $9D			;obviously don't do things when freeze flag is set
ORA $13D4|!addr		;or game is paused
BNE .Re			;

LDA $74			;and when not climbing, return
BEQ .Re			;

BIT $18			;if not pressing A
BPL .Re			;return

LDA #$80
TRB $16	;make player 

LDA #!YSpeed		;set Y-speed
STA $7D			;

LDA #!Sound	;spinjump sound effect
STA !Bank|!addr	;

STZ $74			;No more climbing

.Re
RTL			;