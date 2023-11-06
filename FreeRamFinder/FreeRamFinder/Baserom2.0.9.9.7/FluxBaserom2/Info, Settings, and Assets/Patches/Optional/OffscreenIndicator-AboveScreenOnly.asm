; Only use if you're not using UberASM version

; Offscreen indicator. Displays a small sprite at the top/bottom of the screen to show where Mario is when he's offscreen.
;  Change the settings below as you need to, then insert with asar.

;;;;;;;;;;;;;;;;
;;; Settings ;;;
;;;;;;;;;;;;;;;;

; Tile and YXPPCCCT for the marker when Mario is above the screen.
!tileAbove  =   $1D     ; Tile number
!propsAbove =   $28     ; YXPPCCCT properties

; Tile and YXPPCCCT for the marker when Mario is below the screen.
!tileBelow  =   $69     ; Tile number
!propsBelow =   $28     ; YXPPCCCT properties

; How many pixels the tile should be offset from the very top/bottom of the screen.
;  Use this if you want a small gap between the very edge and the actual tile.
!yOffAbove  =   $02     ; From the top of the screen
!yOffBelow  =   $02     ; From the bottom of the screen

;;;;;;;;;;;;;;;;;;;;;;;;;

!oamIndex   =   $0000   ; OAM index (from $0200) to use.
    ; ^ don't touch this one unless you know how it works.
    ;   this default value isn't really used by much so it should be fine.

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $00A299
    autoclean jsl main

freecode

main:
    phb
    phk
    plb
    LDY #$00
    REP #$20
    LDA $80
    CMP #$FFE1
    BMI .offscreen
    LDX $19
    BNE +
    CLC : ADC #$0008
  + CMP #$00D9
    BMI .ret
    INY
    
  .offscreen
    SEP #$20
    LDA $7E
    CLC : ADC #$04
    STA $0200|!addr+!oamIndex
    LDA yOffs,y
    STA $0201|!addr+!oamIndex
    LDA Tiles,y
    STA $0202|!addr+!oamIndex
    LDA Props,y
    STA $0203|!addr+!oamIndex
    STZ $0420|!addr+(!oamIndex/4)

  .ret
    SEP #$20
    plb
    jsl $00F6DB|!bank   ; Original code
    RTL

Tiles:
    db !tileAbove,!tileBelow
Props:
    db !propsAbove,!propsBelow
yOffs:
    db !yOffAbove,$D7-!yOffBelow