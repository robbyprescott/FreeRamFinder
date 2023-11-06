; Watch out for conflict with Mario/Luigi patch, if you use !StartAsMario

!FreeRAM = $14BE

load:
STZ !FreeRAM

main:
LDA $14AD
BEQ Nope
LDA #$01
STA !FreeRAM 
BRA Return
Nope:
STZ !FreeRAM
Return:
RTL