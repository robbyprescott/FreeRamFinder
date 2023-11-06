main:
    lda $9D
    ora $13D4|!addr
    bne .return

    ldx #!sprite_slots-1
.loop
    lda !9E,x
    cmp #$2D
    bne .continue
    lda !14C8,x
    cmp #$08
    bcc .continue
    lda !1504,x
    bne .continue
.found
    tya
    sta !1570,x
    inc !1504,x     ; Use unused sprite table as a "run once" flag
.continue
    dex
    bpl .loop
.return
    rtl
