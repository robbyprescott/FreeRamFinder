!Address = $19

main:
LDA $18					
AND #$10 ; press R		
BNE Thing ; If so, go to other section.
LDA $18 ; If not, check if
AND #$20 ; press L
BEQ Return ; If not...
LDA !Address
CMP #$01 ; prevent 
BCC Return ; underflow
DEC !Address
Return:
RTL

Thing:
LDA !Address
CMP #$03 ; but won't iincrement any more if gets to #$03
BCS End
INC !Address
End:
RTL