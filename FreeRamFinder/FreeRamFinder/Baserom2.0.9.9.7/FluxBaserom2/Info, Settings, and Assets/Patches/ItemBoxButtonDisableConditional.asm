!FreeRAM = $0DF9

org $00C56C 
autoclean JML Condition

freecode

Condition:
LDA !FreeRAM 
BEQ Return
LDA $16                   
AND #$00
BRA End
Return:
LDA $16                   
AND #$20 
End:
JML $00C570