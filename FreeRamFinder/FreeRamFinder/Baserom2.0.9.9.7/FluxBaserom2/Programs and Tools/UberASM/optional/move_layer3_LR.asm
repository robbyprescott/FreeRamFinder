; Speed in 256th of pixels per frame
; (for example, $0100 = 1 pixel per frame, $0080 = 1 pixel every 2 frames)
!Speed = $0100

; Max Y position for scrolling ($DB is the last value before it overlaps with status bar)
!MaxYPosition = $00DB

; Min Y position for scrolling
!MinYPosition = $0030

; 1 byte of freeram
!freeram = $0E53|!addr

init:
    stz !freeram
    rtl

main:
    stz $1401|!addr
    lda $9D
    ora $13D4|!addr
    bne return
    lda $17
    bit #$30
    beq return
    lda !freeram
    clc
    adc.b #!Speed
    sta !freeram
; LDA and BIT don't change the carry, so no need to PHP here
    lda $17
    bit #$20 ; change to switch L and R
    bne up
    bit #$10 ; change to switch L and R
    bne down
    rtl
down:
    rep #$20
    lda #$0000
    rol
    sta $00
    lda $24
    sec
    sbc $00
    sbc.w #!Speed>>8
    sta $24
    bmi ++
    cmp.w #!MinYPosition
    bcs +
++  lda.w #!MinYPosition
    sta $24
+   sep #$20
    rtl
up:
    rep #$20
    lda $24
    adc.w #!Speed>>8
    sta $24
    cmp.w #!MaxYPosition
    bcc +
    lda.w #!MaxYPosition-1
    sta $24
+   sep #$20
return:
    rtl
