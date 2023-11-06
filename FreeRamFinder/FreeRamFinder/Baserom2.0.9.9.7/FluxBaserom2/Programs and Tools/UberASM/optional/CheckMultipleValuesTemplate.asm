; When branching in your first check, BNE (or whatever) to the label of 
; your second check, and then include a BRA to the main code 
; after this, and so on and so forth. On the last check, just BNE to the last/return label or whatever 

; This example will turn Yoshi drums on if you're big,
; have cape, or fire flower (if LDA $19 is $01, $02, or $03),
; and then turn them off if not.

!FirstValueToCheck = $01
!SecondValueToCheck = $02
!ThirdValueToCheck = $03

main:
    LDA $19 ; address
    CMP #!FirstValueToCheck
	BNE SecondCheck
	BRA ThingToDo
SecondCheck:
	CMP #!SecondValueToCheck
	BNE ThirdCheck
	BRA ThingToDo
ThirdCheck:
	CMP #!ThirdValueToCheck
	BNE NoChange
ThingToDo:	
	LDA #$02 ; Turn on Yoshi drums
	STA $1DFA 
	BRA End
NoChange:
	LDA #$03 ; Or skip this and go straight to RTL
	STA $1DFA
End:
	RTL