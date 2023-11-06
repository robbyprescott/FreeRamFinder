; Note that this has the effect of always flipping the trigger
; back to its normal non-set state after hitting.

!Trigger = $14AF
!LengthPause = $0F ; very brief. $2F longer
!DelayFreeRAM = $0E04


main:
LDA !Trigger
BEQ NotSet	
LDA !DelayFreeRAM
CMP #!LengthPause ; delay 
BEQ Revert
INC !DelayFreeRAM
LDA #$01
STA $13FB ; actual Mario freeze
NotSet:
RTL

Revert:
STZ !Trigger
STZ $13FB
STZ !DelayFreeRAM
RTL

