; When on Yoshi, makes you lean at a ridiculous diagonal angle

main:
LDA $187A
BEQ Return
LDA $13E0
ORA #$10
AND #$13
STA $13E0
Return:
RTL