!Trigger = $14AF
!FreeRAM = $xxxx

load:
STZ !Trigger
STZ !FreeRAM
RTL

main:
LDA !Trigger ; make sure this is only activated once, obviously
BNE Nope
LDA !FreeRAM|!addr
BNE Nope
LDA #!SFX 
STA !SFXBank|!addr
LDA #$01
STA !FreeRAM|!addr
Nope:
RTL