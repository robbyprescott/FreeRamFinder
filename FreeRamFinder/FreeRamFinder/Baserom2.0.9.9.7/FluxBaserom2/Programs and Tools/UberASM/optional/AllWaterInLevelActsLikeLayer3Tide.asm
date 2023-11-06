!SpeedPushRight = $1A ; $18 normal speed push right?
!MaxLeft = $F5 ; $F8 may be vanilla. higher the value, more speed

!CanSwimAgainstTide = 1
!CanJumpOutOfWater = 1
!BoostWhenSwimmingWithTide = 0

main:
    
MoveRight:
    LDA $75 ; check if in water
	BEQ Return
	;LDA $14AF
	;BEQ Return
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
	CMP #!MaxLeft			
    BPL Return				
	LDA #!MaxLeft
    STA $7B
Return:
	RTL	