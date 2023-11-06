; Mario will remain at the furthest left of the screen,
; giving you the widest range of visibility when you move forward.
; Useful for autorunners, etc.
init:
main:
LDA #$02 ; 04 for opposite
STA $13FE
RTL