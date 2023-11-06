;;;
;
; Gate controlled by ropes.
;
; Extra Bit: if set, the gate moves twice as fast than the rope.
;
; Extra Byte 1: height - 1 ($00-$FD).
;
; Extra Byte 2: number of tiles to hide when at rest ($80 = don't hide tiles).
;
; Extra Byte 3: rope/gate ID ($00-$FF).
;
;;;

; GFX tile to use
!Tile = $2E

; Sprite number in PIXI's list
!RopeSpriteNum = $BC

; Map16 values.
; !SolidTile should be an invisible block that acts as 130.
!AirTile   = $0025
!SolidTile = $06B5

!ID          = !C2
!Length      = !1504
!YLoBackup   = !1510
!DirFlag     = !151C
!IsMoving    = !1570
!DoubleSpeed = !157C
!CoverTiles  = !1588

print "INIT",pc
    lda !extra_byte_1,x
    sta !Length,x
    lda !extra_byte_2,x
    sta !CoverTiles,x
    lda !extra_byte_3,x
    sta !ID,x
    lda !sprite_y_low,x
    sta !YLoBackup,x
    lda !extra_bits,x
    lsr #2
    and #$01
    sta !DoubleSpeed,x
    rtl

print "MAIN",pc
    lda !14C8,x
    cmp #$08
    bne +
    phb
    phk
    plb
    jsr Graphics
    jsr Main
    plb
+   rtl

Main:
    lda $9D
    bne +
    lda #$07
    %SubOffScreen()
    jsr SetYSpeed
    jsl $01801A|!bank
    jsr ChangeBlock
+   rts

SetYSpeed:
    lda !ID,x
    sta $00
    ldx.b #!SprSize-1
.loop
    lda !14C8,x
    cmp #$08
    bne .next
    lda !extra_bits,x
    and #!CustomBit
    beq .next
    lda !new_sprite_num,x
    cmp.b #!RopeSpriteNum
    bne .next
    lda !ID,x
    cmp $00
    bne .next
    txy
    ldx $15E9|!addr
    lda !DirFlag,x
    lsr
    lda !sprite_speed_y,y
    beq .check_stop
    bcs +
    eor #$FF
    inc
+   xba
    lda !DoubleSpeed,x
    lsr
    xba
    bcc +
    asl
+   sta !sprite_speed_y,x
    rts
.check_stop
    lda !IsMoving,y
    bne +
    ;lda !sprite_y_low,x
    ;cmp !YLoBackup,x
    ;bne ++
+   stz !sprite_speed_y,x
++  rts
.next
    dex
    bpl .loop
    ldx $15E9|!addr
    lda !sprite_y_low,x
    cmp !YLoBackup,x
    bne +
    stz !sprite_speed_y,x
+   rts

ChangeBlock:
    lda !sprite_speed_y,x
    beq .return
    bmi .up
.down
    lda !sprite_y_low,x
    and #$0F
    cmp #$08
    bcc .return
    rep #$20
    lda.w #!SolidTile
    bra .change
.up
    lda !sprite_y_low,x
    and #$0F
    cmp #$08
    bcs .return
    rep #$20
    lda.w #!AirTile
.change
    sta $00
    sep #$20
    lda !Length,x
    inc
    asl #4
    clc
    adc !sprite_y_low,x
    sta $98
    lda !sprite_y_high,x
    adc #$00
    sta $99
    lda !sprite_x_low,x
    sta $9A
    lda !sprite_x_high,x
    sta $9B
    stz $1933|!addr
    rep #$20
    lda $00
    %ChangeMap16NoVRAM()
    sep #$20
.return
    rts

Graphics:
    %GetDrawInfo()
    sbc #$00
    xba
    lda $01
    rep #$20
    sec
    sbc #$0001
    sta $05
    sep #$20
    lda !15A0,x
    beq +
    lda !14E0,x
    xba
    lda !E4,x
    rep #$20
    sec
    sbc $1A
    cmp #$FFF0
    sep #$20
    bcc .return
+   lda !15F6,x
    sta $02
    lda !Length,x
    inc
    sta $03

    lda !YLoBackup,x
    sec
    sbc !sprite_y_low,x
    bpl +
    eor #$FF
    inc
+   lsr #4
    clc
    adc !CoverTiles,x
    bpl +
    lda #$00
+   sta $59

    ldy !15EA,x
    ldx #$00
.loop
    lda $00
    sta $0300|!addr,y
    rep #$20
    lda $05
    cmp #$00F0
    bcc +
    cmp #$FFF0
    bcs +
    sep #$20
    bra ++
+   sep #$20
    cpx $59
    bcc ++
    sta $0301|!addr,y
    lda #!Tile
    sta $0302|!addr,y
    lda $02
    sta $0303|!addr,y
    lda #$02
    %FinishOAMWriteSingle()
    iny #4
++  lda $05
    clc
    adc #$10
    sta $05
    lda $06
    adc #$00
    sta $06
    inx
    cpx $03
    bcc .loop
    ldx $15E9|!addr
.return
    rts
