; If using level mode 1F with translucent layer 2 FG,
; sprites will go in front of layer 2, instead of behind it

init:
LDA #$1F
STA $212C
STA $212E
RTL