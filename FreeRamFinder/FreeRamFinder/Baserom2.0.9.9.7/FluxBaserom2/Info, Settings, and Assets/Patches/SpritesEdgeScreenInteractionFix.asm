; Fixes sprites losing their interaction with the player while they're going offscreen, 
; touching the edge of the screen (Banzais, etc.)


org $01A7F0
db $EA,$EA,$EA     ; vanilla $1D,$A0,$15