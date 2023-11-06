; Swallow timer will never decrement

main:
LDA $18AC
BEQ Return
LDA #$FF
STA $18AC
Return:
RTL