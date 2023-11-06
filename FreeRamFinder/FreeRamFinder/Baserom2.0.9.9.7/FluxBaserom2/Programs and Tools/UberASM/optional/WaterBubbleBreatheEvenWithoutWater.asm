; by spoons

; Spawn a custom water bubble when out of water
; basically copy-pasted from Thomas' all.log

!ExtendedOffset = $13 ; do not change this

!ExtendedSpriteNumber = $09+!ExtendedOffset ; from pixi list

!Base2 = !addr

main:

    LDA $75 ; if Mario is in water, don't spawn anything since base game will
    BNE Return00FD23
CODE_00FD08:                  ;-----------| Subroutine to handle Mario's water bubbles.
    LDY.b #$3F                ;$00FD08    |\ 
    LDA $15                   ;$00FD0A    ||
    AND.b #$83                ;$00FD0C    || Return if sprites frozen, or not a frame to spawn.
    BNE CODE_00FD12           ;$00FD0E    ||
    LDY.b #$7F                ;$00FD10    || Bubbles spawn every 0x80 frames normally,
CODE_00FD12:                  ;           ||  or every 0x40 frames with A/B/left/right held.
    TYA                       ;$00FD12    ||
    AND $14                   ;$00FD13    ||
    ORA $9D                   ;$00FD15    ||
    BNE Return00FD23          ;$00FD17    |/
    LDX.b #$07                ;$00FD19    |\ 
CODE_00FD1B:                  ;           ||
    LDA.w $170B|!Base2,X      ;$00FD1B    ||
    BEQ CODE_00FD26           ;$00FD1E    || Find an empty extended sprite slot, and return if none found.
    DEX                       ;$00FD20    ||
    BPL CODE_00FD1B           ;$00FD21    ||
Return00FD23:                 ;           ||
    RTL
    
DATA_00FD24:                    ;$00FD24    | X offsets for Mario's water bubble based on the direction he's facing.
    db $02,$0A

CODE_00FD26:                       ;```````````| Extended sprite slot found.
    LDA.b #!ExtendedSpriteNumber   ;$00FD26    |\\ Extended sprite that Mario "breathes" in water (bubble).
    STA.w $170B|!Base2,X           ;$00FD28    |/
    LDY $76                        ;$00FD2B    |\ 
    LDA $94                        ;$00FD2D    ||
    CLC                            ;$00FD2F    ||
    ADC.w DATA_00FD24,Y            ;$00FD30    || Set spawn X position based on the direction Mario is fasing.
    STA.w $171F|!Base2,X           ;$00FD33    ||
    LDA $95                        ;$00FD36    ||
    ADC.b #$00                     ;$00FD38    ||
    STA.w $1733|!Base2,X           ;$00FD3A    |/
    LDA $19                        ;$00FD3D    |\ 
    BEQ CODE_00FD47                ;$00FD3F    ||
    LDA.b #$04                     ;$00FD41    ||| Y offset for the bubble when big.
    LDY $73                        ;$00FD43    ||
    BEQ CODE_00FD49                ;$00FD45    ||
CODE_00FD47:                       ;           ||
    LDA.b #$0C                     ;$00FD47    ||| Y offset for the bubble when small or ducking.
CODE_00FD49:                       ;           ||
    CLC                            ;$00FD49    ||
    ADC $96                        ;$00FD4A    ||
    STA.w $1715|!Base2,X           ;$00FD4C    ||
    LDA $97                        ;$00FD4F    ||
    ADC.b #$00                     ;$00FD51    ||
    STA.w $1729|!Base2,X           ;$00FD53    |/
    STZ.w $1765|!Base2,X           ;$00FD56    |] use $1765 instead.
    RTL