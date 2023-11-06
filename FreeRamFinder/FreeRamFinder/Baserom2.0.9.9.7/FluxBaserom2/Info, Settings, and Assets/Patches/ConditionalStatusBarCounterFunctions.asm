!FreeRAM = $0DEC

org $00A2D5 ; vanilla ($20,$1A,$8E)
autoclean JSL ConditionalStatusCounters
NOP #3

freecode

ConditionalStatusCounters:
LDA !FreeRAM
BNE .jslrtsreturn ; counters will function unless disabled by setting RAM
PHK
PEA .jslrtsreturn-1
PEA $84CF-1
JML $8E1A
.jslrtsreturn
JML $00E2BD