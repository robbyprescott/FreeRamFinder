main:
LDA $187A
BEQ Return
LDA #$01
STA $18E7
BRA End
Return:
STZ $18E7
End:
RTL