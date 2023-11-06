; This prevents any spin jumps, 
; because pressing A will make you normal jump
; (simply by making these into B presses).
; By Runic, just made into Uber by SJC

main:
LDA $16 : ORA $18        ; A/B newly pressed this frame
AND #$80 : TSB $16 : TRB $18    ; force button into $16
RTL