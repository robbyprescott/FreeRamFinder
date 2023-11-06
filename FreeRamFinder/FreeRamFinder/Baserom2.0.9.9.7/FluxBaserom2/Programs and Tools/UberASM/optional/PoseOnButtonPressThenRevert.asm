; By SJandCharlieTheCat
; Short pose when you do a specified button press

!FreeRAMToSetAndRevert = $0E57
!FreeRAM2 = $0E58
!Timer = #$0F 

init:
STZ !FreeRAM2
STZ !FreeRAMToSetAndRevert
RTL
  
main:
lda $16
and #$40 ; check Y/X press
beq +
lda #$01
sta !FreeRAMToSetAndRevert
+
lda !FreeRAMToSetAndRevert ; if set 
beq return ; check
lda #$30 ; make pose.
sta $13E0
LDA !FreeRAM2
  CMP !Timer
  BEQ Revert
  INC !FreeRAM2
return:
  RTL
Revert:
  BRA init

