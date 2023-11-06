;=======================================================================;
; Overworld Warp Menu v1.1                                              ;
; by KevinM                                                             ;
;                                                                       ;
; Insert in gamemode 0E with UberASMTool.                               ;
; Make sure to have the ow_teleport_defines.asm and ascii.txt files in  ;
; the gamemode folder too.                                              ;
;                                                                       ;
; The ExGFX provided is GFX28 with an additional "/" tile, to be used   ;
; with the !ShowCounter option (insert it in LG1 in all submaps).       ;
;                                                                       ;
; Unless you want to modify how this code works, don't touch this file. ;
; Edit the ow_teleport_defines.asm file instead.                        ;
;=======================================================================;

table "ascii.txt"

incsrc ow_teleport_defines.asm

!Flag           = !FreeRAM+0  ; 1 byte
!YSpeed         = !FreeRAM+1  ; 2 bytes
!GroundTimer    = !FreeRAM+3  ; 1 byte
!OptionsCounter = !FreeRAM+4  ; 1 byte
!MenuEntries    = !FreeRAM+5  ; !NumOptions+1 bytes

!CursorFrame    = $1B91|!addr
!CursorPosition = $1B92|!addr
!StripeIndex    = $7F837B
!StripeImage    = $7F837D

!CounterLength  = 7
!NumOptionsH    = (!NumOptions/100)
!NumOptionsD    = ((!NumOptions-(100*!NumOptionsH))/10)
!NumOptionsU    = (!NumOptions-(100*!NumOptionsH)-(10*!NumOptionsD))

macro EndStripeUpload()
    txa
    sta !StripeIndex
    lda #$FFFF
    sta !StripeImage,x
    sep #$30
endmacro

init:
    lda #$00
    sta !Flag
    rtl

main:
    lda !Flag
    asl
    tax
    jsr (.Pointers,x)
    lda !Flag
    beq .return
    stz $15             ;\
    stz $16             ;| Disable buttons.
    stz $17             ;|
    stz $18             ;/
.return
    rtl

.Pointers:
    dw Normal
    dw Menu
    dw Warp

Normal:
    lda $13D4|!addr
    ora $1B87|!addr
    bne .return
    lda $13D9|!addr
    beq .ok
    cmp #$03
    bne .return
.ok
    lda !ButtonRAM
    and #!ButtonValue
    beq .return
    lda #!OpenSFX
    sta !OpenSFXAddr
    lda !Flag
    inc
    sta !Flag
    stz !CursorFrame
    stz !CursorPosition
    rep #$20
    lda.w #!BGColor     ;\
    sta $0701|!addr     ;|
    stz $41             ;|
    stz $2123           ;|
    lda #$0217          ;|
    sta $212C           ;|
    sta $212E           ;|
    sep #$20            ;| Set new screen settings.
    lda #$B3            ;| (same used by game over screen)
    sta $40             ;|
    sta $2131           ;|
    lda #$30            ;|
    sta $43             ;|
    sta $2125           ;|
    lda #$20            ;|
    sta $44             ;|
    sta $2130           ;/
    jsr EnableWindow
    jsr SetOptionsTable
    jsr DrawCursor
    jsr DrawText
if !ShowCounter
    jsr DrawCounter
endif
.return
    rts

EnableWindow:
; Ripped from $00A17E
    rep #$30            ;\
    ldx #$01BE          ;|
    lda #$FF00          ;|
-   sta $04A0|!addr,x   ;| Enable vanilla window HDMA (channel 7).
    dex #2              ;| Required to fix it breaking after the save prompt is closed.
    bpl -               ;|
    sep #$30            ;|
    lda #$80            ;|
    tsb $0D9F|!addr     ;/
    rts

SetOptionsTable:
    lda #$00
    sta !OptionsCounter
    tax
.loop
if !StartMapAlwaysUnlocked != 0
    cpx #$00
    beq ++
endif
    lda RequiredEvent,x
    and #$07
    tay
    lda .EventBitTable,y
    sta $00
    lda RequiredEvent,x
    lsr #3
    tay
    lda $1F02|!addr,y
    and $00
    beq +
