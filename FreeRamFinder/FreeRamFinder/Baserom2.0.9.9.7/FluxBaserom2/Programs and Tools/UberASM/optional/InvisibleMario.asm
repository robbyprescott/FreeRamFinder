; Add hex to prevent triple or rotating platform which makes you visible?

!UseTrigger = 0
!TriggerAddress = $14AF
	
	main:
    if !UseTrigger
    LDA !TriggerAddress
	BEQ Return
	endif
	LDA #$7F
	STA $78
	BRA End
Return:
    STZ $78
End:
	RTL