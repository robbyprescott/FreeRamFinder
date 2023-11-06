; Will trigger something on and off 
; whenever you cape ground pound

!CapePoundRAM = $0DEA ; match RAM in patch
!RAMToTrigger = $14AF

!RevertAfterDelay = 0 ; need to add?

init:
STZ !CapePoundRAM
STZ !RAMToTrigger
RTL

main: 
LDA !CapePoundRAM
BEQ + 
LDA #$01
STA !RAMToTrigger ; or LDA !RAMToTrigger : EOR #$01 : STA !RAMToTrigger?

RTL
+
BRA init