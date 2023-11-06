; By SJC

main:
LDX #!sprite_slots-1 
.loop
LDA !9E,x
CMP #$3E ; p-switch
BNE .next
LDA !163E,x ; simple check of smushed state won't work
CMP #$01
BCC .next
LDA #$04 ; "spin-jump" state, i.e. puff of smoke.
STA !14C8,x
LDA #$10 ; timer
STA !1540,x
.next
DEX
BPL .loop
RTL
