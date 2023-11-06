!falldown_timer = !1564
!platform_prop = !1594
!behavior = !C2
!offset = #(ss3-mpm_init_pointers)>>1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Grey falling platform
;
;	Init
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Platform_clip3:
db $2F,$33,$2F,$33,$00,$00,$00,$00,$15,$15
Platform_properties3:
db $00,$02,$00,$02,$00,$00,$00,$00,$03,$03
Platform_yspeed3:
db $10,$10,$F0,$F0,$00,$00,$00,$00,$10,$F0

ss3_init:
		LDA #$01
		STA !15F6,x

		LDA !1504,x
		SEC
		SBC.b !offset
		TAY

		LDA Platform_clip3,y
		STA !1662,x
		
		LDA Platform_properties3,y
		STA !platform_prop,x
		
		LDA Platform_yspeed3,y
		STA !AA,x
		
		RTS
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;		Main
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ss3_main:
		LDA !platform_prop,x
		AND #$03
		INC
		INC
		
		JSR Shared_GFX			; Graphics routine

		LDA $9D					; Animation lock flag
		BNE ss3_return			; "freeze!"

		LDA #$00
		%SubOffScreen()
		
		JSL $01801A		; Update Y position	
	
		JSR solid_routine
	
		LDA !AA,x
		BMI ss3_WrapUp
	ss3_WrapDown:
			JSR WrapDown
			RTS
	
	ss3_WrapUp:
			JSR WrapUp
	
	ss3_return:
		RTS
	