; Mars note:

;Note that the net hitting animation will not briefly prevent you from spin-jumping as it would usually with normal-jumping. 
;A side effect of this is that, if you spin too soon after hitting a net door, the animation will be cut short and the door won't turn. 
; It's a small window for it to happen and it's pretty inconsequential, but thought I'd mention it anyway.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Allow spinjump from vine/net/etc.
;this code allows player to spinjump from vine/net and etc.
;By RussianMan. Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!YSpeed = $B6		;Yspeed when spinjumping, per Thomas' physics patch

!SpinJumpSound = $04	;just in case you want to change sound effect.
!SpinJumpBank = $1DFC	;

main:
LDA $9D			;obviously don't do things when freeze flag is set
ORA $13D4|!addr		;or game is paused
BNE .Re			;

LDA $74			;and when not climbing, return
BEQ .Re			;

BIT $18			;if not pressing A
BPL .Re			;return

INC $140D|!addr		;make player spin

LDA #!YSpeed		;set Y-speed
STA $7D			;

LDA #!SpinJumpSound	;spinjump sound effect
STA !SpinJumpBank|!addr	;

STZ $74			;No more climbing

.Re
RTL			;