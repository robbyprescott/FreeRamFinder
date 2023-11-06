!RAM = $14AF

!SpeedPushRight = $1A ; $18 normal speed push right?
!SpeedPushLeft = $EA
!MaxLeftAgainstTide = $F5 ; $F8 may be vanilla. higher the value, more speed
!MaxRightAgainstTide = $08

!CanSwimAgainstTide = 1
!CanJumpOutOfWater = 1
!BoostWhenSwimmingWithTide = 0

main:
    
MoveRight:
    LDA $75 ; check if in water
	BEQ Return
	LDA !RAM
	BEQ SwitchDirectionToLeft ; change to BNE to start out going right
	if !CanSwimAgainstTide
    LDA $15
	AND #$02
	BNE Left ; if holding left, branch
	endif
    LDA #!SpeedPushRight  
	STA $7B	
	LDA #$01 ; face right
	STA $76
	if !BoostWhenSwimmingWithTide		
	LDA $15
	AND #$01 ; holding right
	BEQ Return	
    endif
	BRA Return
Left:	
    LDA $7B
	CMP #!MaxLeftAgainstTide			
    BPL Return				
	LDA #!MaxLeftAgainstTide
    STA $7B
	BRA Return
SwitchDirectionToLeft:
	if !CanSwimAgainstTide
    LDA $15
	AND #$01
	BNE Right ; if holding right, branch
	endif
    LDA #!SpeedPushLeft 
	STA $7B	
	STZ $76 ; ; face left
	if !BoostWhenSwimmingWithTide		
	LDA $15
	AND #$02 ; holding left
	BEQ Return	
    endif
	BRA Return
Right:	
    LDA $7B
	CMP #!MaxRightAgainstTide			
    BMI Return ; or BMI				
	LDA #!MaxRightAgainstTide
    STA $7B
Return:
	RTL	