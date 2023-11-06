!NewLength = $5F ; $26 is when swallow animation begins

main:
LDA $18AC  ; Yoshi has item in mouth
CMP #!NewLength
BCC Return
LDA #!NewLength
STA $18AC
Return:
RTL