++  lda !OptionsCounter
    tay
    txa
    tyx
    sta !MenuEntries,x
    tax
    lda !OptionsCounter
    inc
    sta !OptionsCounter
+   inx
    cpx #!NumOptions
    bcc .loop
if !ShowExitOption == 1
    lda !OptionsCounter
    tax
    inc
    sta !OptionsCounter
    lda #!NumOptions    ;\ Always store the "Exit" option at the end
    sta !MenuEntries,x  ;/
endif
    rts

.EventBitTable
    db $80,$40,$20,$10,$08,$04,$02,$01

if !ShowCounter
DrawCounter:
    jsr ComputeCounters
    rep #$30
    lda !StripeIndex
    tax
    lda.w #$5000|(!CounterYPos<<5)|!CounterXPos
    xba
    sta !StripeImage,x
    inx #2
    lda.w #((2*!CounterLength)-1)<<8
    sta !StripeImage,x
    inx #2
    ldy #$0000
-   lda.w $02|!dp,y
    sta !StripeImage,x
    inx #2
    iny #2
    cpy #$000E
    bcc -
    %EndStripeUpload()
    rts

; $02-$0F: stripe table to use for the counter ("XXX/YYY")
ComputeCounters:
    rep #$20
    lda.w #$20FC|(!CounterPalette<<10)
    sta $02
    sta $04
    sta $06
    sta $08
    sta $0A
    sta $0C
    sta $0E
    sep #$20

; Convoluted checks to see how to arrange the characters in the counter
if !NumOptionsH == $00
if !NumOptionsD == $00
    lda.b #!SlashTile
    sta $0C
    lda.b #!NumOptionsU
    sta $0E
    ldx #$04
else
    lda.b #!SlashTile
    sta $0A
    lda.b #!NumOptionsD
    sta $0C
    lda.b #!NumOptionsU
    sta $0E
    ldx #$02
endif
else
    lda.b #!SlashTile
    sta $08
    lda.b #!NumOptionsH
    sta $0A
    lda.b #!NumOptionsD
    sta $0C
    lda.b #!NumOptionsU
    sta $0E
    ldx #$00
endif

; Now compute the digits for the current count, and skip trailing zeroes.
    lda !OptionsCounter
if !ShowExitOption
    dec
endif
    sta $4204
    stz $4205
    lda #10
    sta $4206
    jsr .return
    nop
    lda $4216
    sta $00
    lda $4214
    sta $4204
    stz $4205
    lda #10
    sta $4206
    jsr .return
    nop
    lda $4214
    beq +
    sta $02,x
    lda $4216
    bra ++
+   lda $4216
    beq +++
++  sta $04,x
+++ lda $00
    sta $06,x
.return
    rts
endif

Menu:
    lda !CursorPosition ;\ Backup current position for later
    sta $0F             ;/
    jsr MenuButtons
    lda !Flag           ;\
    cmp #$01            ;| If the menu needs to be closed, skip stripe stuff.
    bne .return         ;/
    jsr DrawCursor
; Do various checks to see if the text needs to "scroll", which means the tilemap needs updating.
; By updating the stripe only when necessary we reduce eventual blank overflows to a minimum.
    lda !CursorPosition ;\
    cmp $0F             ;| If the cursor didn't move, skip.
    beq .return         ;/
    cmp #!ShownOptions  ;\ If past the number of options allowed on screen, update.
    bcs .update         ;/
    cmp #$00            ;\
    bne +               ;| If was on the last option and scrolled back to the first, update.
    lda $0F             ;|
if !ShowExitOption      ;|
    cmp #!NumOptions    ;|
else                    ;|
    cmp #!NumOptions-1  ;|
endif                   ;|
    beq .update         ;/
    lda !CursorPosition ;\
+   cmp #!ShownOptions-1;|
    bne .return         ;| Check if went from !ShownOptions to !ShownOption-1,
    lda $0F             ;| which means the menu needs to go back to the original state.
    cmp #!ShownOptions  ;|
    bne .return         ;/
.update
    jsr DrawText
