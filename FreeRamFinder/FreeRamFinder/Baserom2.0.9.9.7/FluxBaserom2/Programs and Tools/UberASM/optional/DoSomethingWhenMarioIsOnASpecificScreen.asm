; This will run a code the moment you get to whatever screen you specify

!ScreenNumber = $01

main:
	LDA $95	
	CMP #!ScreenNumber	; Check if Mario is on a specified screen
	BNE Return	        ; If not, return; but if so...
	LDA #$01	        ; Example code,
	STA $19		        ; Make Mario big
Return:
	RTL