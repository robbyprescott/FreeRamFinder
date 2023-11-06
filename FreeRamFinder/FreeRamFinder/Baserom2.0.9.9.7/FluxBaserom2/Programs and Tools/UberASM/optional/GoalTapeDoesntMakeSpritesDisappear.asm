; Thanks binavik

!EraseWithoutCoin = 0 ; If you set this to 1, sprites will simply disappear without spawning the coin

main:
  LDX #!sprite_slots-1
.loop
  LDA !1686,x  ;don't turn into coin
  ORA #$20
  STA !1686,x
  if !EraseWithoutCoin = 0
  LDA !190F,x
  ORA #$02     
  STA !190F,x
  else
  LDA !190F,x
  ORA #$20
  STA !190F,x
  endif
  DEX
  BPL .loop
RTL