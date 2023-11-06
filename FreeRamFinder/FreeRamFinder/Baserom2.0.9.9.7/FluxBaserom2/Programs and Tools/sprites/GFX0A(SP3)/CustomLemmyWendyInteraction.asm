;-----------------------------------------------------------------------------------------
; Interaction routines
;-----------------------------------------------------------------------------------------

; GetMarioClipping: $03B664 (stores same location as clippingB)
; MarioSprInteract: $01A7DC
; SprSprInteract: $018032
; get fireball clipping routine $02A547 (B) (needs jslrts), pass exsprite number in Y

;----

; this will need to not call the std routine because we need to tweak our clipping values for upside down spawns first
; there are a few other checks besides just clipping, so look at that
if !BossMarioInteract || !DummyMarioInteract
MarioInteract:
  lda !RAM_DisableInter,x
  bne .Return                      ; return if interaction disable timer > 0

  jsl !GetMarioClipping            ; (B)
  jsl !CheckForContact
  bcs .Contact                      ; if no contact, return
.Return:
  rts

.Contact:
  lda #$08 : sta !RAM_DisableInter,x ; disable interactions for 8 frames
  lda !LWFlags,x : and.b #!FlagDirection
  beq +
  jmp .MarioLoses                    ; can't stomp when upside down
+:
  lda !RAM_MarioSpeedY
  cmp #$10                           ; if Mario is moving upwards (or down slowly enough), he loses
  bpl +
  jmp .MarioLoses
+:

  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy

.Boss:
  lda !RAM_IsSpinJump
  ora !RAM_OnYoshi
  bne .BossSpin

.BossJump:
  if !JumpBoss == 3 : bra .MarioLoses
  jsl !DisplayContactGfx
  jsl !BoostMarioSpeed
  lda #$02 : sta $1df9|!addr  ; contact
  if !JumpBoss == 1 || !JumpBoss == 2 : jsr Stomp : lda #$28 : sta $1dfc|!addr ; play hurt sound
  if !JumpBoss == 1 : jsr TakeDamage
  rts

.BossSpin:
  if !SpinBoss == 3 : bra .MarioLoses
  jsl !DisplayContactGfx
  jsl !BoostMarioSpeed
  lda #$02 : sta $1df9|!addr  ; contact
  if !SpinBoss == 1 || !SpinBoss == 2 : jsr Stomp : lda #$28 : sta $1dfc|!addr ; play hurt sound
  if !SpinBoss == 1 : jsr TakeDamage
  rts

.Dummy:
  lda !RAM_IsSpinJump
  ora !RAM_OnYoshi
  bne .DummySpin

.DummyJump:
  if !JumpDummy == 3 : bra .MarioLoses
  jsl !BoostMarioSpeed
  jsl !DisplayContactGfx
  if !JumpDummy == 2 : jsr Stomp
  if !JumpDummy == 2 || !JumpDummy == 0 : lda #$02 : sta $1df9|!addr  ; contact
  if !JumpDummy == 1 : jsr TakeDamage : lda #$13 : sta $1df9|!addr  ; enemy stomp 1
  rts

.DummySpin:
  if !SpinDummy == 3 : bra .MarioLoses
  jsl !DisplayContactGfx
  if !SpinDummy == 2 : jsr Stomp
  if !SpinDummy == 2 || !SpinDummy == 0 : jsl !BoostMarioSpeed : lda #$02 : sta $1df9|!addr  ; contact
  if !SpinDummy == 1
    lda #$04 : sta !RAM_SpriteStatus,x        ; set status to spin killed
    lda #$1f : sta !LWPhaseTimer,x            ; time for smoke cloud (which uses the same table as the phase timer, which we don't need anymore anyway)
    jsl $07FC3B                               ; show stars
    lda #$f8 : sta !RAM_MarioSpeedY
    lda #$08 : sta $1df9|!addr                ; spin kill sound...is the yoshi stomp really that different?
    lda !RAM_OnYoshi
    beq +
    jsl !BoostMarioSpeed
  +:
  endif
  rts

.MarioLoses:
  lda !RAM_OnYoshi
  bne +
  jsl !HurtMario
  rts
+:
  %LoseYoshi()
  rts
endif

;----

if !BossSpriteInteract || !DummySpriteInteract
SpriteInteract:
  ldy.b #!SprSize
.Loop:
  dey
  bmi .Return

  lda !RAM_SpriteNum,y
  cmp #$29
  beq .Loop                 ; if either the boss or dummy, ignore it

  lda !RAM_SpriteStatus,y
  cmp #$09
  bcc .Loop                 ; continue if status < $09
  cmp #$0c
  bcs .Loop                 ; or if status >= $0c

  tyx
  jsl !GetSpriteClippingB
  ldx $15e9|!addr           ; restore our sprite index
  jsl !CheckForContact
  bcc .Loop                 ; no contact, continue

  lda !RAM_SpriteYLo,y : sta $98
  lda !RAM_SpriteYHi,y : sta $99
  lda !RAM_SpriteXLo,y : sta $9a
  lda !RAM_SpriteXHi,y : sta $9b         ; hope these are right...should check for larger levels, vertical levels, etc
  
  phb
  lda #$02 : pha : plb                 ; apparently the DBR needs to be set to $02 manually for this
  lda #$01                             ; flashing palette
  phy                                  ; it also clobbers y
  jsl !ShatterBlock
  ply                                  ; restore y
  plb                                  ; restore DBR
  lda #$00 : sta !RAM_SpriteStatus,y   ; erase the sprite

  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy
