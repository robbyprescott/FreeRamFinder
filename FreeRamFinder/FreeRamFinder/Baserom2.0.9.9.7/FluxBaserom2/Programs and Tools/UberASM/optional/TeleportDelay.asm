; This will delay for a second before
; teleporting you to where the current screen exit is set to take you.

; Match the !FreeRAM in your block or whatever. Can be used, for example,
; to be able to activate a switch palace switch that will teleport you
; after being hit (but without the awkward instant teleport).

; If you want to teleport to the midway in the SAME level, 
; go to the Modify Screen Exit menu, put the level number as itself, 
; check the "Go to midway entrance" option. 
; Make sure you have the correct settings in the Modify Main and Midway Entrance menu, too.

!Timer = $0A ; how many frames to wait before running

!FreeRAM = $0E7C  ;or whatever value you want. Match this in block. Can change to $14AF to use on/off as trigger
!FreeRAM2 = $0E7D


init:
STZ !FreeRAM
STZ !FreeRAM2
RTL

main:
LDA !FreeRAM ; check if activated
BEQ Return   ; if not activated, return
LDA !FreeRAM2
CMP #!Timer
BEQ .Switch
INC !FreeRAM2
RTL

.Switch
STZ $88             ;\
STZ $89             ;| Activate teleport to screen exit.
LDA #$06            ;|
STA $71             ;/
STZ !FreeRAM2
Return:
  RTL 
  
  