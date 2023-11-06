!StartAlreadyWithWater = 1 ; only becomes water level when trigger is turned on
!Trigger = $14AF

main:
LDA !Trigger
if !StartAlreadyWithWater = 1
BNE Return
else
BEQ Return
endif
LDA #$01
STA $85
BRA End
Return:
STZ $85
End:
RTL