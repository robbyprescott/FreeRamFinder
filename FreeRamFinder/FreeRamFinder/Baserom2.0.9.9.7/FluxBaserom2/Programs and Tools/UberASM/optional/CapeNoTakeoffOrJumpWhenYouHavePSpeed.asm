; Unlike the other Uber which will still give you 
; a mini- flight takeoff (but still float only) when you jump with cape + p-speed,
; this one will prohibit you from jumping altogether when you have p-speed with cape

; A presses also disabled with p-speed, to prevent spin-flight

!FreeRAM = $0E0E
!ConditionalOnTrigger = 0

main:
if !ConditionalOnTrigger
LDA !FreeRAM
BEQ Return
endif
LDA $19
CMP #$02 ; if cape
BNE Return
LDA $13E4
CMP #$70 ; p-speed
BNE Return
LDA #$80 
TRB $16 ; disable B press
TRB $18 ; disable A press
Return:
RTL