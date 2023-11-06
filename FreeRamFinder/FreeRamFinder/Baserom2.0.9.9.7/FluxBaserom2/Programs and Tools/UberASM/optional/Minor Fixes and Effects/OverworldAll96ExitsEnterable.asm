; mainly for testing purposes, I guess.
; Put this in Gamemode 0E
; Note that the paths won't automatically show up.


init:
LDX #$5F ; 95 (+1)
-
LDA $1EA2,X
ORA #$8F
STA $1EA2,X
DEX
BPL -
RTL