main:
LDA $15
EOR $17
AND #$40
BEQ Return
LDA #$40 ; Y or X
TRB $15  
TRB $17
Return:
RTL