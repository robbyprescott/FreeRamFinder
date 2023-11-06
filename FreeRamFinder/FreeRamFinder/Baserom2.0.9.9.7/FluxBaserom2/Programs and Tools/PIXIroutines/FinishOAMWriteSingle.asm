;===================================================
; Routine that handles the 2 bits in $0460,y for a single tile (adapted from $01B7B3).
; Can be used as an alternative to FinishOAMWrite when the sprite is taller/wider than $7F pixels.
;
; Inputs:
; - Y: OAM index of the current tile
; - A: tile size ($00 = 8x8, $02 = 16x16).
;
; Clobbers:
; - X and Y are preserved.
; - A, $0A-$0F are clobbered.
;===================================================
    xba
    phx
    ldx $15E9|!Base2
    lda !E4,x
    sta $0A
    sec
    sbc $1A
    sta $0E
    lda !14E0,x
    sta $0B
    stz $0F
    lda $0300|!Base2,y
    sec
    sbc $0E
    bpl ?+
    dec $0F
?+  clc
    adc $0A
    sta $0C
    lda $0F
    adc $0B
    sta $0D
    tyx
    tya
    lsr #2
    tay
    xba
    sta $0460|!Base2,y
    rep #$20
    lda $0C
    sec
    sbc $1A
    cmp #$0100
    sep #$20
    bcc ?+
    lda $0460|!Base2,y
    ora #$01
    sta $0460|!Base2,y
?+  txy
    plx
    rtl
