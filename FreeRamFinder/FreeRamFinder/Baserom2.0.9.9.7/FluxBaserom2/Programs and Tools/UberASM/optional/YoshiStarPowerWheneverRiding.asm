!StarMusic = 1

init:
LDA #$01
STA $0EC2 ; skips star low sound
RTL

main:
LDA $187A ; check if on Yoshi
BEQ Return
LDA #$FF
STA $1490
RTL

Return:
STZ $1490
RTL