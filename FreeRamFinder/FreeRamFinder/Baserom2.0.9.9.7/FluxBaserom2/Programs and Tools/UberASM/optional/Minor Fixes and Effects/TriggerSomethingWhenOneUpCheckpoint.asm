; When collect all 4 in order *or not in order, if using the new patch by MFG)

main:
LDA $1421
CMP #$04
BNE Return
LDA #$02
STA $19
Return:
RTL