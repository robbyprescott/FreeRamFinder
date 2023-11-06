; RAM conditional trigger added by SJC

;===============================================================================
; Sprites Offscreen Indicator
; by Kevin
;
; This uberasm will draw an indicator on the screen for any sprite that is vertically offscreen.
; You can choose if to ignore some sprites (not show the indicator for them) in the tables below.
; Additionally you can choose if to only draw when above or below the screen (both by default)
; and have a different indicator for the two cases.
; Note that the indicator might not always be perfect depending on the sprite, but it seems to
; work fine for most of the vanilla sprite sizes.
; This will be more apparent for sprites whose hitbox doesn't match the graphics well.
;===============================================================================

; Change to 0 if you don't want the indicator when the sprite is above or below the screen
!draw_above = 1
!draw_below = 0

; Indicator's tile number and YXPPCCCT properties, for sprites above the screen
!tile_above  = $1D
!props_above = $38

; Indicator's tile number and YXPPCCCT properties, for sprites below the screen
!tile_below  = $1D
!props_below = $38

; Tile size ($00 = 8x8, $02 = 16x16)
!tile_size   = $00

; Y offset from the border of the screen to draw the tile at
!yoff_above  = $02
!yoff_below  = $02

; OAM index and table to use
; Default should be fine if you don't have a lot of sprites offscreen at any given moment
; Otherwise, if you're not using cluster sprites !oam_index = $B0 should be a safe choice
; Otherwise !oam_table = $0300 and !oam_index = $38 should work (requires NMSTL or SA-1)
!oam_index = $00
!oam_table = $0200

; Flags to draw the indicator for each normal sprite
; Each bit corresponds to a sprite: 1 = draw, 0 = don't draw
draw_normal:
    db %11111111,%11111111 ; 00-0F
    db %11111111,%11111111 ; 10-1F
    db %11111111,%11111111 ; 20-2F
    db %11111111,%11111111 ; 30-3F
    db %11111111,%11111111 ; 40-4F
    db %11111111,%11111111 ; 50-5F
    db %11111111,%11111111 ; 60-6F
    db %11111111,%11111111 ; 70-7F
    db %11111111,%11111111 ; 80-8F
    db %11111111,%11111111 ; 90-9F
    db %11111111,%11111111 ; A0-AF
    db %11111111,%11111111 ; B0-BF
    db %11111111,%10000000 ; C0-CF

; Flags to draw the indicator for each custom sprite
; Each bit corresponds to a sprite: 1 = draw, 0 = don't draw
draw_custom:
    db %11111111,%11111111 ; 00-0F
    db %11111111,%11111111 ; 10-1F
    db %11111111,%11111111 ; 20-2F
    db %11111111,%11111111 ; 30-3F
    db %11111111,%11111111 ; 40-4F
    db %11111111,%11111111 ; 50-5F
    db %11111111,%11111111 ; 60-6F
    db %11111111,%11111111 ; 70-7F
    db %11111111,%11111111 ; 80-8F
    db %11111111,%11111111 ; 90-9F
    db %11111111,%11111111 ; A0-AF
    db %11111111,%11111111 ; B0-BF

main:
    ; Skip if paused
    lda $13D4
    ora $0EE7 ; Turn off if you trigger $0EE7, added by SJC	
	bne .return

    ; Initialize the current OAM index and OAM index / 4
    lda.b #!oam_index : sta $0F
    lda.b #!oam_index/4 : sta $0E

    ldx.b #!sprite_slots-1
.sprite_loop:
    ; If dead, skip
    lda !14C8,x : cmp #$08 : bcc ..next

    ; Skip if draw flag is unset
    jsr check_draw_flag : beq ..next

    ; Draw the indicator
    jsr draw

..next:
    dex : bpl .sprite_loop

.return:
    rtl

; Returns Z = 0 if sprite needs to be drawn
check_draw_flag:
    ; If PIXI wasn't used, only check for normal sprites
if read3($02FFEE) != $FFFFFF
    lda !7FAB10,x : and #$08 : bne .custom
endif
.normal:
    lda !9E,x : and #$07 : tay
    lda.w .mask,y : xba
    lda !9E,x : lsr #3 : tay
    xba : and.w draw_normal,y
    rts
.custom:
    lda !7FAB9E,x : and #$07 : tay
    lda.w .mask,y : xba
    lda !7FAB9E,x : lsr #3 : tay
    xba : and.w draw_custom,y
    rts

.mask:
    db $80,$40,$20,$10,$08,$04,$02,$01

!oam_size  #= ($0420|!addr)+((!oam_table-$0200)/4)
!oam_table #= !oam_table|!addr

draw:
    phx
    txy
    lda !1662,x : and #$3F : tax

    ; Get the Y clipping values
    stz $0D
    lda.l $03B5E4|!bank,x : bpl +
    dec $0D
+   clc : adc.w !D8,y : sta $00
    lda !14D4,y : adc $0D : sta $01
    lda.l $03B620|!bank,x : sta $02
    stz $03

    ; Get the X clipping values
    stz $0D
    lda.l $03B56C|!bank,x : bpl +
    dec $0D
+   clc : adc.w !E4,y : sta $04
    lda !14E0,y : adc $0D : sta $05
    lda.l $03B5A8|!bank,x

    ; Find the indicator's X position (centered on the sprite's hitbox)
    rep #$20
    and #$00FF : lsr
    clc : adc $04
    sec : sbc $1A
if !tile_size == $00
    sec : sbc #$0004
else
    sec : sbc #$0008
endif
    sta $04

    ; If the sprite is too much horizontally offscreen, return
    bpl +
if !tile_size == $00
    cmp #$FFF9
else
    cmp #$FFF1
endif
    bcc .return
    bra ++
+   cmp #$0100 : bcs .return
++  
    ; Check if the sprite is vertically offscreen
    ; and find if it's above or below it (X=0 or X=1)
    ldx #$01
    lda $00 : sec : sbc $1C
    bmi +
    cmp #$00E6
if !draw_below
    bcs .offscreen
else
    bcs .return
endif
+
if !draw_above
    dex
    clc : adc $02
    bpl .return
else
    bra .return
endif

    ; Draw the sprite
.offscreen:
    sep #$20

    ; Get current OAM index and update it
    ldy $0F

    ; Write OAM X position (B = offscreen flag for later)
    lda $04 : sta.w !oam_table+0,y

    ; Write OAM Y position, tile number and properties
    lda.w .y_offs,x : sta.w !oam_table+1,y
    lda.w .tiles,x : sta.w !oam_table+2,y
    lda.w .props,x : sta.w !oam_table+3,y

    ; Update current OAM index
    iny #4 : sty $0F

    ; Get current OAM index / 4
    ldy $0E

    ; Write the tile size and X high bit
    lda $05 : beq +
    lda #$01
+
if !tile_size != $00
    ora.b #!tile_size
endif
    sta.w !oam_size,y

    ; Update current OAM index / 4
    iny : sty $0E

.return:
    sep #$20
    plx
    rts

.tiles:
    db !tile_above,!tile_below
.props:
    db !props_above,!props_below
.y_offs:
    db !yoff_above,$D7-!yoff_below
