org $00D908
autoclean JSL Float
NOP #1

freecode

Float:
LDA $0E08
BNE Restore
LDA #$10  ; vanilla float              
STA $14A5 
Restore:
RTL

;CODE_00D908:        A9 10         LDA.B #$10                
;CODE_00D90A:        8D A5 14      STA.W $14A5 