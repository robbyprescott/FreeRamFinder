;========================================================================================
; Yoshi's Tongue Block Interaction by Kevin
;
; This UberASM code will make Yoshi's tongue have a block interaction, meaning that
; it will stop extending when touching solid blocks, and it will also be able to
; activate blocks such as ON/OFF, turnblocks, etc.
;
; The solid interaction is based on the act as of the blocks: only blocks that have an
; act as between 0x100 and 0x1FF can be solid, and not all of them will (you can see
; which in the "solid_act_as" table below).
; If you just want the "activate blocks" ability without the solid blocks interaction,
; just change all values under "solid_act_as" to 0, except for those blocks that will be
; triggered (111 to 12D and 16A to 16D).
;
; Since the code only checks for the act as set in the map16 editor, it's not immediately
; possible to handle blocks that change act as dynamically: for B/S P-Switch and ON/OFF
; changing blocks (the more common ones), use the table below to set special blocks that
; act as solid or non-solid when those switches are active.
; Note 1: you use the map16 number there, not the act as! Also keep the ".end" after each table.
; Note 2: when the switches are not active, the interaction will use the act as set in the
; map16 editor. This means, for example, that an ON/OFF state block that's solid when the
; switch is ON, should have its map16 number under onoff_solid, and have act as in LM set to 25.
; Note 3: each table can have a max of 127 entries.
;========================================================================================

; If 1, Yoshi's tongue will be able to trigger blocks such as ON/OFF, bounce blocks, etc.
!trigger_blocks = 1

