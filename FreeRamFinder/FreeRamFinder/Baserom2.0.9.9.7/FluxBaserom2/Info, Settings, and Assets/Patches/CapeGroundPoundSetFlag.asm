; By SJandCharlieTheCat

; This sets two RAM addresses when you pound the ground with a cape dive.
; The first is triggered on and off each time you cape ground pound.
; The second is only activated on, e.g. for you to be able to manually revert off.

!FreeRAM = $0DEA
!FreeRAM2 = $0DEB

org $0294C1 
autoclean JSL AddCapePoundDetect
NOP #4

freecode

AddCapePoundDetect:
LDA.B #$30                ; \ Set ground shake timer 
STA.W $1887
LDA !FreeRAM
EOR #$01
STA !FreeRAM  ; replace STZ.W $14A9
LDA #$01
STA !FreeRAM2
RTL


; $7E:14A8 decrements every frame automatically until it reaches zero, while $7E:14A9 and $7E:14AA decrement every fourth frame. 
; $7E:14A9 is cleared when the player ground pounds with the cape (this can be prevented by setting $02:94C6 to NOP #3 or [EA EA EA])

; $0294C6:        $9C,$A9,$14