;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Line-Guided Rope (sprite 64), by imamelia
;;
;; This is a disassembly of sprite 64 in SMW, the line-guided rope.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Custom version by KevinM, v1.1
;;
;; Extra bit: if set, the rope will start moving once it spawns, instead of waiting for Mario.
;;
;; Extra byte 1: length of the rope, -1 (for example, $03 = 4 tiles rope)
;;   Note: using $FE crashes the game, using $FF causes glitched graphics. You'll never need values this huge anyway.
;;
;; Extra byte 2: speed multiplier, -1 ($00 = normal speed, $01 = double speed, etc.)
;;
;; Extra byte 3: additional settings. Format: osS-----
;;  o: if set, the rope won't despawn when offscreen.
;;     It could be useful for example for a vertical level with a very long rope at the top of it.
;;  s: if set, the rope never moves (this overrides the extra bit and the S bit settings)
;;  S: if set, the rope will stop when a switch is off, and move when it's on (or viceversa, see defines below)
;;  -: unused
;;
;; For more options see the defines below.
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

; SFX that plays when moving
!SFX            = $04   ; Change to $1A if using AddmusicK
                        ; Change to $00 to have no SFX
!SFXAddr        = $1DFA ; Change to $1DF9 if using AddmusicK

; The switch that controls the rope's movement.
; Only relevant if bit S in extra byte 3 is set.
!Switch         = $14AF ; $14AD = blue P-Switch
                        ; $14AE = silver P-Switch
                        ; $14AF = ON/OFF switch
!Reverse        = 0     ; 0 = rope will move when the !Switch is ON
                        ; 1 = rope will move when the !Switch is OFF

; Misc. graphics stuff
!RopeTile       = $CE
!BottomRopeTile = $DE
!MotorTileProp  = $37
!RopeTileProp   = $31

MotorTiles:
db $C0,$C2,$E0,$C2

SmokeXOffset:
db $F8,$00

!Inverted = 0
if !Switch == $14AF
    !Inverted = 1
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "INIT ",pc
PHB
PHK
PLB
JSR LineRopeInit
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LineRopeInit:
lda !extra_byte_1,x     ;\ Store rope length (-1)
sta !1510,x             ;/
INC !1540,x ;
lda !extra_byte_3,x
sta !1504,x
%BEC(+)
bit !1504,x
bvc ++
+
INC !1626,x
++
JSR LineRopeMain    ;
JSR LineRopeMain    ;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print "MAIN ",pc
PHB
PHK
PLB
JSR LineRopeMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LineRopeMain:
TXA     ;
ASL #2      ;
EOR $14     ;
STA $02     ; set the index for the smoke
AND #$07    ; every so many frames...
ORA $9D     ; if sprites are not locked...
BNE NoSmoke ; make smoke come from the sprite's motor

LDA $02         ;
LSR #3          ;
AND #$01        ; 2 possible X offsets for the smoke
TAY         ;
LDA SmokeXOffset,y  ; set the X displacement of the smoke
STA $00         ;
LDA #$F2            ; Y displacement = $F2
STA $01         ;

JSR MotorSmoke      ; show the smoke

NoSmoke:      ;
JSR LineRopeGFX ; draw the sprite

LDA !E4,x   ;
PHA     ; preserve the low bytes of the sprite's position
LDA !D8,x   ; (why not the high bytes?...)
PHA     ;

lda !1504,x
and #$20
beq ++
lda !Switch|!Base2
if !Inverted^!Reverse
    bne +
else
    beq +
endif
++
lda !extra_byte_2,x
-
pha
JSR LineGuideHandlerMainRt
pla
dec
bpl -

LDA $13     ;
AND #$07    ; every 8 frames...
ORA !1626,x ; if the sprite is moving...
ORA $9D     ; and sprites are not locked...
BNE NoSound ;
LDA #!SFX       ; play the ticking sound effect
STA !SFXAddr|!Base2 ;
NoSound:
+

