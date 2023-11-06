; DKC "Blackout Basement"-inspired lights uberasm, with smooth transitions rather than sudden brightness changes.

; 2 bytes of free ram
!Timer = $0EE2|!addr

; How dark the screen should go
; Value between $00 (less dark) and $1F (darkest)
!DarkValue = $1F

; How bright the screen should go when hitting the switch
; Value between $00 (less dark) and $1F (darkest)
; Should be less than !DarkValue
!BrightValue = $00

; How many frames between each brightness level
; Total time will be (!DarkValue - !BrightValue + 1) * !TransitionTime
!TransitionTime = $03

; 0 = lights fade out, switch activates lights
; 1 = lights fade out and in
!Type = 0

; What switch triggers the lights. Only relevant if !Type = 0.
; 0: red switch (sprite C8) (when hit: light on, then fade to dark)
; 1: ON/OFF switch (when hit: light on, then fade to dark)
; 2: Blue P-Switch (when hit: lights on, then fade to dark)
; 3: Silver P-Switch (when hit: lights on, then fade to dark)
; 4: ON/OFF switch (when ON: lights on, when OFF: fade to dark)
; 5: Blue P-Switch (when ON: lights on, when OFF: fade to dark)
; 6: Silver P-Switch (when ON: lights on, when OFF: fade to dark)
!SwitchType = 0

; With this you can set which layers are affected (by default all layers except sprites).
; Note that even if enabled for sprites, only those with palette C-F will be affected.
; For more info see https://smwc.me/m/smw/ram/7E0040.
!CGADSUB = $AF

; Don't edit this
!TimeToDark = (((!DarkValue-!BrightValue+1)*!TransitionTime)-1)

macro InitTimer()
    lda.b #!TimeToDark          ;\
    sta !Timer                  ;| Init timer.
    lda.b #!TimeToDark>>8       ;|
    sta !Timer+1                ;/
endmacro

init:
    rep #$20
    lda #$0017
    sta $212C
    sta $212E
    lda #$2020
    sta $43
    sep #$20
    lda.b #!CGADSUB
    sta $40
    lda.b #read1($0092A1)
    tsb $0D9F|!addr
    
if !Type == 0 && !SwitchType == 1
    lda.b #!TimeToDark          ;\
    sta !Timer                  ;|
    lda $14AF|!addr             ;|
    lsr                         ;| Init the timer and switch state backup.
    lda #$00                    ;|
    ror                         ;|
    ora.b #!TimeToDark>>8       ;|
    sta !Timer+1                ;/
else
    %InitTimer()
endif

    jsr lights                  ; Init brightness.
return:
    rtl

main:
    lda $9D                     ;\
    ora $13D4|!addr             ;| Skip if paused.
    bne return                  ;/

    jsr lights                  ; Apply brightness.

if !Type == 0
if !SwitchType == 0
    ldx #!sprite_slots-1        ;\
-   lda !14C8,x                 ;|
    cmp #$08                    ;|
    bcc +                       ;|
    lda !9E,x                   ;|
    cmp #$C8                    ;|
    bne +                       ;|
    lda !1558,x                 ;| If Mario hit a red switch, reset the timer.
    cmp #$05                    ;|
    bne +                       ;|
    %InitTimer()                ;|
    rtl                         ;|
+   dex                         ;|
    bpl -                       ;/
elseif !SwitchType == 1
    lda !Timer+1                ;\
    asl                         ;|
    lda #$00                    ;|
    rol                         ;|
    cmp $14AF|!addr             ;|
    beq +                       ;|
    lda.b #!TimeToDark          ;|
    sta !Timer                  ;| If the ON/OFF state changed, reset the timer.
    lda $14AF|!addr             ;|
    lsr                         ;|
    lda #$00                    ;|
    ror                         ;|
    ora.b #!TimeToDark>>8       ;|
    sta !Timer+1                ;|
+                               ;/
elseif !SwitchType == 2 || !SwitchType == 3
    !Color = (!SwitchType-2)

    lda ($14AD|!addr)+!Color    ;\
    cmp.b #read1($01AB1B)       ;|
    bne +                       ;| If the P-Switch was just hit, reset the timer.
    %InitTimer()                ;|
    rtl                         ;|
+                               ;/
elseif !SwitchType == 4
    lda $14AF|!addr
    bne +
    %InitTimer()
+
elseif !SwitchType == 5 || !SwitchType == 6
    !Color = (!SwitchType-5)

    lda ($14AD|!addr)+!Color
    beq +
    %InitTimer()
+
endif
endif

if !Type == 0
if !SwitchType == 1
    rep #$20
    lda !Timer
    and #$8000
    sta $00
    lda !Timer
    and #$7FFF
    beq +
    dec
    ora $00
    sta !Timer
+   sep #$20
    rtl
else
    rep #$20                    ;\
    lda !Timer                  ;|
    beq +                       ;| Tick the timer.
    dec !Timer                  ;|
+   sep #$20                    ;/
    rtl
endif
else
    rep #$20
    lda !Timer
    bmi tick_up
tick_down:
    dec
    bne +
    ora #$8000
+   sta !Timer
    sep #$20
    rtl
tick_up:
    inc
    cmp.w #$8001|!TimeToDark
    bne +
    and #$7FFF
+   sta !Timer
    sep #$20
    rtl
endif

lights:
    rep #$20                    ;\
    lda !Timer                  ;|
    and #$7FFF                  ;| Mask out highest bit
    sta $4204                   ;|
    sep #$20                    ;|
    lda.b #!TransitionTime      ;|
    sta $4206                   ;| Find brightness to apply based on the timer and store it in $0701.
    lda ($00,s),y               ;| Waste 7 cycles
    rep #$20                    ;| + 3
    lda.w #!DarkValue           ;| + 3
    sec                         ;| + 2
    sbc $4214                   ;|
    rep #$20                    ;|
    sta $00                     ;|
    asl #5                      ;|
    ora $00                     ;|
    sta $00                     ;|
    asl #5                      ;|
    ora $00                     ;|
    sta $0701|!addr             ;|
    sep #$20                    ;/
    rts
