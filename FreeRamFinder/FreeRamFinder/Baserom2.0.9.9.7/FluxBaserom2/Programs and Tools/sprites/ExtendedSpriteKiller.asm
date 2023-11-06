; Kills extended sprites that come in contact.
; Note: the hitbox is 16x16 (ish), you can change it under "sprite clipping" in the CFG editor

; Extra bit: if clear, the ext. sprite will vanish
;            if set, the ext. sprite will turn into a puff of smoke
;
; Extra Byte 1: extended sprite number to kill. (see $7E170B)
;  If 00, it will kill any ext. sprite it touches.
;  Note: it won't work for ext. sprites 01, 0E, 0F, 10, 12

; If you have more ext. sprite slots than vanilla, change this
!ext_sprite_slots = 10

print "MAIN ",pc
main:
    lda !14C8,x : eor #$08 : ora $9D : bne return
    %SubOffScreen()
    lda !14C8,x : beq return
    jsl $03B6E5|!bank
    lda !extra_byte_1,x : sta $69
    lda !extra_bits,x : and #$04 : lsr #2 : sta $6A
    phb
    lda.b #$02|!bank8 : pha : plb
    ldx.b #!ext_sprite_slots-1
.loop:
    lda $69 : bne ..spec
..any:
    lda !extended_num,x
    bra +
..spec:
    cmp !extended_num,x : bne ..next
    ; 00, 01, 0E, 0F, 10, 12: skip
    ; 11, 13+: interact, force enemy fireball hitbox
    ; 02-0D: interact normally
+   cmp #$02 : bcc ..next
    cmp #$0E : bcc +
    cmp #$11 : beq ++
    cmp #$13 : bcc ..next
++  lda #$02
+   tay
    phk : pea.w (+)-1
    pea.w $02B889-1
    jml $02A51C|!bank
+   jsl $03B72B|!bank : bcc ..next
    lda $6A : sta !extended_num,x
    lda #$0F : sta !extended_timer,x
..next:
    dex : bpl .loop
    ldx $15E9|!addr
    plb
print "INIT ", pc
return:
    rtl
