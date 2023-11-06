@includefrom yoshi_fireballPatch.asm

;blank space, do not put code here.

	dw	Smoke			;00
	dw	BreakNormal		;01
	dw	BreakRainbow		;02
	dw	KillFire		;03
	dw  ChangeToCustomBlock1 ;04

;here goes your new pointers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Smoke:	
	%generate_smoke()
	%generate_smw_tile($02)
	%generate_sound($03,$1DF9)
	%return()
BreakNormal:	
	%shatter_block($00)
	%generate_smw_tile($02)
	%return()
BreakRainbow:	
	%shatter_block($01)
	%generate_smw_tile($02)
	%return()
KillFire:
	%kill_fire()
	%generate_smoke_on_fire()
	%generate_sound($01,$1DF9)
	%return()
ChangeToCustomBlock1:
    %generate_smoke()
	REP #$10
	LDX #$04CC
	%change_map16()
	SEP #$10
	%return()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

interact_table:
    dw $0284 : db $03  ; sprite killer stops fireball
	dw $0299 : db $00  ; block koopa into smoke
	dw $02A9 : db $00  ; block spiny into smoke
.end	