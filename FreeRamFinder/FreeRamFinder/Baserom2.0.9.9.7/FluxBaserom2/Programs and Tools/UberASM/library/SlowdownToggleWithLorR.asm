; Thanks to abwarts

!PlaySoundWhenToggled = 1
!FreeRAMAddress = $14AF ; $14AF
!Loops = $FF

main:
STZ $58

LDA $18
AND #$30 ; check if L or R pressed
BEQ +
LDA !FreeRAMAddress
EOR #$01 ; flip to opposite state each time pressed
STA !FreeRAMAddress
if !PlaySoundWhenToggled
LDA #$29 
STA $1DFC
endif
+
LDA !FreeRAMAddress
CMP #$01 ; if set, do thing	
BEQ Slow
+
RTL

Slow:
NOP #60
INC $58
LDA $58
CMP #!Loops
BNE Slow
End:
RTL