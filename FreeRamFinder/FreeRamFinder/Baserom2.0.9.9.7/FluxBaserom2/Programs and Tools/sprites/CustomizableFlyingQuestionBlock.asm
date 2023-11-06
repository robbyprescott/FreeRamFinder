;===============================================================================;
; Flying Question Block customizable disassembly                                ;
; by KevinM                                                                     ;
;                                                                               ;
; Extra bit: if clear, it'll spawn a powerup or a coin (vanilla behavior).      ;
;   If set, it'll spawn a sprite (see extra bytes).                             ;
;                                                                               ;
; Extra byte 1: controls the movement pattern.                                  ;
;   - 00: always go left.                                                       ;
;   - 01: always go right.                                                      ;
;   - 02: go left first, then right, etc.                                       ;
;   - 03: go right first, then left, etc.                                       ;
;   - 04 or 05: go towards Mario, and keep the same direction.                  ;
;   - 06 or 07: go towards Mario, and then go back and forth.                   ;
;                                                                               ;
; Extra byte 2: if the extra bit is set, it's the sprite number to spawn.       ;
;   If the extra bit is clear, it sets what powerup will spawn (instead of      ;
;   depending on the X position):                                               ;
;   - 00: coin.                                                                 :
;   - 01: flower (mushroom if Mario is small).                                  ;
;   - 02: cape (mushroom if Mario is small).                                    ;
;   - 03: 1-Up mushroom.                                                        ;
;   - 04: mushroom.                                                             ;
;   - 05: star.                                                                 ;
;   - 06: green Yoshi egg.                                                      ;
;   - 07: green Koopa shell (with Koopa inside).                                ;
;   - 08: changing item.                                                        ;
;                                                                               ;
; Extra byte 3: this controls additional settings. Bitwise format: cXBFS--C     ;
;   c: if set, the sprite will spawn in the carryable state (use this to        ;
;        spawn shells, using the Koopas sprite number, or Throw Blocks using    ;
;        sprite number $53).                                                    ;
;   X: if set, the block disappears when hit.                                   ;
;   B: if set, stepping on the block after it's hit will trigger block snakes.  ;
;   F: if set, the block will trigger when hit by spinning the cape.            ;
;   S: if set, the block will act solid for the sprite it spawns (this can look ;
;      a bit janky for sprites that walk around).                               ;
;   -: unused.                                                                  ;
;   C: 0 = spawn normal sprite, 1 = spawn custom sprite.                        ;
;                                                                               ;
; Extra byte 4: Y speed of the spawned sprite (when the extra bit is set).      ;
;                                                                               ;
; Other parameters can be set with the defines below.                           ;
;===============================================================================;

;===================================;
; Defines of general properties     ;
; Feel free to edit these.          ;
;===================================;
!XAcceleration    = $01
!YAcceleration    = $01
!MaxXSpeed        = $10   ; Max X speed before turning back.
!MaxYSpeed        = $0C
!XSpeedUpdateFreq = $03   ;\ These control how often the acceleration gets applied. Lower = more frequently.
!YSpeedUpdateFreq = $01   ;/ Valid values: $00,$01,$03,$07,$0F,$1F,$3F,$7F,$FF.
                          ; For example, bigger YFreq values will result in "higher" sine wave patterns.
!MaxXSpeedTimer   = $20   ; How much to fly at max speed before turning back.
!ConstantXSpeed   = $0C   ; X speed when the sprite is set to never change direction.

!NormalTile       = $2A
!HitTile          = $2E
!DrawWings        = 1     ; 0 = no wings.

!NoMarioContact   = $10   ; How many frames to disable contact with Mario for the spawned item (when the extra bit is set).
!NoSpriteContact  = $20

;====================================================;
; Sprite code                                        ;
; Don't edit this unless you know what you're doing! ;
;====================================================;
!addr = !Base2
!bank = !BankB

;===================================;
; Init routine                      ;
;===================================;
print "INIT ",pc
    lda !extra_byte_1,x     ;\ If the "face Mario" bit is set
    and #$04                ;|
    beq +                   ;|
    %SubHorzPos()           ;| set initial direction based on his relative position.
    tya                     ;|
    eor #$01                ;|
    bra ++                  ;/
+   lda !extra_byte_1,x     ;\ Set initial direction.
    and #$01                ;|
++  sta !1534,x             ;/
    lda !extra_byte_1,x     ;\ Set movement pattern.
    and #$02                ;|
    sta !1504,x             ;/
    lda !extra_byte_3,x     ;\ Store extra settings to absolute address.
    sta !1510,x             ;/
    lda #$FF                ;\ Set spawned sprite slot to $FF (inexistent).
    sta !160E,x             ;/
    rtl

