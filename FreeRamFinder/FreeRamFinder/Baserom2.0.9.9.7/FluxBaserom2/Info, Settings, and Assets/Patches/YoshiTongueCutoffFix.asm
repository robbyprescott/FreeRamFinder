if read1($00FFD5) == $23
    sa1rom
    !157C = $3334
    !addr = $6000
    !bank = $000000
else
    lorom
    !157C = $157C
    !addr = $0000
    !bank = $800000
endif

; Initialize "offscreen to the left" flag.
; Also prevent the routine from return preemtively in case the first tile is already offscreen to the left.
org $01F433
    autoclean jml InitFlag

; We check if this is the last tile later, so skip this part.
org $01F46F
    bra $0D

org $01F4A3
    autoclean jml Fix

freecode

InitFlag:
    stz $0E                 ;> Use $0E as "offscreen to the left flag". Initially 0.
    lda !157C,x             ;\
    bne .Left               ;| If facing right, continue with the original code.
    jml $01F438|!bank       ;/
.Left
    bcs +                   ;\ If Yoshi is very far to the left, the first tile is already
    inc $0E                 ;/ partially offscreen so we set the flag to 1...
+   jml $01F43E|!bank       ;> ...and draw one tile, rather than returning immediately.

Fix:
    lda $0E                 ;\ If the "offscreen to the left" flag is set,
    bne .EndLoop2           ;/ set the bit in $0420 and end drawing.
    lda #$00
    sta $0420|!addr,y
    lda $00                 ;\
    clc                     ;| Set the X position for the next tile.
    adc $05                 ;|
    sta $00                 ;/
    lda $05
    bpl +
    bcs .ContinueLoop       ;\ If the tile goes offscreen to the left, set the flag.
    inc $0E                 ;/
    bra .ContinueLoop
+   bcs .EndLoop
.ContinueLoop
    jml $01F4A8|!bank
.EndLoop2
    lda #$01
    sta $0420|!addr,y
.EndLoop
    ply                     ;> Here we skip the PLY at $01F4A8 so we need to do it ourselves.
    jml $01F4B1|!bank
