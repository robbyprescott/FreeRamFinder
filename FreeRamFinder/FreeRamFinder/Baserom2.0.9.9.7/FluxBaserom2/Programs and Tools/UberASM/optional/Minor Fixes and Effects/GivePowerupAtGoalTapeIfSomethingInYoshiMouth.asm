main:
LDA $19
BNE Return
LDA $18AC|!addr
BEQ Return
LDA $1493|!addr ; goal walk
BEQ Return 
LDA #$01
STA $19
STZ $18AC|!addr
Return:
RTL