;===================================;
; Main routine                      ;
;===================================;
print "MAIN ",pc
    bit !1510,x             ;\ If the "block disappears after being hit" flag is set
    bvc +                   ;|
    lda !C2,x               ;| and the block is in the hit state
    cmp #$02                ;|
    bcc +                   ;|
    lda !1558,x             ;| and the block finished the bouncing animation
    bne +                   ;|
    lda #$1F                ;| kill the block.
    sta !1540,x             ;|
    lda #$04                ;|
    sta !14C8,x             ;/
+   phb
    phk
    plb
    jsr Main
    plb
    rtl

XAcceleration:
    db -!XAcceleration,!XAcceleration
YAcceleration:
    db -!YAcceleration,!YAcceleration
MaxXSpeed:
    db -!MaxXSpeed,!MaxXSpeed
MaxYSpeed:
    db -!MaxYSpeed,!MaxYSpeed
ConstantXSpeed:
    db -!ConstantXSpeed,!ConstantXSpeed

Main:
    lda !163E,x             ;\ If spawning sprite from the block,
    beq +                   ;/
    stz !15EA,x             ;\ set OAM index to $00
    lda $187A|!addr         ;|
    bne +                   ;|
    lda #$04                ;| or $04 if on Yoshi.
    sta !15EA,x             ;/
+   jsr Graphics            ; Draw graphics.
    ldy !15EA,x             ;\ Shift the sprite one pixel up.
    lda $0301|!addr,y       ;|
    dec                     ;|
    sta $0301|!addr,y       ;/
    stz !1528,x
    lda !C2,x               ;\ Don't move or draw wings if the block has been hit.
    beq +                   ;/
    jmp Interact
+
if !DrawWings
    pea.w $01|(Main>>16<<8) ;\ Draw wings.
    plb                     ;|
    phk                     ;|
    pea.w .WingsRet-1       ;|
    pea.w $0180CA-1         ;|
    jml $019E95|!bank       ;/
.WingsRet
    plb
endif
    lda $9D                 ;\ Skip if sprites are frozen.
    beq CheckCape           ;|
    jmp Interact            ;/

CheckCape:
    lda !1510,x             ;\ If the "trigger with cape" flag is set
    and #$10                ;|
    beq +                   ;|
    jsr CapeContact         ;| and there's contact with the cape
    bcc +                   ;|
    lda #$10                ;| trigger the block.
    sta !1558,x             ;|
    inc !C2,x               ;/
+

YMovement:
if !YSpeedUpdateFreq != $00
    lda $14                 ;\ Change speed every other frame.
    and #!YSpeedUpdateFreq  ;|
    bne +                   ;/
endif
    lda !1594,x             ;\ Handle Y acceleration.
    and #$01                ;|
    tay                     ;|
    lda !AA,x               ;|
    clc                     ;|
    adc YAcceleration,y     ;|
    sta !AA,x               ;|
    cmp MaxYSpeed,y         ;|
    bne +                   ;|
    inc !1594,x             ;/
+   jsl $01801A|!bank       ; Update Y position without gravity.

XMovement:
    lda !1504,x
    beq ConstantSpeed
    lda !1540,x             ;\ Skip for a short time when at max speed.
    bne +                   ;/
if !XSpeedUpdateFreq != $00
    lda $14                 ;\ Change speed every 4 frames.
    and #!XSpeedUpdateFreq  ;|
    bne +                   ;/
endif
    lda !1534,x             ;\ Handle X acceleration.
    and #$01                ;|
    tay                     ;|
    lda !B6,x               ;|
    clc                     ;|
    adc XAcceleration,y     ;|
    sta !B6,x               ;|
    cmp MaxXSpeed,y         ;|
    bne +                   ;|
    inc !1534,x             ;/
    lda #!MaxXSpeedTimer    ;\ How long to fly at max speed for.
    sta !1540,x             ;/
+   bra ++

ConstantSpeed:
    ldy !1534,x             ;\ Set constant speed based on direction.
    lda ConstantXSpeed,y    ;|
    sta !B6,x               ;/
++  jsl $018022|!bank       ; Update X position without gravity.
    lda $1491|!addr         ;\ Preserve how many pixels the block has moved.
    sta !1528,x             ;/
    inc !1570,x             ; Increase animation timer.

Interact:
+   jsl $018032|!bank       ; Interact with sprites (handles items thrown at it).
    jsl $01B44F|!bank       ; Make the sprite solid (also handles Mario hitting it from below).
    bcc +                   ;\ If Mario is standing on the block
    lda !1510,x             ;| and the "snake block" setting is set
    and #$20                ;|
    beq +                   ;|
    lda !C2,x               ;|
    cmp #$02                ;| and the block has been hit
    bcc +                   ;|
    stz $1909|!addr         ;/ trigger snake blocks.
+   lda #$00                ;\ Process offscreen.
    %SubOffScreen()         ;/