.return
    rts

MenuButtons:
; Ripped from $009AD9
    inc !CursorFrame
    lda $16
    and #$90
    bne .selectedoption
    lda $18
    bmi .selectedoption
+   lda $16
    bit #$20
    bne .exitmenu
    and #$0C
    bne +
    rts
+   lda !OptionsCounter
    bne +
    rts
+   ldy #!CursorSFX
    sty !CursorSFXAddr
    stz !CursorFrame
    lda $16
    and #$0C
    lsr #2
    tax
    lda !CursorPosition
    adc .CursorMovement-1,x
    bpl +
    lda !OptionsCounter
    dec
+   cmp !OptionsCounter
    bcc +
    lda #$00
+   sta !CursorPosition
    rts
.selectedoption:
    lda !OptionsCounter
    beq .return
    lda #!SelectSFX
    sta !SelectSFXAddr
if !ShowExitOption
    lda !CursorPosition
    inc
    cmp !OptionsCounter
    beq .exitmenu
endif
    lda #!WarpSFX
    sta !WarpSFXAddr
    lda #$00
    sta !YSpeed
    sta !GroundTimer
    lda #$0B            ;\ Necessary to have Mario spinning.
    sta $13D9|!addr     ;/
    lda !Flag
    inc
    sta !Flag
    jsr Warp
    bra .resetmenu
.exitmenu
    lda #!CloseSFX
    sta !CloseSFXAddr
    lda !Flag
    dec
    sta !Flag
.resetmenu
    jsr ResetStripe
    lda #$30            ;\
    sta $40             ;|
    sta $2131           ;|
    stz $43             ;|
    stz $2125           ;|
    lda #$03            ;| Restore original OW screen settings.
    sta $44             ;|
    sta $2130           ;|
    rep #$20            ;|
    lda #$0215          ;|
    sta $212C           ;|
    sta $212E           ;/
    stz $15             ;\ Disable buttons.
    stz $17             ;/
    sep #$20
    lda #$80            ;\ Disable window HDMA.
    trb $0D9F|!addr     ;/
.return
    rts

.CursorMovement
    db $01,$FF,$FF

; Ripped from $009E82
DrawCursor:
    lda !OptionsCounter     ;\
    bne +                   ;|
    rts                     ;|
+   cmp #!ShownOptions      ;|
    bcc +                   ;| $02-$03: number of rows to go through
    lda #!ShownOptions      ;|
+   sta $02                 ;|
    stz $03                 ;/
    sec                     ;\ $00-$01: number of rows - cursor position
    sbc !CursorPosition     ;| Used during the loop to check when to draw the cursor
    beq ++                  ;|\
    bpl +                   ;|| If the cursor goes over the max number of options displayed, force it on the last option.
++  lda #$01                ;|/
+   tax                     ;|
    lda !CursorFrame        ;|\
    eor #$1F                ;||
    and #$18                ;|| Set to $FF on certain frames to have the blinking effect
    bne +                   ;||
    ldx #$FF                ;|/
+   stx $00                 ;|
    stz $01                 ;/
    rep #$30
    lda !StripeIndex
    tax
    lda.w #$5000|(!FirstLineYPos<<5)|!CursorXPos
.loop
    xba
    sta !StripeImage,x
    xba
    clc
    adc.w #!LinesDistance<<5
    pha
    lda #$0100
    sta !StripeImage+2,x
    lda #$38FC
    ldy $00
    cpy $02
    bne +
    lda.w #$2100|!CursorTile|(!CursorPalette<<10)
+   sta !StripeImage+4,x
    txa
    clc
    adc #$0006
    tax
    pla
    dec $02
    bne .loop
    %EndStripeUpload()
    rts

DrawText:
    lda !OptionsCounter     ;\
    bne +                   ;|
    rts                     ;|
+   cmp #!ShownOptions      ;|
    bcc +                   ;| $02-$03: number of rows to go through
    lda #!ShownOptions      ;|
