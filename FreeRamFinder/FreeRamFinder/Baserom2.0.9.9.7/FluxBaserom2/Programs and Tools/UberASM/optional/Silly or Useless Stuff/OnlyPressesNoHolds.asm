main:
  LDA $16	; 
  AND #$0F  ; all buttons
  BEQ Prevent
  BNE Return
Prevent:  
  LDA #$0F
  TRB $15
RTL