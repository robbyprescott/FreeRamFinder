main:
LDA $15
EOR $17
BPL Return ; BMI for check only A
LDA #$80
TRB $15  
TRB $17
Return:
RTL