; Makes dismount attempts just regular jumps instead

main:
LDA $187A|!addr			;/
BEQ .End				;\ Return if not on Yoshi.
LDA $16 : ORA $18        ; A/B newly pressed this frame
AND #$80 : TSB $16 : TRB $18    ; force button into $16
.End
RTL