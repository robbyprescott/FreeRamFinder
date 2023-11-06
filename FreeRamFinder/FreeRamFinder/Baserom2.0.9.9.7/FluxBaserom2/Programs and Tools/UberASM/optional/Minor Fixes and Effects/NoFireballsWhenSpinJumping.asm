main:
LDA $140D
BEQ Return
LDA #$01
STA $0DED
BRA End
Return:
STZ $0DED
End:
RTL