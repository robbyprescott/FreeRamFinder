;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Frame Perfect Spinfly Fix by dtothefourth
;
; Fixes the issue where getting a frame perfect jump 
; to take off mid-spin fly when hitting the ground
; would cause the flight meter not to refill.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Last72 = $7FB640 ;FreeRAM

init:
	LDA #$00
	STA !Last72
	RTL

main:

	;Testing code, uncomment this to have turbo A on L
	;LDA $17
	;AND #$30
	;BEQ +
	;LDA $18
	;ORA #$80
	;STA $18
	;+

	LDA !Last72
	BEQ +

	LDA $18
	BIT #$80
	BEQ +

	LDA $13EF
	BEQ +

	LDA $149F
	BEQ +

	LDA $73
	BNE +

	LDA $13E4               
	CMP #$70                
	BCC +   

	LDA #$50
	STA $149F

	+

	LDA $72
	STA !Last72

	RTL