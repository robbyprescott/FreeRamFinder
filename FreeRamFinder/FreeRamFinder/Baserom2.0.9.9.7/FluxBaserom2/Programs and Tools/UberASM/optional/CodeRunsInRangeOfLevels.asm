!LowestLevel = $0107
!HighestLevel = $0109 

main:
REP #$20
LDA $010B|!addr
CMP #!LowestLevel
BCC Final
CMP #!HighestLevel+1
BCS Final
SEP #$20

; code, e.g. INC $19 to test

Final:
SEP #$20
RTL