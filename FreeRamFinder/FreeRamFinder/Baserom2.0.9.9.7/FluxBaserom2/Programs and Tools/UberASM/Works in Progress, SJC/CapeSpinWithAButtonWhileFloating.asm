; Add more poses

main:
LDA $19
CMP #$02 ; have cape
BNE Return
LDA $13E0
; CMP #$0B ; regular jump up pose
CMP #$24 ; falling pose
BNE Return
LDA $18
AND #$80
BEQ Return
LDA #$12                ;\
STA $14A6               ;/ make mario spin
LDA #$04                ; \ Play sound effect 
STA $1DFC               ; /
Return:
RTL