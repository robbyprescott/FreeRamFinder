!DisableLRFireballs = 1

init:
if !DisableLRFireballs
LDA #$01
STA $0DEE
endif
RTL

main:
LDA $19
CMP #$02 ; must have cape
BNE Return
LDA $18
AND #$30
BEQ Return
LDA #$12                ;\
STA $14A6               ;/ make mario spin
LDA #$04                ; \ Play sound effect 
STA $1DFC               ; /
Return:
RTL