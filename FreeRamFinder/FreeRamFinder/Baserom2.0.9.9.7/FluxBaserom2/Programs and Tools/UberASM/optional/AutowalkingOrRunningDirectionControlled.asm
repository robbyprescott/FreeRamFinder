; Auto-walker/runner, but the direction you run
; is controlled by tapping left or right (just once)

!SpeedRight = $20 
!SpeedLeft = $E0
!DisableMovingLeftOrRightWhenYoureInTheAir = 1
!FreeRAM = $0E22

main:
    LDA $72
    BNE InAir
	LDA $15
    ;LDA $16
	AND #$02 ; left
	BEQ Right 
	LDA #$01
	STA !FreeRAM
	BRA ActualRun
Right:
    LDA $15
	;LDA $16
	AND #$01
	BEQ ActualRun
    STZ !FreeRAM
ActualRun:	
    LDA !FreeRAM
	BNE Left ; run right unless on/off triggered
    LDA #!SpeedRight  
	STA $7B	
	LDA #$02 ; left presses won't change speed or pose
	TRB $15
	TRB $16
	LDA #$01
	STA $76 ; direction
	BRA Return
Left:	
	LDA #!SpeedLeft
    STA $7B
	LDA #$01 ; presses won't change speed or pose
	TRB $15
	TRB $16
	STZ $76 ;
    BRA Return
InAir:
    if !DisableMovingLeftOrRightWhenYoureInTheAir
    LDA #$03 
	TRB $15
	TRB $16  
    endif	
Return:
	RTL	