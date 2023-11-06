; By SJC. 
; Super simple. See L/R switch code for better
; By default you'll start as Mario and then switch


!StartAsMario = 1 ; change to 0 to start as Luigi
!Trigger = $14BE ; FreeRAM, not cleared on level load, but on OW 

load:
if !StartAsMario = 1
LDA !Trigger ; initiate cycle on trigger (triggered after first death)
BEQ End
endif
LDA $0DB3
EOR #$01
STA $0DB3
End:
RTL

init:
STZ $0DA0 ; allow both controllers
RTL

main:
if !StartAsMario = 1
LDA $71
CMP #$09
BEQ No
LDA #$01
STA !Trigger
No:
endif
RTL

