print "Displays + starts (or stops) the timer when used with various TimerOnly Ubers."

!FreeRAMPause = $0EB9
!FreeRAMVisible = $0EBA

db $42
JMP Mario : JMP Mario : JMP Mario
JMP Return : JMP Return : JMP Return : JMP Return
JMP Mario : JMP Mario : JMP Mario

Mario:
;lda #$01
stz !FreeRAMPause ; or sta to kill if using normal
stz !FreeRAMVisible
Return:
RTL 