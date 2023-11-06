; By SJandCharlieTheCat

; No idea what $13FA does

main:
LDA $75 ; In water
AND $148F ; carrying object. $1470 carrying enemy
BEQ ReturnWaterSFX
LDA $15 
AND #$08 ; check if
CMP #$08 ; holding up
BNE ReturnWaterSFX
LDA $15 
AND #$80 ; check if press B
BEQ ReturnWaterSFX
;LDA $7D
;BPL Return
LDA #$0E
STA $1DF9
ReturnWaterSFX:
RTL