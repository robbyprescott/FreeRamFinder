; Which sprite to turn into which other sprite, on state and off state

!SpriteOff  = $6A ; sprite number
!SpriteOn   = $0F ; sprite number

; See $7E14C8. Usually you want $01, but in some cases $08/$09 might be better
!StateOff   = $01
!StateOn    = $01

; 1 byte of freeram
!freeram    = $0EF2|!addr

init:
    lda $14AF|!addr
    sta !freeram
    rtl

main:
    lda $9D
    bne .return
    lda $14AF|!addr
    cmp !freeram
    sta !freeram
    beq .return
    ldy #!sprite_slots-1
-   lda !14C8,y
    cmp #$08
    bcc +
    ldx $14AF|!addr
    lda.w !9E,y
    cmp .sprites,x
    bne +
    txa
    eor #$01
    tax
    lda .sprites,x
    sta.w !9E,y
    lda .states,x
    pha
    lda !157C,y
    pha
    phy
    tyx
    jsl $07F7D2|!bank
    ply
    pla
    sta !157C,y
    pla
    sta !14C8,y
+   dey
    bpl -
.return
    rtl

.sprites
    db !SpriteOff,!SpriteOn

.states
    db !StateOff,!StateOn
