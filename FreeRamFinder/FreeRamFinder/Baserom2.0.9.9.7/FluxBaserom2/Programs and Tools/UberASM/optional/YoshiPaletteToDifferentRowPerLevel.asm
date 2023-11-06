; I think the other Yoshi uberASM (which lets you select the starting color)
; only works if you start out spawning on Yoshi. This will affect all Yoshis in a level.


!PaletteRow = $06     ; YXPPCCCT value in hex, but bits only set for CCC, so palette 8 = 00, palette 9 = 02 
             ;                                                   palette A = 04, B = 06; C = 08 
             ;                                                   palette D = 0A, E = 0C, F = 0E

main:
LDX #!sprite_slots-1
.loop
LDA !14C8,x
BEQ .next
LDA !9E,x
CMP #$35                ; Chuck football
BEQ ChangeToPaletteB
.next
DEX
BPL .loop
RTL

ChangeToPaletteB:
LDA !15F6,x
AND #$F1
ORA #!PaletteRow

STA !15F6,x
BRA main_next