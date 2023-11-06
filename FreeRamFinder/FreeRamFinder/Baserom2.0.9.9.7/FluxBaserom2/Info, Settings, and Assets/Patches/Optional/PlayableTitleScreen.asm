;===================================================================================================;
; Play on the Title Screen patch by KevinM                                                          ;
;                                                                                                   ;
; Patch that allows you to play on the title screen.                                                ;
; Pressing a certain button (by default, start or select) will bring up the file select menu.       ;
; This also gives you 69 bytes of free space at $009C1F (the original title screen movement data).  ;
;===================================================================================================;

; Which button(s) bring up the file select menu
!Button    = %00110000
!ButtonRAM = $16

; 0 = play the death animation (and song) when dying, then reload the level.
; 1 = reload the level as soon as the player dies. The title screen song will keep playing.
; If using option 0 you need to use AddmusicK or the death song will be wrong.
!SkipDeath = 1

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif

; Pressing A/B/X/Y while fade-in will load the level instead of the file select menu
org $00942B
    rts

if !SkipDeath == 0
    ; Reload the song even when reloading the title screen
    org $0096BE
        bra $03 : nop #3
else
    ; Restore original code
    org $0096BE
        lda $0109|!addr
        bne $08
endif

; Skip all title screen movement crap, and make level restart if dying
org $009C67
    lda $71
    cmp #$09
if !SkipDeath != 0
    beq ReloadTitleScreen
else
    bne +
    lda $1496|!addr         ;\
    cmp #$01                ;| Only reload the title screen at the last frame of the death animation.
    beq ReloadTitleScreen   ;/
endif
+   lda !ButtonRAM
    and #!Button
    bne PrepareFileSelect
    jmp $A1DA

; Small routine to prevent the death song from being played when on the title screen.
; I got lucky that this barely fits in the space cleared up by the patch (if it didn't, I could've used the movement data area anyway...)
; Only used if !SkipDeath == 1.
CheckTitleScreen:
    lda $0100|!addr
    cmp #$07
    bne +
    stz $1DFB|!addr
+   rts

warnpc $009C89

org $009C89
ReloadTitleScreen:

org $009C9F
PrepareFileSelect:

if !SkipDeath == 0
    ; Restore original code
    org $00F60F
        lda #$FF
        sta $0DDA|!addr
else
    ; Hijack death routine to not change songs if on the title screen
    ; (compatible with retry and other death-hijacking patches)
    org $00F60F
        jsr CheckTitleScreen
        bra $00
endif

