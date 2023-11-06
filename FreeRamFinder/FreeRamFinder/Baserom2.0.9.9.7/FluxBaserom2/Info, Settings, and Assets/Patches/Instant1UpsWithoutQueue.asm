; 1-ups, 1ups

!FreeRAM = $0E0C 

org $028AC8
autoclean JSL OneUpSound
NOP #1

freecode

OneUpSound:
LDA !FreeRAM
BEQ Return
LDA #$01
STA $18E5
BRA End
Return:
LDA #$23
STA $18E5
End:
RTL


; CODE_028AC8:        A9 23         LDA.B #$23                
; CODE_028ACA:        8D E5 18      STA.W $18E5 