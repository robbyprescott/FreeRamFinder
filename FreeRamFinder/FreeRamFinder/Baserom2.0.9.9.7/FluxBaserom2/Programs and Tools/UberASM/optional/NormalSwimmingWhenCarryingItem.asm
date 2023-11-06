; Swimming poses are 16-1B
; First stroke pose is either 19 or 1B
; https://i.imgur.com/JW4rkEE.png

!FirstPose = $18 ; If $19, will show brief animation, but slightly awkward
!LastPose = $1B

main:
	LDA $75
	BEQ Return
	STZ $148F ; carry flag not set so that no altered swimming physics
	LDA $1470 ; Other carrying flag, check for poses
	BEQ Return
	LDA $13E0
	CMP #!FirstPose
    BCC Return
    CMP #!LastPose+1
    BCS Return
	;BEQ Return
	LDA #$16
	STA $13E0
	BRA Return
	
Return:
	RTL