; If 1, Yoshi's tongue will instantly retract a bit after hitting a block,
; to avoid a bug where triggering a block with an item inside would cause him
; to eat it immediately (if the item is a powerup, the powerup won't even work).
; If !trigger_blocks = 0 then this is useless (keep it at 0 too).
!items_from_blocks_fix = 0

; SFX when the tongue hits a solid block
; $00 = no SFX
!solid_sfx      = $01
!solid_sfx_addr = $1DF9|!addr

; These map16 blocks will act as solid for the tongue
; when the Blue P-Switch is ON
blue_pswitch_solid:
    ; Add entries here like dw $XXXX,$YYYY,...
    dw $0029,$002B
.end:

; These map16 blocks will act as air for the tongue
; when the Blue P-Switch is ON
blue_pswitch_air:
    ; Add entries here like dw $XXXX,$YYYY,...
    dw $0132
.end:

; These map16 blocks will act as solid for the tongue
; when the Silver P-Switch is ON
silver_pswitch_solid:
    ; Add entries here like dw $XXXX,$YYYY,...
    
.end:

; These map16 blocks will act as air for the tongue
; when the Silver P-Switch is ON
silver_pswitch_air:
    ; Add entries here like dw $XXXX,$YYYY,...
    dw $012F
.end:

; These map16 blocks will act as solid for the tongue
; when the ON/OFF switch is ON
onoff_switch_solid:
    ; Add entries here like dw $XXXX,$YYYY,...

.end:

; These map16 blocks will act as air for the tongue
; when the ON/OFF switch is ON
onoff_switch_air:
    ; Add entries here like dw $XXXX,$YYYY,...

.end:

;========================================================================================
; Code starts here. Don't edit unless you know what you're doing!
;========================================================================================
main:
    ; Return if the game is locked
    lda $9D : ora $13D4|!addr : bne .return
    
    ; Return if there's no Yoshi
    ldx $18E2|!addr : beq .return

    ; Get Yoshi's sprite slot
    dex

    ; Return if Yoshi isn't sticking out his tongue
    lda !1594,x : cmp #$01 : bne .return

    ; Put tongue's position in $98-$9A
    jsr set_tongue_position

    ; Interact with blocks
    jsr block_interact
.return:
    rtl

set_tongue_position:
    ; Set DB = $01 for the tables below
    phb
    lda.b #$01|!bank8 : pha : plb

    ; Set the tongue Y position
    ldy !1602,x
    lda.w $01F61A,y : inc #2
    clc : adc !D8,x : sta $98
    lda !14D4,x : adc #$00 : sta $99

    ; Set the tongue X position
    lda !157C,x : bne +
    lda.w $01F60A+8,y : clc : adc !151C,x
    ldy #$00
    bra ++
+   lda.w $01F60A,y : sec : sbc !151C,x
    ldy #$FF
++  clc : adc !E4,x : sta $9A
    tya : adc !14E0,x : sta $9B

    ; Restore DB
    plb
    rts

block_interact:
.layer1:
    ; First check layer 1
    stz $1933|!addr
    jsr .interaction

.layer2:
    ; Return if not a layer 2 level
    lda $5B : bmi +
    rts
+
    ; If vertical level, restore $98-$9A
    and #$03 : beq +
    rep #$30
    lda $9B
    ldy $99
    sty $9B
    sta $99
    sep #$30
+   
    ; Now check layer 2
    inc $1933|!addr

    ; Offset block position with the layer 2 offset
    rep #$20
    lda $98 : clc : adc $28 : sta $98
    lda $9A : clc : adc $26 : sta $9A
    sep #$20

.interaction:
    ; Get the block map16 number
    jsl GetMap16_Main

    ; Check switch-changing blocks
    jsr check_special_blocks
    bcs .solid

    ; Get the block act as
    jsl GetMap16_ActAs

    ; Return if not act as 0x100-0x1FF
    cpy #$01 : bne .return

if !trigger_blocks
    ; Activate the block
    dey
    jsl $00F160|!bank
endif
    
    ; Check if the block acts solid
    phx
    lda $1693|!addr : and #$07 : tax
    lda.l $018000|!bank,x : pha
    lda $1693|!addr : lsr #3 : tax
    pla
    and.l solid_act_as,x
    plx
    cmp #$00 : beq .return

.solid:
if !solid_sfx != $00
    ; Play the SFX
    lda.b #!solid_sfx : sta !solid_sfx_addr
endif
    ; Go to the "retracting tongue" phase
    lda #$02 : sta !1594,x
    lda.l $01F329|!bank : sta !1558,x

    ; Reduce the tongue length a bit to avoid
    ; eating an item spawned from the block
if !items_from_blocks_fix
    lda !151C,x : cmp #$0A : bcs +
    stz !1594,x
    stz !1558,x
    stz !151C,x
    rts
+   sec : sbc #$0A : sta !151C,x
endif
.return:
    rts

macro scan_tables(table)
    ldy.b #<table>_solid_end-<table>_solid
?-  beq ?+
    cmp.w <table>_solid-2,y : bne ?++
    sec
    jmp .return
?++ dey #2
    bra ?-
?+  
    ldy.b #<table>_air_end-<table>_air
?-  beq ?+
    cmp.w <table>_air-2,y : bne ?++
    jmp .return_air
?++ dey #2
    bra ?-
?+
endmacro

check_special_blocks:
    phb : phk : plb

    ; Save map16 number to A (16 bit)
    xba : tya : xba

    rep #$20
    
    ; Check Blue P-Switch
    ldy $14AD|!addr : beq +
    %scan_tables(blue_pswitch)
+   
    ; Check Silver P-Switch
    ldy $14AE|!addr : beq +
    %scan_tables(silver_pswitch)
+
    ; Check ON/OFF switch (inverted!)
    ldy $14AF|!addr : bne +
    %scan_tables(onoff_switch)
+   
    ; If you want to add more custom switches here, just follow the format of the previous lines:
    ; ldy <address> : beq +
    ;     %scan_tables(mycool_switch)
    ; +
    ; At the top put two tables "mycool_switch_solid" and "mycool_switch_air"
    ; and have both end with ".end"


    ; No solid block was found, so CLC
    clc
.return:
    plb
    sep #$20

    ; Restore map16 number to A/Y
    xba : tay : xba
    rts

.return_air:
    plb
    ; Destroy the JSR so we skip the block interaction altogether
    pla
    sep #$20
    rts

;========================================================================================
; This table determines the behavior of blocks 0x100-0x1FF, and blocks that act like them
; Bit 0 = block is not solid
; Bit 1 = block is solid (Yoshi's tongue will stop on these)
;========================================================================================
solid_act_as:
    db %00000000 ; 100-107
    db %00000000 ; 108-10F
    db %01111111 ; 110-117
    db %11111111 ; 118-11F
    db %11111111 ; 120-127
    db %11111111 ; 128-12F
    db %10111111 ; 130-137
    db %11111111 ; 138-13F
    db %11111111 ; 140-147
    db %11111111 ; 148-14F
    db %11111111 ; 150-157
    db %11111000 ; 158-15F
    db %01111111 ; 160-167
    db %11111100 ; 168-16F
    db %00000000 ; 170-177
    db %00000000 ; 178-17F
    db %00000000 ; 180-187
    db %00000000 ; 188-18F
    db %00000000 ; 190-197
    db %00000000 ; 198-19F
    db %00000000 ; 1A0-1A7
    db %00000000 ; 1A8-1AF
    db %00000000 ; 1B0-1B7
    db %00000000 ; 1B8-1BF
    db %00001111 ; 1C0-1C7
    db %11000000 ; 1C8-1CF
    db %00000000 ; 1D0-1D7
    db %00000000 ; 1D8-1DF
    db %00000000 ; 1E0-1E7
    db %00001111 ; 1E8-1EF
    db %00000000 ; 1F0-1F7
    db %00000000 ; 1F8-1FF
