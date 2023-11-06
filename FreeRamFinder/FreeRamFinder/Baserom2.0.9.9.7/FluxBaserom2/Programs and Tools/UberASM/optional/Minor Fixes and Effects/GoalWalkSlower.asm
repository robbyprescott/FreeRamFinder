; If speed $0D, then ten empty tiles between goal and teleport.


main:
LDA $1493        ; goal sequence
BEQ Return
LDA $7B		     
CMP #$0D         ; Slower walk speed after. Normal walk speed is $21.
BMI Return				
LDA #$0D	     ; Very slow indeed
STA $7B						
Return:
RTL

