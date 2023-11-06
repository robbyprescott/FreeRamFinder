!NumberOfCoins = #$05 ; this many to trigger

main:
LDA $1420
CMP !NumberOfCoins
BEQ Return
LDA #$10 ; magikoopa magic sound?
STA $1DF9
INC $19
RTL