;===========================================================================================
; Better Ghost House Exit Sprite by KevinM
;
; This patch make the Ghost House Exit sprite draw its tile based on its position, rather than using hardcoded values.
; This allows you to place it in different spots in LM to change where it'll be drawn (since LM will always display it
; on the vanilla position, turn on "Sprite Data (Hex Code)" viewing to see where the sprite actually is and move it).
; It also allows to have multiple instances of this sprite in the same sublevel (NMSTL/SA-1 is required in this case).
;
; It also fixes a couple issues in vanilla:
; - Part of the right door appears when the door is too much offscreen horizontally.
; - The tiles always appear at the same position even when scrolling the screen vertically.
;
; You can also change the tilemap easily with the tables below, and also change how many tiles it uses
; (make sure each table has the same amount of bytes).
; Since the patch uses 34 bytes less than vanilla, those are free if you want to add more tiles to the tilemap
; (since it's 4 tables, you can add up to 8 tiles).
;
; If you're not using the "No More Sprite Tile Limits" patch (or SA-1), I recommend using
; sprite header 0E, which seems to work well with this when there's a bunch of other sprites on screen.
; Using other headers often resulted in some tiles having the wrong priority with respect to Mario.
;===========================================================================================

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

org $02F594
    phb
    phk
    plb
    jsr GhostExitMain   ; JSR is required to not make GetDrawInfo crash
    plb
    rtl

GhostExitMain:
    jsr $D378           ; Call GetDrawInfo in bank 2
    phx
    ldx.b #YDisp-XDisp-1
.loop
    lda $00
    clc
    adc.w XDisp,x
    sta $0300|!addr,y
    lda $01
    clc
    adc.w YDisp,x
    sta $0301|!addr,y
    lda.w Tiles,x
    sta $0302|!addr,y
    lda.w Props,x
    sta $0303|!addr,y
    iny #4
    dex
    bpl .loop
    plx
    lda.b #YDisp-XDisp-1
    ldy #$02
    jmp $B7A7           ; Jump to finish OAM routine

; You can change the tilemap here.
; Tile order is: Exit sign (2 tiles), left door (4 tiles), right door (4 tiles).
XDisp:      ; X displacement of each tile
    db $08,$18,$F8,$F8,$F8,$F8,$28,$28,$28,$28

YDisp:      ; Y displacement of each tile
    db $FF,$FF,$2F,$37,$47,$4F,$2F,$37,$47,$4F

Tiles:      ; Tile number of each tile
    db $9C,$9E,$A0,$B0,$B0,$A0,$A0,$B0,$B0,$A0

Props:      ; YXPPCCCT properties of each tile
    db $23,$23,$2D,$2D,$AD,$AD,$6D,$6D,$ED,$ED

warnpc $02F619
