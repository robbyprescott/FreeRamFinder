; E.g. make trigger block simply
; LDA #$01
; STA !FreeRAM

!Timer = $18 ; how many frames to wait before running

!FreeRAM = $0EB0  ;or whatever value you want. Can change to $14AF to use on/off as trigger
!FreeRAM2 = $0EB1
;!FreeRAM3 = $0EAF if not using...


init:
STZ !FreeRAM
STZ !FreeRAM2
;STZ !FreeRAM3
RTL

main:
LDA !FreeRAM ; check if activated
BEQ Return   ; if not activated, return
LDA !FreeRAM2
CMP #!Timer
BEQ .YourCode
INC !FreeRAM2
RTL

.YourCode
LDA #$01  ; example
STA $14AF ; code
;end of your code
STZ !FreeRAM2
Return:
  RTL 