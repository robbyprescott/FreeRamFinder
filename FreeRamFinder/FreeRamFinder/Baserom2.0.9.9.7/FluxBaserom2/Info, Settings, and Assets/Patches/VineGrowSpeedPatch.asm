; To speed values with $0DFE

!DummyRAM = $0DFE

org $01C1AD
autoclean JSL VineSpeed 

freecode

VineSpeed:
LDA !DummyRAM
CMP #$01 ; check if speed set via UberASM dummy RAM
BCC Normal ; If above...
LDA !DummyRAM
STA $AA,x
BRA Return
Normal:
LDA #$F0
STA $AA,x ; RAM_SpriteSpeedY
Return:
RTL