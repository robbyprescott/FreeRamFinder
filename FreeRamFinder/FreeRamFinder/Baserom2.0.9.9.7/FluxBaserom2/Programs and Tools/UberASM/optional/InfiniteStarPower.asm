; You'll probably need to change music in level, if 1

!StarMusic = 1

init:
LDA #$01
STA $0EC2 ; skips star low sound
if !StarMusic = 1
LDA #$05 
STA $1DFB
endif
RTL

main:
LDA #$FF
STA $1490
Return:
RTL