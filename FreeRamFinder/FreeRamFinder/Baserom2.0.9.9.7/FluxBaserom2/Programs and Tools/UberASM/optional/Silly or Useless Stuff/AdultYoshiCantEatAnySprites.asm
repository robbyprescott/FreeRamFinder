; By SJC
; Makes all sprites inedible by adult Yoshi

main:
  LDX #!sprite_slots-1
.loop
  LDA !1686,x  
  ORA #$01
  STA !1686,x
  DEX
  BPL .loop
  RTL