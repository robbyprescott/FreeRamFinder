!MeterSpriteNum = $B8     ; sprite number inserted as with Pixi

;----------------------------------------------------------------------
; Don't change these

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
!MeterPreviousValue = !187B

; set by uber each frame
!MeterValue = !1602
!MeterValueFrac = !160E
!MeterPalette = !1626

; bleh
if !sa1
  !SprSize = 22
else
  !SprSize = 12
endif

;----------------------------

load:
  LDA #$01
  STA $0E0A ; disables item reserve box GFX by default, to prevent glitchy GFX
  RTL 

init:
  jsl $02A9E4|!bank       ; Get free sprite slot
  cpy #$ff
  beq .Return             ; returns Y = $ff if none (which shouldn't really happen)
  tyx

  jsl $07F722|!bank                               ; zero sprite tables
  lda.b #!MeterSpriteNum : sta !new_sprite_num,x
  jsl $0187A7|!bank                               ; Pixi's routine that sets tweaker bytes, etc
  lda #$08 : sta !extra_bits,x
  lda #$01 : sta !sprite_status,x

  lda.b #!ID : sta !MeterID,x
  lda.b #!MaxValue : sta !MeterMax,x
  lda.b #!InitialValue : sta !MeterValue,x : sta !MeterPreviousValue,x
  stz !MeterValueFrac,x
  lda.b #!Size : sta !MeterSize,x
  lda.b #!XOffset : sta !MeterXOffset,x
  lda.b #(!Horizontal*!FlagHorizontal)+(!DrawEmpty*!FlagDrawEmpty)+(!DrawFull*!FlagDrawFull)+(!DrawUnchanged*!FlagDrawUnchanged) : sta !MeterFlags,x
  lda.b #!UnchangedLimit : sta !MeterUnchangedLimit,x
  lda.b #MeterTiles&$FF : sta !MeterTilemapLow,x
  lda.b #(MeterTiles>>8)&$FF : sta !MeterTilemapMed,x
  lda.b #(MeterTiles>>16)&$FF : sta !MeterTilemapHigh,x

  lda !166E,x                      ; 3rd tweaker byte
  if !UseSecondGfxPage == 1
  ora #$01
  else
  and #$fe
  endif
  sta !166E,x

.Return:
  rtl

;------------------------

main:
  ldx.b #!SprSize-1
.Loop:
  lda !sprite_status,x
  beq .Continue
  lda !extra_bits,x : and #$08
  beq .Continue
  lda !new_sprite_num,x
  cmp.b #!MeterSpriteNum
  bne .Continue
  lda !MeterID,x
  cmp.b #!ID
  beq .FoundIt
.Continue:
  dex
  bpl .Loop
  rtl                 ; not found, so bail out

.FoundIt:
  lda $9d
  ora $13d4|!addr
  bne .Locked                      ; don't update value if sprites are locked or game is paused
  lda !MeterValueFrac,x : sta $00
  lda !MeterValue,x : sta $01
  jsr GetNewValue
  lda $00 : sta !MeterValueFrac,x
  lda $01 : sta !MeterValue,x

.Locked:
  lda !MeterValue,x
  cmp.b #!LowValue
  bcs +
  lda.b #!LowPalette<<1
  bra .SetPalette
+:
  cmp.b #!MediumValue
  bcs +
  lda.b #!MediumPalette<<1
  bra .SetPalette
+:
  lda.b #!HighPalette<<1
.SetPalette:
  sta !MeterPalette,x

  lda $94 : sta !sprite_x_low,x
  lda $95 : sta !sprite_x_high,x
  lda $96 : sta !sprite_y_low,x
  lda $97 : sta !sprite_y_high,x

  lda.b #!YOffset
  ldy $187a|!addr           ; riding yoshi?
  beq +
  clc : adc #!YoshiOffset   ; if so, additional yoshi offset
+:
  ldy $19                   ; powerup status
  beq +
  clc : adc #!BigMarioOffset   ; if big mario, additional offset
+:
  sta !MeterYOffset,x       ; set the current Y offset

  rtl

;-----------------
; Helper routines

; adds the 16-bit unsigned value at $02-03 to the 16-bit unsigned value at $00-01, clipping to !MaxValue if appropriate
; if the result is at the maximum, then the c flag is set, otherwise it's clear

AddValue:
  rep #$20
  lda $00
  clc : adc $02
  bcs .Max                 ; if carry set from the add, then it's automatically over the max
  cmp.w #(!MaxValue<<8)
  bcs .Max                 ; if carry set here, then the result >= max

  sta $00
  sep #$20
  rts                      ; carry already clear

.Max:
  lda.w #(!MaxValue<<8)    ; result too high, so just set to the max
  sta $00
  sep #$20
  rts                      ; carry already set

; subtracts the 16-bit unsigned value at $02-03 from the 16-bit unsigned value at $00-01, clipping to 0 if appropriate
; if the result is zero, then the c flag is set, otherwise it's clear
SubtractValue:
  rep #$20
  lda $00
  sec : sbc $02
  beq .Zero          ; if the result is 0
  bcc .Zero          ; or a borrow is needed

  sta $00            ; result > 0, so set that as new amount
  sep #$20
  clc                ; and clear carry bit = result not 0
  rts                 

.Zero:
  stz $00            ; otherwise, set it to 0
  sep #$21           ; and set carry bit
  rts
