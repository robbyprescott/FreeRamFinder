; UberASM Version
; From Ladida's cluster sprite package. Slightly modified.

; Add L/R?

;LDA $18              ; \ Press - alt 16
;AND #$30             ; | L or R 
;LSR #4
;AND #$03
;TAX                  ; | increase or decrease counter based on
;LDA.l Add,x          ; | pushing L or R.
;CLC                  ; |
;ADC !Counter         ; /

!SpikeCount       = $09   ; Amount of sprites to fall down, -1. Values outside of 00-13 are not recommended.

!ClusterNum = $00	  ; Custom cluster sprite number from your list. 00 is fish, 01 flowers, 02 rain, 03 sandstorm

;Don't edit these!
!ClusterOffset  = $09

!cluster_num = $1892|!addr
!cluster_y_low = $1E02|!addr
!cluster_x_low = $1E16|!addr

init:
LDA $71						;if castle entrance/no yoshi sign cutscene plays
CMP #$0A					;don't spawn clusters (if the sublevel you're using should have them, you'll have to use a sprite version)
BEQ .Re						;

PHB
PHK
PLB

	LDY #!SpikeCount
-
	LDA #!ClusterNum+!ClusterOffset
	STA !cluster_num,y     ; /

	LDA InitXY,y           ; \ Initial X and Y position of each sprite.
	PHA                    ; | Is relative to screen border.
	AND #$F0               ; |
	STA !cluster_x_low,y   ; |
	PLA                    ; |
	ASL #4                 ; |
	STA !cluster_y_low,y   ; /
	
	DEY                    ; \ Loop until all slots are done.
	BPL -                  ; /

	LDA #$01               ; \ Run cluster sprite routine.
	STA $18B8|!addr       ; /

	PLB                    ; restore bank

.Re
	RTL                    ; Return.


; Initial X and Y position table of sprites.
; Relative to screen border.
; Format: $xy
InitXY:
db $06,$45,$9E,$E2,$A7,$BC,$59,$40,$61,$F5,$D6,$24,$7B,$33,$C6,$0B,$00,$39,$70,$A1