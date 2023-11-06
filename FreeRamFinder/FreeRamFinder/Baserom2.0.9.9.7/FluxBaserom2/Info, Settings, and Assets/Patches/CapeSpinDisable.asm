org $00D06C
autoclean JSL CapeStuff
NOP #4

freecode

CapeStuff:
; CODE_00D095 fireball
LDA $73
ORA $187A 
ORA $140D
ORA $0E26 ; FreeRAM
RTL