;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Heavy Carry by dtothefourth
;
; UberASM - Can stop you from jumping or adjust fall
; speed while carrying anything
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!DisableJump = 0 ; 0 = can jump, 1 = jump disabled

!GravityModU = $02	; Modifies gravity while rising
					; 0 = don't change
					; 1-7F  = increase fall speed (1-8 recommended)
					; 80-FF = decrease fall speed (FC-FF recommended) makes it floaty instead of heavy

!GravityModD = $02	; Modifies gravity while falling
					; 0 = don't change
					; 1-7F  = increase fall speed (1-8 recommended)
					; 80-FF = decrease fall speed (FC-FF recommended) makes it floaty instead of heavy

main:

	LDA $1470|!addr
	ORA $148F|!addr
	BNE +
	RTL
	+

	
	if !DisableJump
	LDA #$80
	TRB $16
	TRB $18
	TSB $0DAA|!addr
	TSB $0DAB|!addr
	TSB $0DAC|!addr
	TSB $0DAD|!addr
	endif

	LDA $7D
	BMI +
	CLC
	ADC #!GravityModD
	BRA ++
	+
	CLC
	ADC #!GravityModU
	++
	STA $7D

	RTL

