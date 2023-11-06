; Use ths with layer 3 tide example level
; SJC added actual tide physics

!WaterLevel = $0150 ; 150 is 6 tiles high?
!TypeOfInteract = $02		; $02 = Water, $04 = Lava, $06 = Ground, $08 = Magma

!SpeedPushRight = $1A ; $18 normal speed push right?
!MaxLeft = $F5 ; $F8 may be vanilla. higher the value, more speed

!CanSwimAgainstTide = 1
!CanJumpOutOfWater = 1
!BoostWhenSwimmingWithTide = 0


load:
	LDA #!TypeOfInteract
	STA !InteractionType
	REP #$20
	LDA #!WaterLevel
	STA !InteractionPos
    RTL

init:
	%InitInteractLineHdma(3, $12)
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
	RTL
main:
    %CalculateInteractLineHdma(!InteractionPos, $20, $E0)
MoveRight:
    LDA $75 ; check if in water
	BEQ Return
	;LDA $14AF
	;BEQ SwitchDirection
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
	BRA Return
SwitchDirection:
Return:
	RTL	