; Water Bubble extended sprite disassembly ($12)
; Based on Thomas' all.log

!OnlyDespawnOffscreen = 1
!SurviveOutsideOfWater = 1 ; no effect if !OnlyDespawnOffscreen = 1
!TileNum = $1C
!TileProps = $04 ; YXPPCCCT

macro localJSL(dest, rtlop)
    assert read1(<rtlop>) == $6B, "rtl op should point to a rtl"
    assert bank(<dest>) == bank(<rtlop>)
    PHB            ;first save our own DB
    PHK            ;first form 24bit return address
    PEA.w ?return-1
    PEA.w <rtlop>-1        ;second comes 16bit return address
    PEA.w ((bank(<dest>))<<8)|(bank(<dest>))    ;change db to desired value
    PLB
    PLB
    JML <dest>
?return:
    PLB            ;restore our own DB
endmacro

; Water bubble misc RAM:
; $1765 - Frame counter for timing Y speed movement.

print "MAIN ",pc
WaterBubble:                      ;-----------| Underwater bubble MAIN
    LDA $9D                       ;$029EEE    |\ Branch if game frozen.
    BNE Graphics                  ;$029EF0    |/
    INC.w $1765|!Base2,X          ;$029EF2    |\
    LDA.w $1765|!Base2,X          ;$029EF5    ||
    AND.b #$30                    ;$029EF8    ||
    BEQ AfterRise                 ;$029EFA    || For 48 frames out of 64, move upwards at 1 pixel per frame.
    DEC.w $1715|!Base2,X          ;$029EFC    ||  For the remaining 16, freeze the bubble in place vertically.
    LDY.w $1715|!Base2,X          ;$029EFF    ||
    INY                           ;$029F02    ||
    BNE AfterRise                 ;$029F03    ||
    DEC.w $1729|!Base2,X          ;$029F05    |/
AfterRise:                        ;           |
if !OnlyDespawnOffscreen == 1
    BRA Graphics
endif
    TXA                           ;$029F08    |\
    EOR $13                       ;$029F09    ||
    LSR                           ;$029F0B    ||
    BCS Graphics                  ;$029F0C    ||
    %localJSL($02A56E, $028089)   ; Extended sprite-object interaction routine
    BCS Erase                     ;$029F11    ||
if !SurviveOutsideOfWater == 1
    BRA Graphics
else
    LDA $85                       ;$029F13    || Branch if not touching a solid block,
    BNE Graphics                  ;$029F15    ||  and either in a water level or touching a water block.
    LDA $0C                       ;$029F17    ||
    CMP.b #$06                    ;$029F19    || On odd frames, branch irregardless.
    BCC Graphics                  ;$029F1B    ||
    LDA $0F                       ;$029F1D    ||
    BEQ Erase                     ;$029F1F    ||
    LDA $0D                       ;$029F21    ||
    CMP.b #$06                    ;$029F23    ||
    BCC Graphics                  ;$029F25    |/
endif
Erase:                            ;           |
    STZ.w $170B|!Base2,X ; Erase the extended sprite.
    RTL

Graphics:                              ;```````````| Bubble is in water.
    LDA.w $1715|!Base2,X               ;$029F2A    |\
    CMP $1C                            ;$029F2D    ||
    LDA.w $1729|!Base2,X               ;$029F2F    || Erase the sprite if vertically offscreen.
    SBC $1D                            ;$029F32    ||
    BNE Erase                          ;$029F34    |/
    LDA.w $1765|!Base2,X               ;$029F39    |\
    AND.b #$0C                         ;$029F3C    ||
    LSR                                ;$029F3E    ||
    LSR                                ;$029F3F    || Get X offset for the horizontal "waving" motion.
    TAY                                ;$029F40    ||
    LDA.w x_offsets,Y                  ;$029F41    ||
    STA $04                            ;$029F44    |/
    %ExtendedGetDrawInfo()
    LDA $01
    CLC                                ;$029F4C    || Offset X position in OAM.
    ADC $04                            ;$029F4D    ||
    STA.w $0200|!Base2,Y               ;$029F4F    |/
    LDA $02
    CLC                                ;$029F55    || Offset Y position in OAM.
    ADC.b #$05                         ;$029F56    ||
    STA.w $0201|!Base2,Y               ;$029F58    |/
    LDA.b #!TileNum                    ;$029F5B    |\\ Tile to use for the water bubble.
    STA.w $0202|!Base2,Y               ;$029F5D    |/
    LDA.b #!TileProps
    ORA $64                            ;$02A1F4    ||
    STA.w $0203|!Base2,Y               ;$02A1F6    ||

    TYA                                ;$02A204    |
    LSR                                ;$02A205    |
    LSR                                ;$02A206    |
    TAY                                ;$02A207    |
    LDA.b #$00                         ;$02A208    |\ Set tile size (8x8).
    STA.w $0420|!Base2,Y               ;$02A20A    |/
    ; LDX.w $15E9                      ;$02A20D    |

    RTL

x_offsets:
    db $00,$01,$00,$FF