.Boss:
  if !SpriteBoss == 1 || !SpriteBoss == 2 : jsr Stomp : lda #$28 : sta $1dfc|!addr ; hurt sound
  if !SpriteBoss == 1 : jsr TakeDamage
  rts

.Dummy:
  if !SpriteDummy == 2 : jsr Stomp : lda #$02 : sta $1df9|!addr  ; contact
  if !SpriteDummy == 1 : jsr TakeDamage : lda #$13 : sta $1df9|!addr  ; enemy stomp 1

.Return:
  rts
endif

;----

if !BossFireballInteract || !DummyFireballInteract
FireballInteract:
  ldy #$09

.Loop:
  lda !extended_num,y
  cmp #$05
  beq .Check               ; player fireball
  cmp #$11
  bne .Continue            ; yoshi fireball

.Check:
  %jslrts($02A547)         ; get fireball clipping routine (B)
  jsl !CheckForContact
  bcc .Continue            ; no contact, continue

  lda !extended_num,y
  cmp #$11
  beq +                            ; skip turning into smoke for Yoshi fireball
  lda #$01 : sta !extended_num,y   ; contact, turn into smoke puff
  lda #$0f : sta !extended_timer,y ; for this much time

+:
  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy
.Boss:
  if !FireballBoss == 1 || !FireballBoss == 2 : jsr Stomp : lda #$02 : sta $1df9|!addr  ; contact (maybe hurt instead?)
  if !FireballBoss == 1 : jsr TakeDamage
  if !FireballBoss == 0
    cpy #$05
    bne +
    lda #$01 : sta $1df9|!addr  ; thud sound for player fireball only
    +:
  endif
  rts
  bra .Continue

.Dummy:
  if !FireballDummy == 1 : jsr TakeDamage : lda #$03 : sta $1df9|!addr   ; kick sound
  if !FireballDummy == 2 : jsr Stomp : lda #$02 : sta $1df9|!addr  ; contact
  if !FireballDummy == 0
    cpy #$05
    bne +
    lda #$01 : sta $1df9|!addr  ; thud sound for player fireball only
    +:
  endif
  rts

.Continue:
  dey
  if not(!YoshiFireballs)
    cpy #$08
  endif
  bpl .Loop              ; if Yoshi fireballs are checked for, return after all slots, otherwise just check the top 2

.Return:
  rts
endif

;----

; this calls the ClippingA routine and then adjusts for upside down spawn
; y result is the sprite y coord + offset
; clipping rect normally at y + yoff with height ht (so y + yoff to y + yoff + ht - 1)
; upside down should have y - yoff as the bottom, so y - yoff - ht + 1
; need to get the offset from the clipping table and not hardcode it -- FIX
; could also just do this manually

; add (y - yoff - ht + 1) - (y + yoff) = -2yoff -ht + 1
; = sub 2yoff + ht - 1 = -(2yoff + ht) + 1

;-----------------------------------------------
; Get clipping (A)
;   Calls the base version, then adjusts the top coordinate for an upside down spawn
;   Left edge = $04/$0A (low/high)
;   Width     = $06
;   Top       = $05/$0B (low/high)
;   Height    = $07
;-----------------------------------------------

GetClipping:
  phy
  jsl !GetSpriteClippingA

  lda !LWFlags,x : and.b #!FlagDirection
  beq .Return            ; normal spawn point, return

  lda !1662,x
  and #$3f               ; sprite clipping value
  tax
  lda $03B5E4,x          ; vertical clipping offset
  asl                    ; 2 * offset
  clc : adc $07
  dec                    ; 2 * offset + ht - 1
  sta $0f
  stz $0e                ; extend $0f to 16 bits
  bpl +
  dec $0e
+:

  lda $05
  sec : sbc $0f          ; and subtract adjustment to the original value
  sta $05
  lda $0b
  sbc $0e
  sta $0b

  ldx $15e9|!addr

.Return:
  ply
  rts

;-----------------------------------------------
; Set the stomped state and animation
;-----------------------------------------------

Stomp:
  lda #$02 : sta $1DF9|!addr      ; play sound effect
  lda #$04 : sta !LWPhase,x       ; set phase 4 (stomped)
  stz !LWFrameCounter,x           ; reset frame counter
  lda !LWFlags,x : and.b #!FlagDummy
  bne +

  lda.b #!TimeStompedBoss : sta !LWPhaseTimer,x  ; set stomped timer
  lda.b #!NumBossAnimations+!NumDummyAnimations : sta !LWAnimation,x       ; animation for hurt boss, unpaused
  lda !LWRemainingHP,x
  eor #$ff : inc
  sta !LWRemainingHP,x                                                   ; negate hp to indicate that no damage was done (kind of a gross solution, but whatever)
  rts

+:
  lda.b #!TimeStompedDummy : sta !LWPhaseTimer,x  ; set stomped timer
  lda.b #!NumBossAnimations+!NumDummyAnimations+1 : sta !LWAnimation,x     ; animation for hurt dummy, unpaused
  rts

;-----------------------------------------------
; Take damage from either Mario or a sprite
;-----------------------------------------------

TakeDamage:
  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy                          ; if the stomped sprite was a dummy, branch

  lda !LWRemainingHP,x
  eor #$ff
  sta !LWRemainingHP,x            ; damage actually done, so negate and decrement
  bne .Return
  if !KillSprites == 1
    jsr KillMostSprites                       ; if now at 0 hp, erase other sprites
  endif
  if !TilesToChange > 0 : jsr ChangeTiles   ; and change tiles if configured
  rts

.Dummy:
  lda #3 : sta !LWPhase,x                   ; retreat!
  lda.b #!TimeRetreat : sta !LWPhaseTimer,x

.Return:
  rts
