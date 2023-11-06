!Value = $60 ; I don't understand how the conversion here works, from RGB or whatever to hex

init:
  LDA #$17   ; Everything on mainscreen
  STA $212C
  STA $212E
  STA $0D9D|!addr
  STZ $212D  ; Nothing on subscreen
  STZ $212F
  STA $0D9E|!addr

  LDA #$83  ; Colour subtraction, affect
  STA $40

main:
  LDA #!Value ; 
  STA $0701
RTL