PLA     ;
SEC     ;
SBC !D8,x   ;
EOR #$FF        ;
INC     ;
STA $185E|!Base2    ;
PLA     ;
SEC     ;
SBC !E4,x       ;
EOR #$FF        ;
INC     ;
STA $18B6|!Base2    ;

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
STZ !163E,x ; clear it
STZ $18BE|!Base2    ; and clear the climbing flag as well

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
+
stz !163E,x
stz $18BE|!Base2
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

STZ $18BE|!Base2    ; clear the climb flag
LDA #$10        ;
STA !154C,x ; and disable interaction for a few frames

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

LDA $18B6|!Base2    ; the amount the sprite moved on the X-axis during the line-guide routine
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

LDA !1626,x ;

StartMoving:

LDA !1626,x ; if the stationary flag is not already clear...
BEQ NoClearSFlag    ;
bit !1504,x         ;\ If stationary setting is set, skip.
bvs NoClearSFlag    ;/
STZ !1626,x ; clear it
STZ !1540,x ; as well as the move timer
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
    jsl $03B664|!BankB  ; Get Mario clipping
    stz $0C
    stz $0D

; Custom sprite clipping
    lda #$FC
    clc
    adc !E4,x
    sta $04
    lda !14E0,x
    adc #$FF
    sta $0A
    lda #$08
    sta $06
    stz $0E
    lda #$10
    clc
    adc !D8,x
    sta $05
    lda !14D4,x
    adc #$00
    sta $0B

; Clipping height = !extra_byte_1,x * $10 + $04
if !sa1
    stz $2250
    lda !extra_byte_1,x
    sta $2251
    stz $2252
    lda #$10
    sta $2253
    stz $2254
    cmp ($00)
    rep #$20
    lda $2306
else
    lda !extra_byte_1,x
    sta $4202
    lda #$10
    sta $4203
    nop #4
    rep #$20
    lda $4216
endif
    clc
    adc #$0004
    sep #$20
    sta $07
    xba
    sta $0F
    jsr CheckContact16
    rts
.ReturnNoContact:
    clc
    rts

;=================================================================;
; IMPROVED CONTACT DETECTION ROUTINE + 16 bit clipping dimensions ;
; adapted from a routine by Von Fahrenheit                        ;
;=================================================================;
; Clipping 1:
; $00,$08: Xpos
; $01,$09: Ypos
; $02,$0C: X Dimension
; $03,$0D: Y Dimension
; Clipping 2:
; $04,$0A: Xpos
; $05,$0B: Ypos
; $06,$0E: X Dimension
; $07,$0F: Y Dimension
;
; $45-$4A is used by the routine (as scratch ram)
;=================================================================;
CheckContact16:
    phx
    ldx #$01
-   lda $00,x : sta $45
    lda $08,x : sta $46
    lda $04,x : sta $47
    lda $0A,x : sta $48
    lda $06,x : sta $49
    lda $0E,x : sta $4A
    lda $0C,x : xba
    lda $02,x
    rep #$20
    clc : adc $45
    cmp $47
    bcc .Return
    lda $49
    clc : adc $47
    cmp $45
    bcc .Return
    sep #$20
    dex
    bpl -
    plx
    rts
.Return
    sep #$20
    plx
    rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; motor smoke subroutine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MotorSmoke:
LDA !15A0,x ; if the sprite is offscreen
ORA !186C,x ; in either direction...
BNE Return04    ; don't make smoke

LDY #$03        ; 4 indexes per smoke table

SmokeLoop:  ;

LDA $17C0|!Base2,y  ; if this slot is free...
BEQ FreeSmoke   ; use it
DEY     ; if not, check the next index
BPL SmokeLoop   ;
RTS

FreeSmoke:  ;

LDA #$03        ; set the type of smoke
STA $17C0|!Base2,y  ;
LDA !E4,x   ;
ADC $00     ; smoke X offset
STA $17C8|!Base2,y  ;
LDA !D8,x   ;
ADC $01     ; smoke Y offset
STA $17C4|!Base2,y  ;
LDA #$13        ; time to show smoke
STA $17CC|!Base2,y  ;

Return04:       ;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main line-guided sprite routine ($01D74D)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LineGuideHandlerMainRt:
lda !1504,x
bmi +
LDA #$01
%SubOffScreen()
+

