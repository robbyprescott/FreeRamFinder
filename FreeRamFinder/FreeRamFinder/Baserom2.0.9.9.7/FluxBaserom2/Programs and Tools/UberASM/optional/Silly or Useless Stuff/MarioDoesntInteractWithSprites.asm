;it may break sprites that use $154C for something else, although it's rare
; for example the feather uses it to indicate that it's coming out of a block so it won't move horizontally

main:
  ldx.b #!sprite_slots-1
- lda !14C8,x : cmp #$08 : bcc +
  lda #$FF : sta !154C,x
+ dex : bpl -
  rtl