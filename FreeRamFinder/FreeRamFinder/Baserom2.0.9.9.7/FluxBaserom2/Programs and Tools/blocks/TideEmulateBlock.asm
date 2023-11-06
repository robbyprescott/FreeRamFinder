print "Emulates layer 3 tide pushing you left. Speeds and other options customizable."

!SpeedPushRight = $1A ; $18 normal speed push right?
!MaxLeft = $F5 ; $F8 may be vanilla. higher the value, more speed

!CanSwimAgainstTide = 1
!CanJumpOutOfWater = 1
!BoostWhenSwimmingWithTide = 0

db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BodyInside:
HeadInside:
    
MoveRight:
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
MarioBelow:
MarioAbove:
TopCorner:
MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireball:	
Return:
	RTL	

print ""
