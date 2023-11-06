; Could make this faster by more direct
; Will still eventually swallow after a while if you just hold itme in mouth; but can change this too

main:
;LDA $187A
LDA $14AF
BEQ Return
LDA #$10
STA $14A3
Return:
RTL