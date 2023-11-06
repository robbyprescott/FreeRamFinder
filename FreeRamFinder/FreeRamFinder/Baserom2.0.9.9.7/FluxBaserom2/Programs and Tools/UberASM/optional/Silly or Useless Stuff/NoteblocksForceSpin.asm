main:
LDA $140D
BNE Return
LDA $1402
BEQ Return
LDA #$01
STA $140D
Return:
RTL