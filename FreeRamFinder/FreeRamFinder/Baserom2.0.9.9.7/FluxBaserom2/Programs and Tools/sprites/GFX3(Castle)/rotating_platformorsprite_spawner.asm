;===========================================================
; Multiple Rotating Ball 'n' Chains/Platforms Spawner
; by KevinM
;
; This sprite works similarly to vanilla sprite E0 but with much more
; flexibility on what sprites to spawn and how many.
;
; The rotation direction depends on the X position, like in vanilla, unless
; you're using my "Sprite Properties on Extra Bit" patch, in which case it will
; depend on the extra bit (clear = clockwise, set = counter-clockwise)
;
; Extra byte 1: amount of sprites (1-8)
;
; Extra byte 2: bitwise setting for spawning BnC/platforms
;  Each bit can be 0 (spawn BnC) or 1 (spawn platform)
;  So you can control each of the sprites you spawn
;  For example: 90 (10010000 in binary) will make sprites 1 and 4
;  be platforms, and sprites 2 and 3 BnCs (also 5-8 if used).
;  Tip: use 00 if you want all BnCs, FF if you want all platforms
;
; Extra byte 3: bitwise setting for skipping spawning any of the sprites
;  Each bit here controls if the corresponding sprite should not spawn
;  (starting from the left bit, like for extra byte 2).
;  This can be used to leave "holes" in the circle. Leave 00 to not use this.
;  For example, if you choose to spawn 4 sprites without skips (00), they will
;  spawn 90 degrees from each other. If you choose to spawn 5 and skip the
;  last one (00001000 -> 08), the other 4 will be closer together (72 degrees)
;===========================================================

sprites_num:
    db $9E,$A3

starting_angles:
    dw $0000
    dw $0000,$0100
    dw $0000,$00AA,$0155
    dw $0000,$0080,$0100,$0180
    dw $0000,$0066,$00CD,$0132,$0197
    dw $0000,$0055,$00AA,$0100,$0155,$01AA
    dw $0000,$0049,$0092,$00DB,$0125,$016E,$01B7
    dw $0000,$0040,$0080,$00C0,$0100,$0140,$0180,$01C0

angles_table_offsets:
    db $00,$02,$06,$0C,$14,$1E,$2A,$38

print "MAIN ",pc
    phb : phk : plb
    
    stz $0A
    lda !extra_bits,x : and #$04 : sta $0B
    lda !extra_byte_1,x : sta $0C
    tay
    lda angles_table_offsets-1,y : sta $0D
    lda !extra_byte_2,x : sta $0E
    lda !extra_byte_3,x : sta $0F

spawn_loop:
    lda #$00 : asl $0F : rol : bne .next
    asl $0E : rol : tay
    lda.w sprites_num,y
    ldy $0A : bne .spawn_new
.change_this:
    inc $0A
    sta !9E,x
    jsl $07F7D2|!bank
    txy
    bra .set_stuff
.spawn_new:
    rep #$20
    stz $00
    stz $02
    sep #$20
    clc
    %SpawnSprite()
    bcs .next
.set_stuff:
    phx
    tyx
    lda #$01 : sta !14C8,x
    lda !extra_bits,x : ora $0B : sta !extra_bits,x
    lda $0C : asl : clc : adc $0D : tay
    lda.w starting_angles-1,y : sta !151C,x
    lda.w starting_angles-2,y : sta !1602,x
    plx
.next:
    dec $0C : bne spawn_loop
.end:
    plb
print "INIT ",pc
    rtl
