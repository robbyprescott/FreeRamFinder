; Could make this faster by more direct

main:
LDA $18AC
CMP #$26
BCC Return
LDA #$01
STA $18AC
Return:
RTL