; For use with music display code,
; to disable on a per-level basis

main:
LDA $13D4 ; pause 
BEQ Return
LDA #$30
TSB $0DAC
TSB $0DAD
Return:
RTL