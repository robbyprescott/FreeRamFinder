; You can still take damage if big

!CantDieInPit = 1 ; change to 1 to get a boost whenever you fall in a pit

load:
LDA #$01
STA $0EB7
if !CantDieInPit
STA $0EB8
endif
RTL