!FreeRAM = $0E0B 

org $00F5BB
autoclean JSL GoalHurt
NOP #5

freecode

GoalHurt:
LDA !FreeRAM
BNE Vanilla
LDA $1497 
ORA $1490 
ORA $1493 
BRA End
Vanilla:
LDA $1497 
ORA $1490  
End:
RTL