; This uberasm allows items in Yoshi's mouth to persist through door/pipe transitions (if you don't want to use the "Carry Sprites Through Doors and Pipes" patch

; 1 byte of empty ram. Should be cleared on reset and ow load but not on level load.
!freeram1 = $14C1|!addr

; 8 bytes of empty ram. Should not be cleared on level load.
!freeram2 = $7FB310

;
!YoshiHasSprite   = !freeram1
!SpriteNumber     = !freeram2+0
!SpriteExtraBits  = !freeram2+1
!SpriteExtraProp1 = !freeram2+2
!SpriteExtraProp2 = !freeram2+3
!SpriteExtraByte1 = !freeram2+4
!SpriteExtraByte2 = !freeram2+5
!SpriteExtraByte3 = !freeram2+6
!SpriteExtraByte4 = !freeram2+7

init:
    lda !YoshiHasSprite
    beq .return
    ldy $18E2|!addr
    beq .return
    ldx #!sprite_slots-1
.loop
    lda !14C8,x
    beq .found
.next
    dex
    bpl .loop
    rtl
.found
    lda !SpriteNumber
    sta !9E,x
    jsl $07F7D2|!bank
    lda !SpriteExtraBits
    and #$08
    beq .normal
.custom
    lda !9E,x
    sta !new_sprite_num,x
    jsl $0187A7|!bank
    lda !SpriteExtraBits
    sta !extra_bits,x
    lda !SpriteExtraProp1
    sta !extra_prop_1,x
    lda !SpriteExtraProp2
    sta !extra_prop_2,x
    lda !SpriteExtraByte1
    sta !extra_byte_1,x
    lda !SpriteExtraByte2
    sta !extra_byte_2,x
    lda !SpriteExtraByte3
    sta !extra_byte_3,x
    lda !SpriteExtraByte4
    sta !extra_byte_4,x
.normal
    lda #$07
    sta !14C8,x
    txa
    sta !160E-1,y
    lda #$FF
    sta $18AC|!addr
.return
    rtl

main:
    lda $71
    cmp #$09
    beq .return
    ldy $18E2|!addr
    beq .return
    ldx !160E-1,y
    bmi .return
    lda !9E,x
    sta !SpriteNumber
    lda !extra_bits,x
    sta !SpriteExtraBits
    and #$08
    beq .normal
.custom
    lda !new_sprite_num,x
    sta !SpriteNumber
    lda !extra_prop_1,x
    sta !SpriteExtraProp1
    lda !extra_prop_2,x
    sta !SpriteExtraProp2
    lda !extra_byte_1,x
    sta !SpriteExtraByte1
    lda !extra_byte_2,x
    sta !SpriteExtraByte2
    lda !extra_byte_3,x
    sta !SpriteExtraByte3
    lda !extra_byte_4,x
    sta !SpriteExtraByte4
.normal
    lda #$01
    sta !YoshiHasSprite
    rtl
.return
    stz !YoshiHasSprite
    rtl