LDA !1540,x ; if the move timer is set...
BNE RunStatePtr ; skip the next check
LDA $9D     ; if sprites are locked...
ORA !1626,x ; or the stationary flag is set...
BNE Return04    ; return

;==========================================================
; Run the different states with the vanilla routines
; - Easier
; - Uses less space
; - Includes line-guided fixes (like act as fix)
;==========================================================
RunStatePtr:    ;
	pea.w ($01)|(LineGuideHandlerMainRt>>16<<8)
	plb
	phk
	pea.w .jslrtsreturn-1
	pea.w $0180CA-1
	jml $01D75C|!BankB
.jslrtsreturn
	plb
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
sec
sbc #$0008  ; Y offset - 8
sta $05     ; $05-$06 = 16 bit Y position relative to the screen border
sep #$20

lda !15A0,x ;\
beq +       ;| Don't draw anything if horizontally offscreen.
rts         ;|
+           ;/

LDA $00     ;
SEC         ;
SBC #$08    ; X offset - 8
STA $00     ;

TXA         ;
ASL #2      ;
EOR $14     ;
LSR #3      ;
AND #$03    ;
STA $02     ; index to the motor tiles

STZ $04     ;

lda !1510,x ;\
inc #2      ;| $03 = tiles to draw - 1
sta $03     ;/

LDY !15EA,x ; load the OAM index back into Y
LDX #$00        ; start X off at 00   

GFXLoop:
LDA $00             ;
STA $0300|!Base2,y  ; no X displacement

rep #$20
lda $05
cmp #$00F0      ;\
bcc +           ;|
cmp #$FFF0      ;| Skip the tile if it's not on screen (vertically).
bcs +           ;|
sep #$20        ;|
bra SkipTile    ;/
+
sep #$20
++
sta $0301|!Base2,y

lda #!RopeTile
CPX #$00            ; if the tilemap index is 0...
BNE UseRopeTiles    ;
PHX
LDX $02             ;
LDA MotorTiles,x    ; then use the motor tilemap
PLX
UseRopeTiles:       ; else, use the rope tilemap
STA $0302|!Base2,y  ; set the tile number

LDA #!MotorTileProp ;
CPX #$01            ; if the tilemap index is 0...
BCC SetTileProp     ; use the tile properties of the motor
LDA #!RopeTileProp  ; else, use the tile properties of the rope
SetTileProp:        ;
STA $0303|!Base2,y  ; set the tile properties

jsr SetOAM460   ; Set tile size and X high position bit

INY #4      ; increment the OAM index

SkipTile:
lda $05     ;\
clc         ;|
adc #$10    ;|
sta $05     ;| Set Y position of next tile.
lda $06     ;|
adc #$00    ;|
sta $06     ;/

INX         ; and the tilemap index
CPX $03     ; if we have reached our tile count...
BNE GFXLoop ; break the loop

LDA #!BottomRopeTile    ; set the tile number for the bottom of the rope
STA $02FE|!Base2,y      ;

LDX $15E9|!Base2    ; sprite index back into X
RTS     ;

;===================================================
; Routine that handles the 2 bits in $0460,y
; Adapted from $01B7B3
;===================================================
SetOAM460:
    phx
    ldx $15E9|!Base2
    lda !E4,x
    sta $07
    sec
    sbc $1A
    sta $0B
    lda !14E0,x
    sta $08
    stz $0F
    lda $0300|!Base2,y
    sec
    sbc $0B
    bpl +
    dec $0F
+   clc
    adc $07
    sta $09
    lda $0F
    adc $08
    sta $0A
    phy                 ;\
    tya                 ;|
    lsr #2              ;| Tile size = 16x16
    tay                 ;|
    lda #$02            ;|
    sta $0460|!Base2,y  ;/
    rep #$20
    lda $09
    sec
    sbc $1A
    cmp #$0100
    sep #$20
    bcc +
    lda $0460|!Base2,y
    ora #$01
    sta $0460|!Base2,y
+   ply
    plx
    rts
