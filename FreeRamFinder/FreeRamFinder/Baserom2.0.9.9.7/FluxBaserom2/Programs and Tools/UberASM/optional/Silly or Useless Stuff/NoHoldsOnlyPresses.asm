; by SJandCharlieTheCat

; Prevents hold if press

main:
  LDA $16	; \ press 
  AND #$0F   ; 01 is right. 0F is all
  BNE Return  
  LDA #$0F
  TRB $15		; | prevent hold
Return:
  RTL