; Significantly lowers the 60 frame delay after pressing start to (un)pause.
; Be warned that this will make pause buffering much easier.

!FreeRAM = $0EAC

org $00A22C
autoclean JSL PauseBuffer
NOP

freecode

PauseBuffer:
LDA !FreeRAM
BNE Original
LDA.B #$10
STA.W $13D3
RTL

Original:
LDA.B #$3C
STA.W $13D3
RTL

;CODE_00A22C:        A9 3C         LDA.B #$3C                ;\ disable pressing pause 
;CODE_00A22E:        8D D3 13      STA.W $13D3               ;/