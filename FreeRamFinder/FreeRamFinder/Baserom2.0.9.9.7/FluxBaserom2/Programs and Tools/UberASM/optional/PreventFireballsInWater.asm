; Need to have applied fireball flag patch

init:
STZ $0DED
RTL

main:
LDA $9D				;freeze flag or pause, don't do fire stuff if either is set
ORA $13D4|!addr			;
BNE .Re				;

LDA $19				;if not fire enabled
CMP #$03			;
BNE .Re				;don't bother

LDA $75				;not in water?
BEQ .Re				;can shoot

LDA #$01
STA $0DED
BRA .End

.Re
STZ $0DED
.End
RTL