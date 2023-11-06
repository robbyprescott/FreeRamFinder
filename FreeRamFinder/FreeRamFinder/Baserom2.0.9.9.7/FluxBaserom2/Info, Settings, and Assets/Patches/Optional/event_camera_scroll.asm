; Due to how the code works, using values different than $40
; will cause the camera to not move in a straight line.
; (it still works properly though)
!scroll_speed = $40

if read1($00FFD5) == $23
    sa1rom
    !sa1  = 1
    !dp   = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1  = 0
    !dp   = $0000
    !addr = $0000
    !bank = $800000
endif

; OW addresses that are not used during events.
!x_backup = $1DF0|!addr
!y_backup = $1DF2|!addr

org $04E640
    autoclean jml init

org $04E6D3
    autoclean jml before_event

org $04EA01
    autoclean jml after_event

freecode

init:
    rep #$20
    lda $1A : sta !x_backup
    lda $1C : sta !y_backup
    sep #$20
    inc $1B86|!addr
    lda $1DEA|!addr
    jml $04E646|!bank

before_event:
    jsr check_continue
    bcs .continue
    jsr scroll
    bcs .continue
.return:
    jml $04E6F8|!bank
.continue:
    inc $1B86|!addr
    lda $1DEA|!addr
    jml $04E6D9|!bank

after_event:
    jsr check_continue
    bcs .continue
    rep #$20
    lda !x_backup : sta $0C
    lda !y_backup : sta $0E
    jsr scroll
    bcs .continue
.return:
    jml $04EA24|!bank
.continue:
    stz $1B86|!addr
    inc $13D9|!addr
    jml $04EA07|!bank

check_continue:
    ; Skip if the submap is not the main ow.
    ldx $0DB3|!addr
    lda $1F11|!addr,x : bne .continue

    ; Skip if either table contains $FFFF.
    lda $1DEA|!addr : asl : tax
    rep #$20
    lda.l x_pos,x : sta $0C : bmi .continue
    lda.l y_pos,x : sta $0E : bmi .continue
.return:
    sep #$20
    clc
    rts
.continue:
    sep #$20
    sec
    rts

;=======================================================
; Routine to scroll the screen to a specified position.
; Adapted from $04829E
;
; Inputs:
;  $0C = destination X position
;  $0E = destination Y position
;
; Output:
;  Carry = set if finished scrolling
;=======================================================
scroll:
    rep #$20
    lda $0E : sec : sbc $1C : sta $01
    bpl +
    eor #$FFFF : inc
+   lsr
    sep #$20
    sta $05
    rep #$20
    lda $0C : sec : sbc $1A : sta $00
    bpl +
    eor #$FFFF : inc
+   lsr
    sep #$20
    sta $04
    sep #$20
    ldx #$01
    cmp $05 : bcs +
    dex
    lda $05   
+   cmp #$02 : bcs +
    rep #$20
    lda $0C : sta $1A : sta $1E
    lda $0E : sta $1C : sta $20
    sep #$20
    sec
    rts
+   stz $4204
    ldy $04,x : sty $4205
    sta $4206
    nop #6
    rep #$20
    lda $4214 : lsr #2
    sep #$20
    ldy $01,x : bpl +
    eor #$FF : inc
+   sta $01,x
    txa : eor #$01 : tax
    lda.b #!scroll_speed
    ldy $01,x : bpl +
    lda.b #-!scroll_speed
+   sta $01,x
    ldy #$01
-   tya : asl : tax
    lda $01|!dp,y : asl #4
    clc : adc $1B7C|!addr,y : sta $1B7C|!addr,y
    lda $01|!dp,y
    phy : php
    lsr #4
    ldy #$00
    plp
    bpl +
    ora #$F0
    dey
+   adc $1A,x : sta $1A,x : sta $1E,x
    tya
    adc $1B,x : sta $1B,x : sta $1F,x
    ply
    dey
    bpl -
    clc
    rts

incsrc event_camera_scroll_tables.asm
