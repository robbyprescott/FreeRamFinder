; Actually just disables Y and X presses when on Yosh

main:
LDA $187A
BEQ Return
LDA #$40
TRB $16
Return:
RTL

; You can also do
; LDA #$01
; STA $1410,
; but it has some potential unwanted effects