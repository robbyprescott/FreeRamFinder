if read1($00FFD5) == $23
    sa1rom
    !sa1  = 1
    !addr = $6000
    !E4   = $322C
    !14E0 = $326E
else
    lorom
    !sa1  = 0
    !addr = $0000
    !E4   = $E4
    !14E0 = $14E0
endif

org $01989D
    autoclean jsl koopa_eyes_check_offscreen
    rts

freedata

macro check_tile(offset)
    lda.w ($0300+(<offset>*4))|!addr,y
    sbc $02
    rep #$21
    bpl +
    ora #$FF00
+   adc $02
    cmp #$0100
    sep #$20
    lda #$00
    adc #$00
    sta.w ($0460+(<offset>))|!addr,x
endmacro

; Adapted from Akaginite's FinishOAMWrite routine
koopa_eyes_check_offscreen:
    pha
    lda !14E0,x : xba
    lda !E4,x
    rep #$20
    sec : sbc $1A : sta $02
    sep #$21
    plx
    %check_tile(0)
    sec
    %check_tile(1)
    ldx $15E9|!addr
    rtl
