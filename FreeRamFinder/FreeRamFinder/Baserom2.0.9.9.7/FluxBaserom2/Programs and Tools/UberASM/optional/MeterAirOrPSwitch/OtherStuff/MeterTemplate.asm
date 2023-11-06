; Add any type-specific defines here
	
;-------------------------------------------------------------------------

; These are common to all meter types

; Tile numbers to use for the sprite:
; The first 9 tiles are for 0-8 pixels full, and the last is the end cap tile (bottom for vertical, left for horizontal).
MeterTiles:
  db $00, $01, $02, $03, $04, $10, $11, $12, $13, $14

!UseSecondGfxPage = 0   ; set to 1 to use SP3/4, or 0 to use SP1/2

!Size = 3                  ; the number of 8x8 segments for the main part of the meter (2 tiles beyond this are used for the caps too)
!XOffset = 16              ; the signed x offset from the player, in pixels (in the range -128 to 127)
!YOffset = 0               ; the signed y offset from the player, in pixels (in the range -128 to 127)
!BigMarioOffset = 0        ; additional y offset when Mario has at least a mushroom
!YoshiOffset = 8           ; additional y offset when riding Yoshi
!Horizontal = 0            ; 0 for vertical, 1 for horizontal
!DrawEmpty = 0             ; if 0, the meter will never be displayed while empty; if 1, it may be
!DrawFull = 1              ; if 0, the meter will never be displayed while full; if 1, it may be
!DrawUnchanged = 1         ; if 0, the meter will not be drawn when its value hasn't changed for a specified length of time; if 1, this isn't considered
!UnchangedLimit = 255      ; the length of time (in frames) that the meter value should remain unchanged in order to stop drawing if the above option is 0
!InitialValue = 0          ; initial meter value
!MaxValue = 255            ; the maximum value the meter can be

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

; This routine is passed the current (8.8 fixed point) meter value in $00-01 ($01 has the whole number part, $00 has the fractional part)
; It should return the new value in the same way.
GetNewValue:
  rts