.MakeSolid
    lda !1510,x             ;\ Skip if the block shouldn't be solid for the spawned sprite.
    and #$08                ;|
    beq +                   ;/
    ldy !160E,x             ;\ Skip if no sprite spawned from the block.
    cpy #$FF                ;|
    beq +                   ;/
    lda !14C8,y             ;\ Skip if the sprite isn't alive.
    cmp #$08                ;|
    bcc +                   ;/
    lda !1686,y             ;\ Skip if the sprite doesn't interact with objects.
    bmi +                   ;/
    jsr MakeSolidForSprite  ; Make the block solid for the spawned sprite.
+   lda !1558,x             ;\ Branch if not halfway through the hit animation.
    cmp #$08                ;|
    bne +                   ;/
.SpawnItem
    pha
    inc !C2,x               ; Change sprite state.
    lda #$50                ;\ Set sprite spawn timer.
    sta !163E,x             ;/
    lda #$FF                ;\ Prevent the block from respawning.
    sta !161A,x             ;/
    %BEC(++)                ;\ Spawn sprite.
    jsr SpawnSpriteCustom   ;|
    bra +++                 ;|
++  jsr SpawnSpriteVanilla  ;/
+++ pla
+   lsr                     ;\ Handle bounce animation.
    tay                     ;|
    lda .BounceYOffset,y    ;|
    sta $00                 ;|
    ldy !15EA,x             ;|
    lda $0301|!addr,y       ;|
    sec                     ;|
    sbc $00                 ;|
    sta $0301|!addr,y       ;/
    rts

.BounceYOffset:
    db $00,$03,$05,$07,$08,$08,$07,$05,$03

;===============================================================;
; CapeContact routine (stolen from GIEPY)                       ;
; Checks for contact between the spinning cape and the sprite.  ;
; If the carry is set, they're in contact.                      ;
;===============================================================;
CapeContact:
    lda $13E8|!addr         ;\ If the cape is not spinning, return.
    beq .NoContact          ;/
    lda !15D0,x             ;\ If the sprite can't contact the cape, return.
    ora !154C,x             ;|
    ora !1FE2,x             ;|
    bne .NoContact          ;/
    lda !1632,x             ;\ If the player and the sprite are on different sides of the net, return.
    phy                     ;|
    ldy $74                 ;|
    beq +                   ;|
    eor #$01                ;|
+   ply                     ;|
    eor $13F9|!addr         ;|
    bne .NoContact          ;/
    jsl $03B69F|!bank       ; Get the clipping of the sprite.
    lda $13E9|!addr         ;\ Get the clipping of the cape.
    sec                     ;|
    sbc #$02                ;|
    sta $00                 ;|
    lda $13EA|!addr         ;|
    sbc #$00                ;|
    sta $08                 ;|
    lda #$14                ;|
    sta $02                 ;|
    lda $13EB|!addr         ;|
    sta $01                 ;|
    lda $13EC|!addr         ;|
    sta $09                 ;|
    lda #$10                ;|
    sta $03                 ;/
    jsl $03B72B|!bank       ; Check for contact with the cape.
    rts
.NoContact
    clc
    rts

;===================================================;
; SpawnSpriteVanilla routine                        ;
; This is the routine used by the original sprite.  ;
;===================================================;
SpawnSpriteVanilla:
    lda !E4,x               ;\ Set the sprite to spawn at the block's position.
    sta $9A                 ;|
    lda !14E0,x             ;|
    sta $9B                 ;|
    lda !D8,x               ;|
    sta $98                 ;|
    lda !14D4,x             ;|
    sta $99                 ;/
    lda !extra_byte_2,x     ;\ Get index of sprite to spawn.
    tay                     ;/
    lda $19                 ;\ If Mario doesn't have a powerup, increase index by 9.
    bne +                   ;|
    tya                     ;|
    clc                     ;|
    adc #$09                ;|
    tay                     ;/
+   lda .SpriteIndex,y      ;\ Get index for the sprite to spawn.
    sta $05                 ;/
    phb
    lda #$02                ;\ Spawn the sprite.
    pha                     ;|
    plb                     ;|
    phx                     ;|
    jsl $02887D|!bank       ;|
    plx                     ;/
    lda $185E|!addr         ;\ Get spawned sprite's index.
    sta !160E,x             ;|
    tay                     ;/
    lda #$01                ;\ Prevent it from appearing behind FG objects while rising.
    sta !1528,y             ;/
    lda.w !9E,y             ;\ If Fire Flower, set it to stay still on top of the sprite.
    cmp #$75                ;|
    bne +                   ;|
    lda #$FF                ;|
    sta.w !C2,y             ;/
+   plb
    rts

.SpriteIndex:
    db $06,$02,$04,$05,$01,$03,$0C,$0D,$0E  ; Items when big Mario.
    db $06,$01,$01,$05,$01,$03,$0C,$0D,$0E  ; Items when small Mario.

