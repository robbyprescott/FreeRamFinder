; If you press L or R, will spawn a powerup in your item reserve box,
; and you can cycle through them.

!Powerup = $01

main:
LDA $18
AND #$30 ; #$20 is L, #$10 is R
BEQ + 
LDA #!Powerup  
STA $0DC2 
LDA #$10 ; magikoopa	
STA $1DF9
+
RTL