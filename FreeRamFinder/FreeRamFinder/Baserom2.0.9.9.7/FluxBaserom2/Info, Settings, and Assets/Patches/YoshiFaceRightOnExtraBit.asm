; Restore:
; org $0183E0 
; db $DE,$0E,$16,$FE,$7C,$15


org $0183E0
  autoclean JSL YoshiThing
  NOP #2 ; clear the remaining two bytes @ $0183E4

freecode 

YoshiThing:
  DEC $160E,x
  LDA $7FAB10,x ; !extra_bits,x
  AND #$04
  BEQ Nope
  INC $157C,x
  BRA End
  Nope:
  STZ $157C,x
  End:
  RTL