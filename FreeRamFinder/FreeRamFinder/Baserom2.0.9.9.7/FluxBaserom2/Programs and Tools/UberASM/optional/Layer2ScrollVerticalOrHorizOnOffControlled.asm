; ON/OFF Switch controlled Layer 2 scroll
; by KevinM

; 0 = horizontal, 1 = vertical
; Make sure that the corresponding scroll is set to "None" in LM!
; (V-Scroll for vertical, H-Scroll for horizontal).
!Direction = 1

; Note: you can invert the movement behavior (for example, make the layer go
; down when the switch is OFF, and invert the switch and go back up later) just
; by inverting the speed and acceleration (i.e. put a - sign before them).
; You also need to change the limits (i.e. !LowLimit becomes the !HighLimit, and viceversa).
; Examples:
; - Positive acc. and speed, !HighLimit > !LowLimit:
;   - If horizontal, layer 2 goes down when the switch is on, goes back up when it's off.
;   - If vertical, layer 2 goes right when the switch is on, goes back left when it's off.
; - Negative acc. and speed, !LowLimit > !HighLimit:
;   - If horizontal, layer 2 goes up when the switch is on, goes back down when it's off.
;   - If vertical, layer 2 goes left when the switch is on, goes back right when it's off.

; Positions between which the layer 2 moves.
; Note: the code will check if the position is exactly equal to one of these values
; to see if it should switch direction, so it can happen it fails at high speeds.
; If it happens, try changing the values by 1 pixel until it works properly.
; Also, for horizontal scroll you usually want a negative value for !HighLimit (i.e. first two digits = $FF,$FE etc.)
; but also for !LowLimit if the speed is positive (it can be hard to get the right values to do what you want, so experiment a bit!)
!LowLimit     = $0020
!HighLimit    = $00C1

; How fast it reaches the top speed.
!Acceleration = $0001

; Top movement speed.
!Speed        = $0040

; 0 = don't invert the ON/OFF state when reaching the top.
!InvertSwitch = 1

; SFX to play when getting down.
!SFX     = $09
!SFXAddr = $1DFC|!addr

; How long to shake layer 1 for when it goes back up.
; $00 = no shake.
!Layer1ShakeTime = $20

; How long to shake layer 2 for when it goes back down.
; $00 = no shake.
!Layer2ShakeTime = $10

; Set to 1 to prevent the camera from moving horizontally.
!DisableHorzLayer1Scroll = 0

; Don't change from here.
!Switch    = $14AF|!addr
!Position  = ($1466|!addr)+(!Direction*2)
!SpeedAddr = ($144A|!addr)+(!Direction*2)
!Index     = $04+(!Direction*2)

; Flag to fix a bug in the vanilla sprite.
; We'll just use a scroll sprite ram which won't be used otherwise here.
!HitGroundFlag = ($144A|!addr)+((1-!Direction)*2)

; Init ON/OFF controlled layer 2 code.
; Disassembled from $05BFF6.
init:
if !DisableHorzLayer1Scroll
    stz $1411|!addr
endif
    rep #$20
    stz $1442|!addr
    stz $1444|!addr
    stz $1446|!addr
    stz $1448|!addr
    stz $144A|!addr
    stz $144C|!addr
    stz $144E|!addr
    stz $1450|!addr
    stz $1452|!addr
    stz $1454|!addr
    sep #$20
    stz !HitGroundFlag
    rtl

; Main ON/OFF controlled layer 2 code.
; Disassembled from $05C727.
main:
    lda $9D
    ora $13D4|!addr
    bne .return
    ldx !Switch
    beq .On
    stz !HitGroundFlag
    ldx #$02
.On
    cpx $1443|!addr
    beq .IsMoving
    dec $1445|!addr
    bpl +
    stx $1443|!addr
+   lda !Position
    eor #$01
    sta !Position
    stz !SpeedAddr
    stz !SpeedAddr+1
    rtl
.IsMoving
    lda.b #!Layer2ShakeTime
    sta $1445|!addr
    rep #$20
    lda !Position
    cmp .Limit,x
    bne .KeepMoving
    cpx #$00
    bne .NoShake
    lda !HitGroundFlag
    bne .NoShake
    inc !HitGroundFlag
    lda.w #!SFX
    sta !SFXAddr
    lda.w #!Layer1ShakeTime
    sta $1887|!addr
.NoShake
if !InvertSwitch
    ldx #$00
    stx !Switch
endif
    sep #$20
    rtl
.KeepMoving
    lda !SpeedAddr
    cmp .Speed,x
    beq .NoAcceleration
    clc
    adc .Acceleration,X
    sta !SpeedAddr
.NoAcceleration
    ldx.b #!Index
    jsr MoveLayer
    sep #$20
.return
    rtl

.Limit:
    dw !LowLimit,!HighLimit

.Speed:
    dw -!Speed,!Speed

.Acceleration:
    dw -!Acceleration,!Acceleration

; Generic routine to move layers.
; Disassembled from $05C4F9.
MoveLayer:
    lda $144E|!addr,x
    and #$00FF
    clc
    adc $1446|!addr,x
    sta $144E|!addr,x
    and #$FF00
    bpl +
    ora #$00FF
+   xba
    clc
    adc $1462|!addr,x
    sta $1462|!addr,x
    rts
