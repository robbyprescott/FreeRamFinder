!SpeedRight = $1A ; $18 normal speed push right?
!SpeedLeft = $EA
!Trigger = $14AF

main:
    LDA !Trigger
	BNE Left ; run right unless on/off triggered
    LDA #!SpeedRight  
	STA $7B	
	LDA #$02 ; no left
	TRB $15
	TRB $16
	LDA #$01
	STA $76
	BRA Return
Left:	
	LDA #!SpeedLeft
    STA $7B
	LDA #$01
	TRB $15
	TRB $16
	STZ $76
Return:
	RTL	