;================================================;
; SpawnSpriteCustom routine                      ;
; This routine spawns any sprite from the block. ;
;================================================;
SpawnSpriteCustom:
    stz $00
    stz $01
    stz $02
    stz $03
    lda !1510,x
    lsr
    lda !extra_byte_2,x
    %SpawnSprite()
    bcs .Return
    tya                     ;\ Save sprite slot.
    sta !160E,x             ;/
    phx                     ;\ Set Y offset.
    lda !1656,y             ;|
    and #$0F                ;|
    tax                     ;|
    lda YOffset,x           ;|
    sec                     ;|
    sbc #$08                ;|
    sta $00                 ;|
    plx                     ;|
    lda.w !D8,y             ;|
    sec                     ;|
    sbc $00                 ;|
    sta.w !D8,y             ;|
    lda !14D4,y             ;|
    sbc #$00                ;|
    sta !14D4,y             ;/
    lda !extra_byte_4,x     ;\ Set Y speed.
    sta.w !AA,y             ;/
    lda #$00                ;\ Set X speed.
    sta.w !B6,y             ;/
    lda #!NoMarioContact    ;\ Set timer to disable contact with Mario.
    sta !154C,y             ;/
    lda.w !9E,y             ;\ Skip for Yoshi because it's the swallow timer.
    cmp #$35                ;|
    bne +                   ;|
    lda !1510,x             ;|
    lsr                     ;|
    bcc ++                  ;/
+   lda #!NoSpriteContact   ;\ Set timer to disable contact with sprites.
    sta !1564,y             ;/
++  lda #$02                ;\ Play sfx.
    sta $1DFC|!addr         ;/
    lda !1510,x             ;\ Set state as "carryable" if flag is set.
    bpl .Return             ;|
    lda #$09                ;|
    sta !14C8,y             ;/
.Return
    rts

;========================================================;
; MakeSolidForSprite routine                             ;
; Makes the block act as solid for the sprite slot in Y. ;
; Adapted from the routine at $01B44F.                   ;
;========================================================;
MakeSolidForSprite:
    phx                     ;\ If the sprites are not touching, return.
    tyx                     ;|
    jsl $03B6E5|!bank       ;|
    plx                     ;|
    jsl $03B69F|!bank       ;|
    jsl $03B72B|!bank       ;|
    bcc .ReturnAndReset     ;/
    lda.w !AA,y             ;\ Return if the sprite is moving up
    bmi .Return             ;|
    lda !1588,y             ;| or is being pushed down by an object.
    and #$08                ;|
    bne .Return             ;/
    phx
    lda !1656,y             ;\ Get Y offset from the block based on the sprite's object clipping.
    and #$0F                ;|
    tax                     ;|
    lda YOffset,x           ;|
    sta $00                 ;/
    plx
    lda !D8,x               ;\ Set Y position of the sprite.
    sec                     ;|
    sbc $00                 ;|
    sta.w !D8,y             ;|
    lda !14D4,x             ;|
    sbc #$00                ;|
    sta !14D4,y             ;/
    lda !1588,y             ;\ Set sprite as blocked from below.
    ora #$04                ;|
    sta !1588,y             ;/
    lda #$10                ;\ Y speed while being on top of the block.
    sta.w !AA,y             ;/
.Return
    rts

.ReturnAndReset
    lda !163E,x             ;\ If finished spawning sprite
    bne +                   ;|
    lda #$FF                ;| set spawned sprite as inexistent.
    sta !160E,x             ;/
+   rts

YOffset:
    db $10,$20,$07,$20,$20,$20,$08,$1F
    db $0F,$10,$50,$08,$00,$10,$10,$04

;===================================;
; Graphics routine                  ;
;===================================;
Graphics:
    %GetDrawInfo()
    lda $00                 ;\ Set tile position.
    sta $0300|!addr,y       ;|
    lda $01                 ;|
    sta $0301|!addr,y       ;/
    lda !C2,x               ;\ Set tile.
    cmp #$01                ;|
    lda #!NormalTile        ;| Cf. $01AE7A
    bcc +                   ;|
    lda #!HitTile           ;| Cf. $01AE76
+   sta $0302|!addr,y       ;/
    lda !15F6,x             ;\ Set tile properties.
    ora $64                 ;|
    sta $0303|!addr,y       ;/
    tya                     ;\ Set tile size.
    lsr #2                  ;|
    tay                     ;|
    lda #$02                ;|
    ora !15A0,x             ;|
    sta $0460|!addr,y       ;|
    sta $0461|!addr,y       ;/
    phk                     ;\ Handles graphics when the block is (partially) offscreen.
    pea.w .Return-1         ;|
    pea.w $0180CA-1         ;|
    jml $01A3DF|!bank       ;/
.Return
    rts
