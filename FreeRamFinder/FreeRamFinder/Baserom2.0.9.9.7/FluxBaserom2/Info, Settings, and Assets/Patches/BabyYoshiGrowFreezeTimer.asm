; Conditional for how quickly baby Yoshi will grow into adult Yoshi.
; Normally has an awkward freeze

!FreeRAM = $0E09

org $01A2EE
autoclean JSL GrowTime
NOP #1

freecode

GrowTime:
LDA !FreeRAM
BNE OriginalTime ; If not set, go back to original
LDA #$10
STA $18E8
BRA Return
OriginalTime:
LDA #$40
STA $18E8
Return:
RTL


;CODE_01A2EE:        A9 40         LDA.B #$40                
;CODE_01A2F0:        8D E8 18      STA.W $18E8