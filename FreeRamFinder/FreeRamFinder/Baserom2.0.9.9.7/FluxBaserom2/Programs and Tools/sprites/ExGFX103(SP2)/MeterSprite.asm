;-----------------------------------------------------------------------------------------
; Meter v1.0 , by Fernap
;
; Uses extra bit: No
;-----------------------------------------------------------------------------------------

; set by uber once
!MeterMax = !1504
!MeterSize = !1510   ; this one isn't cleared by default
!MeterXOffset = !151C
!MeterYOffset = !1534
!MeterFlags = !1570
  !FlagHorizontal = $01
  !FlagDrawEmpty = $02
  !FlagDrawFull = $04
  !FlagDrawUnchanged = $08
!MeterUnchangedLimit = !1594
!MeterTilemapLow = !extra_byte_1
!MeterTilemapMed = !extra_byte_2
!MeterTilemapHigh = !extra_byte_3
!MeterID = !C2


; set by uber each frame
!MeterValue = !1602
!MeterValueFrac = !160E
!MeterPalette = !1626

; set by us
!MeterPreviousValue = !187B
!MeterUnchangedTimer = !154C

;-------
; Main
;-------

print "MAIN ",pc
  phb
  phk : plb
  jsr Main
  plb
  rtl


Main:
  lda !MeterValue,x
  cmp !MeterPreviousValue,x
  beq +
  sta !MeterPreviousValue,x
  lda !MeterUnchangedLimit,x : sta !MeterUnchangedTimer,x     ; value changed, so reset the timer
+:

  lda !MeterValue,x
  bne +
  lda !MeterFlags,x : and.b #!FlagDrawEmpty
  beq .Return                                 ; if meter at 0 and flag clear, skip gfx
  lda !MeterValue,x
+:

  cmp !MeterMax,x
  bne +
  lda !MeterFlags,x : and.b #!FlagDrawFull
  beq .Return                                 ; if meter at max and flag clear, skip gfx
+:

  lda !MeterUnchangedTimer,x
  bne +
  lda !MeterFlags,x : and.b #!FlagDrawUnchanged
  beq .Return                                ; if meter's been unchanged for long enough and flag clear, skip gfx
+:

  ; compute (val / max) * (8 * size) = (val * size * 8) / max for the number of filled pixels in the meter
  if !sa1
    stz $2250                          ; multiplication mode
    lda !MeterValue,x
    sta $2251                                ; mult A low
    stz $2252                                ; mult A high
    lda !MeterSize,x : asl #3
    sta $2253                                ; mult B low
    stz $2254                                ; mult B high
    bra $00                                  ; wait (3 cycles + 2 from the subsequent lda = 5)

    lda #$01 : sta $2250                     ; division mode
    rep #$20
    lda $2306                                ; mult result bytes 0 & 1
    sta $2251                                ; dividend low & high
    sep #$20
    lda !MeterMax,x
    sta $2253                                ; divisor low
    stz $2254                                ; divisor high
    nop : bra $00                            ; wait
    lda $2306                                ; quotient low
  else
    lda !MeterValue,x
    sta $4202               ; mult A
    lda !MeterSize,x : asl #3
    sta $4203               ; mult B
    nop #4                  ; wait

    lda $4216               ; mult result low
    sta $4204               ; dividend low
    lda $4217               ; mult result high
    sta $4205               ; dividend high
    lda !MeterMax,x
    sta $4206               ; divisor
    nop #8                  ; wait

    lda $4214               ; quotient low
  endif

  jsr SpriteGraphics
.Return:
  rts

;----------------------------------------------------------------------------------------------------------------

;------
; Graphics routine
;------

; $0a-0c - pointer to tilemap
; $0d - number of pixels full left to draw
; $0e - horizontal flag
; $0f - tile loop counter

; passed number of full pixels to draw in A
SpriteGraphics:
  sta $0d                                               ; set up temp stuff
  lda !MeterFlags,x : and.b #!FlagHorizontal : sta $0e
  lda !MeterSize,x : sta $0f
  lda !MeterTilemapLow,x : sta $0a
  lda !MeterTilemapMed,x : sta $0b
  lda !MeterTilemapHigh,x : sta $0c

  stz $01                                               ; x offset + sprite x -> tile x
  lda !MeterXOffset,x
  bpl +
  dec $01
+:
  clc : adc !sprite_x_low,x : sta $00
  lda $01 : adc !sprite_x_high,x : sta $01

  stz $03                                              ; ditto y
  lda !MeterYOffset,x
  bpl +
  dec $03
+:
  clc : adc !sprite_y_low,x : sta $02
  lda $03 : adc !sprite_y_high,x : sta $03

  rep #$20
  lda $00 : sec : sbc $1a : sta $00                    ; and minus screen boundaries
  lda $02 : sec : sbc $1c : sta $02
  sep #$20

  lda !166E,x : and #$01                  ; "use second graphics page" flag from third tweaker byte
  ora !MeterPalette,x                     ; palette bits should be set as 0000ccc0
  ora #%00100000                          ; pri 2
  sta $05

  lda !sprite_oam_index,x
  tax

  ldy #$09
  lda [$0a],y
  sta $04
  jsr DrawTile

.Loop:
  lda $0e
  bne +
  lda $02 : sec : sbc #$08 : sta $02    ; if vetical, subtract 8 from y position (even if loop is finished, to take care of the cap)
  lda $03 : sbc #$00 : sta $03
  bra ++
+:
  lda $00 : clc : adc #$08 : sta $00    ; if horizontal, add 8 to x
  lda $01 : adc #$00 : sta $01
++:
  lda $0f
  beq .EndLoop

; if pixels >= 8, use 8 as the tile index, subtract 8
; if pixels <= 8, use pixels as the tile index, set to 0
  lda $0d
  cmp #$08
  bcc +
  ldy #$08                  ; pixels >= 8
  sec : sbc #$08 : sta $0d
  bra ++
+:
  tay                       ; pixels < 8
  stz $0d
++:

  lda [$0a],y
  sta $04

  jsr DrawTile

  dec $0f
  bra .Loop

.EndLoop:
  lda $0e
  beq +
  lda $05 : eor #$40 : sta $05    ; if horizontal, flip x
  bra ++
+:
  lda $05 : eor #$80 : sta $05    ; if vertical, flip y
++:
  ldy #$09
  lda [$0a],y
  sta $04
  jsr DrawTile                    ; draw the last cap tile

  ldx $15e9|!addr
  rts


; $00-01 - x position
; $02-03 - y position
; $04 - tile num
; $05 - yxppccct
; X - oam offset, updated by call
DrawTile:
  rep #$20
  lda $00
  cmp.w #-7
  bmi .Return       ; if x < -7
  cmp.w #256
  bpl .Return       ; if x >= 256
  lda $02
  cmp.w #-7
  bmi .Return       ; if y < -7
  cmp.w #224
  bpl .Return       ; if x >= 224
  sep #$20

  lda $00 : sta $0300|!addr,x
  lda $02 : sta $0301|!addr,x
  lda $04 : sta $0302|!addr,x
  lda $05 : sta $0303|!addr,x

  txa : lsr #2 : tax
  lda $01 : and #$01 : sta $0460|!addr,x  ; 9th bit of x

  txa : inc : asl #2 : tax         ; next OAM slot

.Return:
  sep #$20
  rts

