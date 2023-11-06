; Horizontal meter.
; Use with ExGFX103 in SP2
; Disables item reserve box GFX by default, to prevent glitchy GFX

; If you're using this along with other Ubers in the same level,
; read the README in /MeterAirOrPSwitch/ for instructions

!DeductAmount = $0100      ; how much to deduct each frame the player is in water (8.8 fixed point value -- $0100 will deduct 1 unit each frame, $0280 will deduct 2.5, etc)
!RestoreAmount = $0300     ; how much to add to the meter each frame the player is out of the water (8.8 fixed point value as above)
!CoinAmount = $0500        ; how much air is restored by picking up a coin (8.8 fixed point value -- $0500 would give back 5 units, etc)
!CanBreatheAtSurface = 1   ; 1 if Mario can breathe at the surface, 0 if not

;-------------------------------------------------------------------------

; Tile numbers to use for the sprite:
; The first 9 tiles are for 0-8 pixels full, and the last is the end cap tile (bottom for vertical, left for horizontal).
MeterTiles:
  db $E6, $E7, $CC, $CD, $EB, $F6, $F7, $DC, $DD, $FB  ; SP2, replaces item-changing box, item reserve GFX, keyhole,
                                                       ; Default was $00, $01, $02, $03, $04, $10, $11, $12, $13, $14

!UseSecondGfxPage = 0   ; set to 1 to use SP3/4, or 0 to use SP1/2

!Size = 2                  ; the number of 8x8 segments for the main part of the meter (2 tiles beyond this are used for the caps too)
!XOffset = 16              ; the signed x offset from the player, in pixels (in the range -128 to 127)
!YOffset = 0               ; the signed y offset from the player, in pixels (in the range -128 to 127)
!BigMarioOffset = 0        ; additional y offset when Mario has at least a mushroom
!YoshiOffset = 8           ; additional y offset when riding Yoshi
!Horizontal = 1            ; 0 for vertical, 1 for horizontal
!DrawEmpty = 1             ; if 0, the meter will never be displayed while empty; if 1, it may be
!DrawFull = 1              ; if 0, the meter will never be displayed while full; if 1, it may be
!DrawUnchanged = 0         ; if 0, the meter will not be drawn when its value hasn't changed for a specified length of time; if 1, this isn't considered
!UnchangedLimit = 120      ; the length of time (in frames) that the meter value should remain unchanged in order to stop drawing if the above option is 0 (max 255)
!MaxValue = $ff            ; the maximum value the meter can be (max $ff = 255)
!InitialValue = !MaxValue  ; initial meter value

; These control what palette(s) to use for various meter levels
; If the meter's value is less than !LowValue, it will use !LowPalette
; Otherwise, if it's less than !MediumValue, it will use !MediumPalette
; Otherwise, it will use HighPalette

!LowValue #= !MaxValue/4
!MediumValue #= !MaxValue/2

!LowPalette = 4            ; these should be sprite palettes 0-7 (subtract 8 from the overall SNES palette number)
!MediumPalette = 2
!HighPalette = 5

!ID = 1                    ; If using more than 1 meter simultaneously, set these to unique values so they can be differentiated

;-------------------------------------------------------------------------

incsrc "MeterBase.asm"

GetNewValue:
  if !CoinAmount > 0
    lda $13cc|!addr                         ; coins to give
    beq +
    lda.b #(!CoinAmount&$ff) : sta $02
    lda.b #(!CoinAmount>>8) : sta $03
    jsr AddValue
  endif

+:
  lda $75                                 ; player in water flag
  beq .NotInWater
  if !CanBreatheAtSurface
    lda $13fa|!addr                       ; can jump out of water flag
    bne .NotInWater
  endif

.InWater:
  lda.b #(!DeductAmount&$ff) : sta $02
  lda.b #(!DeductAmount>>8) : sta $03
  jsr SubtractValue
  bcc .Return                              ; carry clear -- result not 0
  jsl $00F606|!bank                        ; otherwise, kill mario
  rts

.NotInWater:
  lda.b #(!RestoreAmount&$ff) : sta $02
  lda.b #(!RestoreAmount>>8) : sta $03
  jsr AddValue

.Return:
  rts

