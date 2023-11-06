; By KevinM. Mods by SJC
; This will only start when triggered

!FreeRAMFrozen = $0EB9 ; if set at level load, timer either won't start
!FreeRAMVisible = $0EBA ; or show up until unset

!AlreadyHaveTimer = 0 ; change this to 0 if you only want timer to start counting upon trigger

!FreeRAMKillVanillaFunction = $0DEC ; note that will kill other functions

; Starting OAM index of the tiles
!oam_idx = $E4 ; $00 is default, but Yoshi tongue will make it disappear. 
               ; if E4 causes any serious problems, switch back to $00.
                        
; The 4 8x8 tiles that will be used
tiles:
    db $E6,$E7,$F6,$F7   ; 29 is 2-up. 30 and 31 - cluster leaf and fish. DD = item reserve box
	                     ; 69 and 83 were formerly free, but patch broken.
	           
			             ; C2-C3, D2-D3 are orb. $CC,$CD,$DC,$DD, Item reserve bubble 
	                     ; $4E,$4F,$5E,$4F is RETRY (20-21 is cursor). 
	
	                     ; By default $80,$81,$90,$91, 
	                     ; which will overwrite the berry sprite GFX, 
	                     ; causing a little GFX jank when Yoshi eats a berry
						 ; (both for the berry and the timer itself).
						

; X position of each tile
x_pos:
    db $D8,$E0,$E8,$F0 ; Change first value to $D0 to further separate timer icon from numbers 

; Y position of all the tiles
!y_pos = $08

; YXPPCCCT properties of all the tiles
!props = $30

; GFX file with all the tiles
gfx:
    incbin timer_gfx.bin

; RAM defines
!timer_t = $0F30|!addr
!timer_h = $0F31|!addr
!timer_d = $0F32|!addr
!timer_u = $0F33|!addr

nmi:
    ; If the level is loading, also upload the clock tile
    lda $0100|!addr : cmp #$14 : beq +
    rep #$20
    lda #$1801 : sta $4320
    ldy #$80 : sty $2115
    ldy.b #gfx>>16 : sty $4324
    lda.w #gfx+$0200 : sta $4322
    lda.l tiles : and #$00FF : asl #4
    clc : adc #$6000 : sta $2116
    lda #$0020 : sta $4325
    ldy #$04 : sty $420B
    bra ++
+
    ; We only need to upload tiles on the frame the timer changes
    lda !timer_t : cmp #$28 : bne .return
    rep #$20
    lda #$1801 : sta $4320
    ldy #$80 : sty $2115
    ldy.b #gfx>>16 : sty $4324
++  ldx #$02
-   lda !timer_h,x : and #$00FF : asl #5
    clc : adc.w #gfx : sta $4322
    lda.l tiles+1,x : and #$00FF : asl #4
    clc : adc #$6000 : sta $2116
    lda #$0020 : sta $4325
    ldy #$04 : sty $420B
    dex : bpl -
    sep #$20
.return:
    rtl

init:
    lda #$28 : sta !timer_t
	;if !AlreadyHaveTimer = 0
	;LDA #$01 
	;STA !FreeRAMKillVanillaFunction
	;endif
main:
    lda $9D
	ora $13D4|!addr
	ora $1493
	ora !FreeRAMFrozen
	bne .draw ; Only count down if not these. 
	; Added goal tape check, $1493
    
	if !AlreadyHaveTimer = 0
.tick:
    lda !timer_t : beq +
    dec !timer_t
    bra .draw
+   lda #$28 : sta !timer_t
    lda !timer_h : ora !timer_d : ora !timer_u : beq .draw
    ldx #$02
-   dec !timer_h,x
    bpl +
    lda #$09 : sta !timer_h,x
    dex : bpl -
+   lda !timer_h : ora !timer_d : ora !timer_u : bne .draw
    jsl $00F606|!bank
	endif

.draw:
    lda !FreeRAMVisible : bne + ; added SJC 
    ldx.b #!oam_idx
    ldy #$00
-   lda x_pos,y : sta $0200|!addr,x
    lda.b #!y_pos : sta $0201|!addr,x
    lda tiles,y : sta $0202|!addr,x
    lda.b #!props : sta $0203|!addr,x
    phx
    txa : lsr #2 : tax
    stz $0420|!addr,x
    plx
    inx #4
    iny
    cpy #$04 : bcc -

.check_leading_zeros:
    ldx.b #!oam_idx+4
    ldy #$00
-   lda !timer_h,y : bne +
    lda #$F0 : sta $0201|!addr,x
    inx #4
    iny
    cpy #$02 : bcc -
+
    rtl
