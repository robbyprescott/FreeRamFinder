if read1($00FFD5) == $23
    sa1rom
    !addr   = $6000
    !bank   = $000000
    !7ED000 = $40D000
else
    lorom
    !addr   = $0000
    !bank   = $800000
    !7ED000 = $7ED000
endif

org $0096A1
    autoclean jml check_level

freecode

; This table determines which levels will show the "Mario Start!" message.
; Each bit corresponds to one level (1 = enabled, 0 = disabled).
; By default 104 (Yoshi's House) has it disabled like in vanilla SMW.
mario_start_enabled:
    db %00000000 ; 000-007
    db %00000000 ; 008-00F
    db %00000000 ; 010-017
    db %00000000 ; 018-01F
    db %00000000 ; 020,021,022,023,024 + 101,102,103
    db %00000000 ; 104-10B
    db %00000000 ; 10C-113
    db %00000000 ; 114-11B
    db %00000000 ; 11C-123
    db %00000000 ; 124-12B
    db %00000000 ; 12C-133
    db %00000000 ; 134-13B

check_level:
    jsr get_translevel
    sta $00
    and #$07 : tax
    lda.l $018000|!bank,x
    pha
    lda $00 : lsr #3 : tax
    pla
    and.l mario_start_enabled,x
    bne .enable
.disable:
    jml $0096AB|!bank
.enable:
    jml $0096A8|!bank

get_translevel:
    ldy $0DD6|!addr
    lda $1F17|!addr,y : lsr #4 : sta $00
    lda $1F19|!addr,y : and #$F0 : ora $00 : sta $00
    lda $1F1A|!addr,y : asl : ora $1F18|!addr,y
    ldy $0DB3|!addr
    ldx $1F11|!addr,y : beq +
    clc : adc #$04
+   sta $01
    rep #$10
    ldx $00
    lda !7ED000,x
    sep #$10
    rts