+   sta $02                 ;|
    stz $03                 ;/
    lda !CursorPosition     ;\
    inc                     ;|
    sec                     ;|
    sbc $02                 ;| $04-$05: first option to show in the menu
    bpl +                   ;| Usually 0 except when cursor position + 1 > max number of options to display
    lda #$00                ;|
+   sta $04                 ;|
    stz $05                 ;/
    rep #$30
    lda !StripeIndex
    tax
    lda.w #$5000|(!FirstLineYPos<<5)|!TextXPos
.loop
    xba
    sta !StripeImage,x
    inx #2
    xba
    clc
    adc.w #!LinesDistance<<5
    pha
    lda.w #((!TextLength*2)-1)<<8
    sta !StripeImage,x
    inx #2
    sep #$20
    phx
    ldx $04
    lda !MenuEntries,x
    plx
    sta $4202
    lda.b #!TextLength
    sta $4203
    rep #$20
    lda.w #!TextLength
    clc
    adc $4216
    sta $00
    ldy $4216
    sep #$20
.loop2
    lda SubmapNames,y
    sta !StripeImage,x
    inx
    lda.b #$20|(!TextPalette<<2)
    sta !StripeImage,x
    inx
    iny
    cpy $00
    bne .loop2
    rep #$20
    pla
    inc $04
    dec $02
    bne .loop
    %EndStripeUpload()
    rts

ResetStripe:
    lda #!ShownOptions
    sta $02
    stz $03
    rep #$30
    lda !StripeIndex
    tax
    lda.w #$5000|(!FirstLineYPos<<5)|!CursorXPos
.loop
    xba
    sta !StripeImage,x
    xba
    clc
    adc.w #!LinesDistance<<5
    pha
    lda.w #$0040|((2+(!TextLength*2))<<8)
    sta !StripeImage+2,x
    lda #$38FC
    sta !StripeImage+4,x
    txa
    clc
    adc #$0006
    tax
    pla
    dec $02
    bne .loop

if !ShowCounter
    lda.w #$5000|(!CounterYPos<<5)|!CounterXPos
    xba
    sta !StripeImage,x
    lda.w #$0040|((2*(!CounterLength-1))<<8)    ; For some reason using 2*!CounterLength would draw 8 tiles instead of 7
    sta !StripeImage+2,x
    lda #$38FC
    sta !StripeImage+4,x
    txa
    clc
    adc #$0006
    tax
endif

    %EndStripeUpload()
    rts

Warp:
    stz $1DF7|!addr     ;\ Prevent vanilla from handling the warp.
    stz $1DF8|!addr     ;/
; Ripped from $049E52
    lda !YSpeed
    bne .flyingup
    lda !GroundTimer
    inc
    sta !GroundTimer
    cmp #!GroundTime
    bne .return
    bra .startflyup
.flyingup
    lda $13
    and #$07
    bne .skip
.startflyup
    lda !YSpeed
    inc
    sta !YSpeed
    cmp #!MaxYSpeed+1
    bne .skip
    lda #!MaxYSpeed
    sta !YSpeed
.skip
    rep #$20
    lda !YSpeed
    and #$00FF
    sta $00
    ldx $0DD6|!addr
    lda $1F19|!addr,x
    sec
    sbc $00
    sta $1F19|!addr,x
    sec
    sbc $1C
    sep #$20
    bmi .switchmaps
.return
    rts
.switchmaps
    ldx !CursorPosition
    lda !MenuEntries,x
    tay
    lda DestinationSubmap,y
    sta $13C3|!addr
    ldx $0DB3|!addr
    sta $1F11|!addr,x
    txa
    asl
    tax
    lda DestinationType,y
    sta $1F13|!addr,x
    tya
    asl
    tay
    rep #$20
    ldx $0DD6|!addr
    lda DestinationXPosition,y
    and #$01FF
    sta $1F17|!addr,x
    lsr #4
    sta $1F1F|!addr,x
    lda DestinationYPosition,y
    and #$01FF
    sta $1F19|!addr,x
    lsr #4
    sta $1F21|!addr,x
    sep #$20
    stz $0DD5|!addr
    lda #$0B            ;\ Load OW gamemode.
    sta $0100|!addr     ;/
    rts
