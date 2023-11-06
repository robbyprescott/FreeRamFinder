;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Line-Guided Rope (sprite 64), by imamelia
;;
;; This is a disassembly of sprite 64 in SMW, the line-guided rope.
;;
;; Note that Extra Byte 4 MUST be set to a non-zero value, or else
;; the rope won't do anything.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Custom version by KevinM, v1.1
;;
;; Extra Byte 1: length of the rope, -1 (for example, $03 = 4 tiles rope)
;;   Note: using $FE crashes the game, using $FF causes glitched graphics. You'll never need values this huge anyway.
;;
;; Extra Byte 2: Y speed when going down ($00-$7F).
;;
;; Extra Byte 3: Y speed when going up ($00-$7F).
;;
;; Extra Byte 4: max Y displacement ($00-$FF). MUST be set to a non-zero value.
;;
;; Extra Byte 5: X offset on spawn ($00-$FF).
;;
;; Extra Byte 6: Y offset on spawn ($00-$FF).
;;
;; Extra Byte 7: number of tiles to hide at rest ($80 = don't hide).
;;
;; Extra Byte 8: rope/gate ID ($00-$FF).
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 1 = fix the glitch where being pushed off of the rope by a solid object allows Mario to climb in the air.
; (this only applies for this sprite!)
!RopeGlitchFix  = 1

; 1 = fix the glitch where getting on the ground while climbing the rope will make it still push you around even if not climbing anymore.
; (this only applies for this sprite!)
!GroundFix      = 1

; Misc. graphics stuff
!RopeTile       = $CE
!BottomRopeTile = $DE

!sfx      = $1A
!sfx_addr = $1DF9|!addr
!sfx_freq = $03     ; Frequency to play sfx when moving. Lower = faster.
                    ; Valid values: $01,$03,$07,$0F,$1F,$3F.

!ID         = !C2
!Length     = !1504
!SpeedDown  = !1510
!SpeedUp    = !151C
!MaxYDelta  = !1528
!YLoBackup  = !1534
!IsMoving   = !1570
!CoverTiles = !157C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro LoadExtraBytesPointer()
    lda !extra_byte_1,x
    sta $00
    lda !extra_byte_2,x
    sta $01
    lda !extra_byte_3,x
    sta $02
    ldy #$00
endmacro

macro StoreExtraByte(addr)
    lda [$00],y
    sta <addr>
    iny
endmacro

macro StoreExtraByteX(addr)
    lda [$00],y
    sta <addr>,x
    iny
endmacro

print "INIT ",pc
    %LoadExtraBytesPointer()
    %StoreExtraByteX(!Length)
    %StoreExtraByteX(!SpeedDown)
    %StoreExtraByteX(!SpeedUp)
    eor #$FF
    inc
    sta !SpeedUp,x
    %StoreExtraByteX(!MaxYDelta)
    %StoreExtraByte($03)
    %StoreExtraByte($04)
    %StoreExtraByteX(!CoverTiles)
    %StoreExtraByteX(!ID)
    stz $00
    lda $03
    bpl +
    dec $00
+   clc
    adc !sprite_x_low,x
    sta !sprite_x_low,x
    lda !sprite_x_high,x
    adc $00
    sta !sprite_x_high,x
    stz $00
    lda $04
    bpl +
    dec $00
+   clc
    adc !sprite_y_low,x
    sta !sprite_y_low,x
    lda !sprite_y_high,x
    adc $00
    sta !sprite_y_high,x
    lda !sprite_y_low,x     ;\ Backup initial Y position.
    sta !YLoBackup,x        ;/
    stz !IsMoving,x
    rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "MAIN ",pc
    lda !14C8,x
    cmp #$08
    bne +
    phb
    phk
    plb
    jsr LineRopeGFX
    jsr LineRopeMain
    plb
+   rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro RemoveClimb()
    stz !163E,x
    stz $18BE|!Base2
    stz !IsMoving,x
endmacro

; If in a vertical level, make it despawn based on its length and how much it can go down
SubOffScreenVert:
	lda !15A0,x
	ora !186C,x
	bne +
	rts
+	lda !167A,x
	and #$04
	bne .return
	lda $13
	lsr
	bcs .return
	lda !E4,x
	cmp #$00
	lda !14E0,x
	sbc #$00
	cmp #$02
	bcs .erase
	lda #$40
	sta $0C
	lda #$01
	sta $0E
	lda !MaxYDelta,x
	sta $0A
	lda #$00
	sta $0B
	xba
	lda !Length,x
	rep #$20
	asl #4
	clc
	adc $0A
	eor #$FFFF
	inc
	sep #$20
	sta $0D
	xba
	sta $0F
	lda $13
	lsr
	and #$01
	sta $01
	tay
	lda $1C
	clc
	adc $0C|!dp,y
	rol $00
	cmp !D8,x
	php
	lda $1D
	lsr $00
	adc $0E|!dp,y
	plp
	sbc !14D4,x
	sta $00
	ldy $01
	beq +
	eor #$80
	sta $00
+	lda $00
	bpl .return
	bmi .erase
.return
	rts
.erase
	lda !14C8,x
	cmp #$08
	bcc .kill
	ldy !161A,x
	cpy #$FF
	beq .kill
	phx
	phy
	tyx
	lda #$00
if !Disable255SpritesPerLevel
	sta !1938,x
else
	sta.l !7FAF00,x
endif
	ply
	plx
.kill
	stz !14C8,x
	rts

SetYSpeed:
    lda !sprite_y_low,x
    sec
    sbc !YLoBackup,x
    sta $00
    lda !MaxYDelta,x
    beq .Stationary
    lda !IsMoving,x
    beq .GoUp
.GoDown
    lda $00
    cmp !MaxYDelta,x
    bcs .Stationary
    lda !SpeedDown,x
    sta !sprite_speed_y,x
    rts
.GoUp
    lda $00
    beq .Stationary
    lda !SpeedUp,x
    sta !sprite_speed_y,x
    rts
.Stationary
    stz !sprite_speed_y,x
    rts

LineRopeMain:
    lda $9D
    beq +
    rts
+
    lda #!sfx_freq
    sta $00
    lda !sprite_speed_y,x
    beq +
    bpl ++
    asl $00
    inc $00
++  lda $13
    and $00
    bne +
    lda #!sfx
    sta !sfx_addr
+

	lda $5B
	and #$01
	beq +
	jsr SubOffScreenVert
	bra ++
+   lda #$07
    %SubOffScreen()
++  jsr SetYSpeed
    jsl $01801A|!bank ; Y movement
    sta $185E|!Base2  ; keep track of Y axis movement

LDA $77     ;
AND #$03    ; if the player is touching a wall...

if !RopeGlitchFix
BNE +
else
BNE Return00    ; don't interact with the sprite
endif

jsr MarioContact
BCS MaybeClimb  ; if the player is touching the sprite, go to the rope interaction routine

NoClimb:        ;

LDA !163E,x ; unless the grab timer is already zero...
BEQ Return00    ;
+
%RemoveClimb()
Return00:       ;
RTS     ;

MaybeClimb:

LDA !14C8,x     ; if the sprite is nonexistent...
BEQ SkipClimbCheck  ; skip the next part of code

LDA $1470|!Base2    ; if the player is carrying something...
ORA $187A|!Base2    ; or on Yoshi...
BNE NoClimb ; don't let him/her climb the rope

if !GroundFix
lda $77
and #$04
bne +
endif

LDA #$03        ;
STA !163E,x ; set the climb timer

if !GroundFix
    bra ++
+   %RemoveClimb()
++
endif

LDA !154C,x ; if interaction is disabled...
BNE Return00    ; return

LDA $18BE|!Base2        ; if the player is already climbing...
BNE SkipButtonCheck1    ; don't check to see if he/she is pressing the up button

LDA $15     ;
AND #$08    ; if the player is pressing Up...
BEQ Return00    ;
STA $18BE|!Base2    ; set the climbing flag

SkipButtonCheck1:

BIT $16     ; if the player is pressing A or B...
BPL NoJumpOffRope   ;

LDA #$B0        ;
STA $7D     ; make him/her go upward

SkipClimbCheck:
LDA #$10        ;
STA !154C,x ; and disable interaction for a few frames
stz !IsMoving,x
STZ $18BE|!Base2    ; clear the climb flag

NoJumpOffRope:

LDY #$00        ; Y = 00
LDA $185E|!Base2    ; check the necessary position offset
BPL PlusOffset  ; if it is negative...
DEY     ; Y = FF
PlusOffset: ;
CLC     ;
ADC $96     ; add the amount the sprite moved on the Y-axis during the line-guide routine
STA $96     ; to the player's Y position
TYA     ;
ADC $97     ; handle the high byte
STA $97     ;

LDA !D8,x   ;
STA $00     ; put the sprite's Y position
LDA !14D4,x ; into adjacent scratch RAM
STA $01     ;
REP #$20        ; set A to 16-bit mode
LDA $96     ;
SEC     ;
SBC $00     ;
CMP.w #$0000    ; I'm not exactly sure what the purpose of this is...
BPL NoIncYPos   ;
INC $96     ;
NoIncYPos:  ;
SEP #$20        ;

LDA #$00
JSR PlayerXOffsetRt ;

LDA !E4,x   ;
SEC     ;
SBC #$08        ; sprite X position - $08
CMP $94     ;
BEQ StartMoving ; if the player is at the sprite's X position, there is no need to offset his/her position
BPL XCheckPlus  ; if the result was positive, do another check with A = 01
LDA #$FF        ; if the result was positive, do another check with A = FF
BRA Check2  ;

XCheckPlus: ;
LDA #$01        ;
Check2:     ;
JSR PlayerXOffsetRt ;

StartMoving:
lda $18BE|!addr
sta !IsMoving,x
NoClearSFlag:   ;
RTS     ;

PlayerXOffsetRt:

LDY #$00        ; Y = 00
CMP #$00        ; check the position offset
BPL PlusOffset2 ; if it is negative...
DEY     ; Y = FF
PlusOffset2:    ;
CLC     ;
ADC $94     ; add the amount the sprite moved on the X-axis during the line-guide routine
STA $94     ; to the player's X position
TYA     ;
ADC $95     ; handle the high byte
STA $95     ;
RTS     ;

; Disassembly of $01A80F, using custom clipping for the sprite
MarioContact:
    lda $71
    cmp #$01
    bcs .ReturnNoContact
    lda #$00
    bit $0D9B|!Base2
    bvs +
    lda $13F9|!Base2
    eor !1632,x
+   bne .ReturnNoContact

; Custom sprite clipping
    lda #$FC
    sta $08
    lda #$FF
    sta $09
    lda #$10
    sta $0A
    stz $0B
    lda #$08
    sta $0C
    stz $0D

; Clipping height = !Length * $10 + $04
if !sa1
    stz $2250
    lda !Length,x
    sta $2251
    stz $2252
    lda #$10
    sta $2253
    stz $2254
    cmp ($00)
    rep #$20
    lda $2306
else
    lda !Length,x
    sta $4202
    lda #$10
    sta $4203
    nop #4
    rep #$20
    lda $4216
endif
    clc
    adc #$0004
    sta $0E
    sep #$20
    %SetPlayerClippingAlternate()
    %SetSpriteClippingAlternate()
    %CheckForContactAlternate()
    rts
.ReturnNoContact:
    clc
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineRopeGFX:
    %GetDrawInfo()
    sbc #$00    ; High byte of Y offset in B
    xba         ; (sbc #$00 because GetDrawInfo does "sbc #$0C" in 8-bit mode so we need to update the high bit too)
    lda $01     ; Low byte of Y offset in A
    rep #$20
    clc
    adc #$0008  ; Y offset + 8
    sta $05     ; $05-$06 = 16 bit Y position relative to the screen border
    sep #$20

    lda !15A0,x
    beq +
    lda !14E0,x
    xba
    lda !E4,x
    rep #$20
    sec
    sbc $1A
    cmp #$FFF0
    sep #$20
    bcs +
    jmp .return
+

LDA $00     ;
SEC         ;
SBC #$08    ; X offset - 8
STA $00     ;

STZ $04     ;

lda !15F6,x
sta $02

lda !Length,x ;\
inc           ;| $03 = tiles to draw - 1
sta $03       ;/

    lda !sprite_y_low,x
    sec
    sbc !YLoBackup,x
    bpl +
    eor #$FF
    inc
+   bit #$0F
    beq +
    clc
    adc #$10
+   lsr #4
    sta $59
    lda !CoverTiles,x
    bmi +
    sec
    sbc $59
    bpl ++
+   lda #$00
++  sta $59

LDY !15EA,x ; load the OAM index back into Y
LDX #$00        ; start X off at 00
stz $0F

.GFXLoop:
	rep #$20
	lda $05
	cmp #$FFF0
	bcs +
	lda $05
	bmi .SkipTile
	cmp #$00F0
	bcc +
	sep #$20
	bra .end
+	sep #$20
	cpx $59
	bcc .SkipTile
	sta $0301|!Base2,y
	inc $0F

LDA $00             ;
STA $0300|!Base2,y  ; no X displacement

lda #!RopeTile
STA $0302|!Base2,y  ; set the tile number

LDA $02
STA $0303|!Base2,y  ; set the tile properties

lda #$02
%FinishOAMWriteSingle()

INY #4      ; increment the OAM index

.SkipTile:
sep #$20
lda $05     ;\
clc         ;|
adc #$10    ;|
sta $05     ;| Set Y position of next tile.
lda $06     ;|
adc #$00    ;|
sta $06     ;/

INX          ; and the tilemap index
CPX $03      ; if we have reached our tile count...
BNE .GFXLoop ; break the loop

lda $0F
beq .end
LDA #!BottomRopeTile    ; set the tile number for the bottom of the rope
STA $02FE|!Base2,y      ;

.end
LDX $15E9|!Base2    ; sprite index back into X
.return
RTS     ;
