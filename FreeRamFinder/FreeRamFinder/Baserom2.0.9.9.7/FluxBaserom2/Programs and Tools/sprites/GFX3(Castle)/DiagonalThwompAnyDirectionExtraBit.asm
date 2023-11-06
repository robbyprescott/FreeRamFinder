;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Improved Diagonal Thwomps, by Major Flare
;;
;; Based on: Diagonal Thwomps, by yoshicookiezeus
;;
;; Just your normal Thwomp, but moves diagonally.
;; 
;; Uses Extra bit? Yes.
;;   - Extra bit enabled: Power Thwomps.
;;
;; Extra Byte 1: Bit field. Format: m--- --dd
;;  m: Mad flag. If set, Power Thwomp will smash endlessly. Used only
;;     when extra bit is set.
;;  dd: Direction (binary):
;;   - 00: right, down
;;   - 01: right, up
;;   - 10: left, down
;;   - 11: left, up
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Gravity = $04          ; Valid Values: 00-7F
!MaxSpeed = $3E         ; Max Speed, both horizontal and vertical. Range: 00-7F
!RiseSpeed = $10        ; Max Returning speed. Range: 00-7F
!NormalShakeTimer = $18 ; Earthquake timer, normal thwomp
!PowerShakeTimer = $22  ; Earthquake timer, power and mad thwomps
!FreezeTimeNormal = $40 ; Time to make normal thwomps rise again
!FreezeTimeMad = $10    ; Time between Mad Thwomp smashings.

!Sound = $09            ; Sound.
!SoundBank = $1DFC      ; Sound bank.

; Please, do not change unless you know what you are doing.
!Expression = !1528
!State = !C2
!Direction = !1602
!OrigX = !1504
!OrigY = !151C
!Freeze = !1540

print "INIT ", pc
    lda !D8,x
    sta !OrigY,x
    
    lda !E4,x
    clc : adc #$08
    sta !E4,x
    sta !OrigX,x
    
    lda !7FAB40,x
    and #$03
    sta !Direction,x
    
    rtl

print "MAIN ",pc
    phb : phk : plb
    jsr ThwompMain
    plb
    rtl

Return:
    rts
ThwompMain:
    jsr DrawThwomp

    lda !14C8,x
    cmp #$08
    bne Return
    lda $9D
    bne Return
    
    lda #$00
    %SubOffScreen()
    
    jsl $01A7DC|!bank
    
    lda !State,x
    jsl $0086DF|!bank
    dw Hover
    dw Smashing
    dw Wait
    dw Rise

Hover:
    lda !186C,x
    bne .fall
    lda !15A0,x
    bne .return
    
    %SubHorzPos()
    tya
    ldy !Direction,x
    sta !157C,x
    eor .condition,y
    beq .return
.fall
    lda #$02
    sta !Expression,x
    
    inc !State,x
    
    lda .initX,y
    sta !B6,x
    lda .initY,y
    sta !AA,x
.return
    rts

.condition
    db $01, $01, $00, $00
.initX
    db $00, $00, $FF, $FF
.initY
    db $00, $FF, $00, $FF
    
Smashing:
    jsl $01801A|!bank
    jsl $018022|!bank
    
    ldy !Direction,x
    
    lda !AA,x
    jsr .absValue
    cmp #!MaxSpeed
    bcs +
    lda !AA,x
    clc : adc .gravityY,y
    sta !AA,x
   
+   lda !B6,x
    jsr .absValue
    cmp #!MaxSpeed
    bcs ++
    lda !B6,x
    clc : adc .gravityX,y
    sta !B6,x

++  phy
    jsl $019138|!bank
    ply
    
    lda !1588,x
    and .blockedY,y
    bne .hit
    
    phy
    tya
    lsr
    tay
    
    lda !E4,x
    pha
    clc : adc .offsetLo,y
    sta !E4,x
    lda !14E0,x
    pha
    adc .offsetHi,y
    sta !14E0,x
    
    jsl $019138|!bank
    
    pla : sta !14E0,x
    pla : sta !E4,x
    
    ply
    
    lda !1588,x
    and .blockedX,y
    bne .hit
    rts

.hit
    jsr .someSpeedRoutine
    
    lda !7FAB10,x
    and #$04
    bne .power
    lda #!NormalShakeTimer
    sta $1887|!addr
    bra .sound
.power
    ldy #!PowerShakeTimer
    sty $1887|!addr
    lda $77
    and #$04
    beq .sound
    sty $18BD|!addr
.sound
    lda #!Sound
    sta !SoundBank|!addr
    
    ldy #$00
    lda !7FAB40,x
    bpl .nomad
    iny
.nomad
    lda .time,y
    sta !Freeze,x
    
    inc !State,x
    rts
    
.absValue
    bpl +
    eor #$ff
    inc
+   rts

.someSpeedRoutine
    lda !1588,x
    bmi +
    lda #$00
    ldy !15B8,x
    beq ++
+   lda #$18
++  sta !AA,x
    sta !B6,x
    rts

.time
    db !FreezeTimeNormal, !FreezeTimeMad
.offsetLo
    db $07, $F6
.offsetHi
    db $00, $FF
.blockedY
    db $04, $08, $04, $08
.blockedX
    db $01, $01, $02, $02
.gravityX
    db !Gravity, !Gravity, -!Gravity, -!Gravity
.gravityY
    db !Gravity, -!Gravity, !Gravity, -!Gravity

Wait:
    lda !Freeze,x
    bne .return
    
    lda !7FAB40,x
    bmi .ismad
    
    stz !Expression,x
    inc !State,x
.return
    rts
.ismad
    lda !Direction,x
    eor #$03
    sta !Direction,x
    dec !State,x
    rts

Rise:
    lda !D8,x
    cmp !OrigY,x
    bne .move
    
    lda !OrigX,x
    sta !E4,x
    stz !State,x
    rts
.move
    ldy !Direction,x
    lda .riseX,y
    sta !B6,x
    lda .riseY,y
    sta !AA,x
    jsl $01801A|!bank
    jsl $018022|!bank
    rts
    
.riseX
    db -!RiseSpeed, -!RiseSpeed, !RiseSpeed, !RiseSpeed
.riseY
    db -!RiseSpeed, !RiseSpeed, -!RiseSpeed, !RiseSpeed
    
;;;; GFX Routine
!AngryTile = $CA
X_OFFSET:		db $FC,$04,$FC,$04,$00 
Y_OFFSET:		db $00,$00,$10,$10,$08 
TILE_MAP:		db $8E,$8E,$AE,$AE,$C8 
PROPERTIES:		db $03,$43,$03,$43,$03

DrawThwomp:
    %GetDrawInfo()
    
    lda !Expression,x
    sta $02
    phx
    ldx #$03
    cmp #$00
    beq .loop
    inx
.loop
    lda $00
    clc : adc X_OFFSET,x
    sta $0300|!addr,y
    
    lda $01
    clc : adc Y_OFFSET,x
    sta $0301|!addr,y
    
    lda PROPERTIES,x
    ora $64
    sta $0303|!addr,y
    
    lda TILE_MAP,x
    cpx #$04
    bne .normal
    phx
    ldx $02
    cpx #$02
    bne +
    lda #!AngryTile
+   plx
.normal
    sta $0302|!addr,y
    
    iny #4
    dex
    bpl .loop
    
    plx
    ldy #$02
    lda #$04
    %FinishOAMWrite()
    rts;