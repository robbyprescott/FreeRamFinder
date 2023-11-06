!DoSomethingWhenDamaged = 1 ; if 0, will do something when you die instead

main:
if !DoSomethingWhenDamaged
LDA $71	
CMP #$01 ; check for damage animation
BNE Return
else
LDA $71	
CMP #$09 ; actual death
BNE Return
endif
LDA #$01
STA $14AF ; INC $13CC give coin
Return:
RTL