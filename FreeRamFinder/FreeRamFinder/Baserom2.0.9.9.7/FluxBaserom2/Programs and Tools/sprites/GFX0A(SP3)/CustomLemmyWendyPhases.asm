;-----------------------------------------------------------------------------------------
; phase 0 - hiding
;-----------------------------------------------------------------------------------------

; Note: only the boss is ever in phase 0, not the dummies
Phase0:
  if !ManualCycles == 0
    lda !LWPhaseTimer,x                   ; if time's not up, return
    bne .Return
  else
    lda !LWCycle,x                        ; if the timer hasn't reached the value for the current cycle, return
    asl
    tay
    lda EmergeTimes,y
    cmp !LWTimeLo,x
    bne .Return
    lda EmergeTimes+1,y
    cmp !LWTimeHi,x
    bne .Return
  endif

  jsr NewSpawnPoint

  lda.b #!NumBossAnimations-1
  jsr GetRandRange                      ; random animation type
  sta !LWAnimation,x                    ; store it
  tay                                   ; use it to determine time to rise during next action
  lda TimeEmerge,y : sta !LWPhaseTimer,x
  stz !LWFrameCounter,x                 ; reset frame counter
  lda !LWFlags,x
  ora.b #!FlagPaused
  sta !LWFlags,x                        ; pause it
  inc !LWPhase,x                        ; set phase 1
 
.Return:
  rts

; clobbers $00-$05, $0e, $0f, y
NewSpawnPoint:
  lda.b #!PatternsPerCycle-1
  jsr GetRandRange                                ; choose a pattern for the current cycle
  clc : adc !LWLocationOffset,x
  sta $0e                                         ; this gives the offset into the boss spawn table and each dummy table
  tay
  lda BossSpawnLocations,y                        ; the spawn point for this cycle that has been selected
  sta $0d                                         ; stash it
  cmp #$ff
  beq .NoBoss                                     ; spawn point $ff means the boss doesn't spawn

  asl                                             ; 16-bit values to look up
  tay
  lda SpawnPointX,y : sta !RAM_SpriteXLo,x
  lda SpawnPointY,y : sta !RAM_SpriteYLo,x
  lda SpawnPointX+1,y : sta !RAM_SpriteXHi,x
  lda SpawnPointY+1,y : sta !RAM_SpriteYHi,x
  ldy $0d                                        ; spawn point
  lda SpawnPointDir,y
  beq +
  lda !LWFlags,x
  ora.b #!FlagDirection
  sta !LWFlags,x                                 ; set upside down flag if this spawn point is upside down
  bra .SpawnDummies
+:
  lda !LWFlags,x
  and.b #~!FlagDirection
  sta !LWFlags,x                                 ; otherwise clear it
  bra .SpawnDummies

.NoBoss:
  lda #$40
  sta !RAM_SpriteXHi,x
  sta !RAM_SpriteYHi,x                          ; $40xx, $40xx is wayyy offscreen...the boss logic will still run, but there's no interaction and nothing will render

.SpawnDummies:
  lda.b #!MaxDummies : sta $0f      ; loop counter
.Loop:
  lda $0f
  beq .Return
  
  ldy $0e
  lda DummySpawnLocations,y
  cmp #$ff
  beq .Continue                                  ; location -1 means this pattern doesn't use this dummy
  jsr SpawnDummy
  bcs .Return                                    ; spawn failed, so just bail out of the rest

.Continue:
  dec $0f
  lda $0e
  clc : adc.b #!NumPatterns                      ; same relative offset into the next dummy table
  sta $0e
  jmp .Loop

.Return
  rts

; the vanilla version forces the dummies into slots 0 and 1 always
; using pixi's spawn routine doesn't do this, and runs into tile limit issues
; can spawnsafe with an appropriate max (up to 7 seems to work...8 works for the dummies, but corrupts mario a little...9 is
; totally broken)
; in fact, setting OE seems to allow slots 0-8, except for that little hiccup with mario's sprite corruption
; so for now, just going to make a define for the max slot and can look into the tile limit patch later

; pass spawn point index in A
; clobbers $00-$05, y
; returns carry bit clear if spawn successful, carry bit set if spawn failed
SpawnDummy:
  sta $05                                         ; stash spawn point
  stz $02
  stz $03
  lda.b #!MaxDummySlot : sta $04                  ; see above
  lda !new_sprite_num,x
  sec
  %SpawnSpriteSafe()
  bcs .Return                                     ; spawn failed

+:
  lda #$00
  sta !RAM_OffscreenHorz,y
  sta !RAM_OffscreenVert,y
  lda #$08 : sta !RAM_SpriteStatus,y              ; bypass init for spawned dummy
  lda.b #!FlagDummy|!FlagPaused : sta !LWFlags,y  ; set dummy and pause animation frame counter
  lda !LWKid,x : sta !LWKid,y                     ; are we Lemmy or Wendy? Does it even matter?
  lda !1662,x : sta !1662,y                       ; copy the clipping value to the dummy (other two bits here are ignored)
  lda.b #!NumDummyAnimations-1
  jsr GetRandRange
  clc : adc.b #!NumBossAnimations                 ; dummy animations are immediately after the boss ones
  sta !LWAnimation,y
  tax
  lda TimeEmerge,x : sta !LWPhaseTimer,y
  lda #1 : sta !LWPhase,y                         ; set phase 1
  lda #$00 : sta !LWFrameCounter,y                ; reset frame counter

  lda $05                                         ; the spawn point from earlier
  asl
  tax
  lda SpawnPointX,x : sta !RAM_SpriteXLo,y
  lda SpawnPointY,x : sta !RAM_SpriteYLo,y
  lda SpawnPointX+1,x : sta !RAM_SpriteXHi,y
  lda SpawnPointY+1,x : sta !RAM_SpriteYHi,y

  ldx $05                                        ; spawn point
  lda SpawnPointDir,x
  beq +
  lda !LWFlags,y
  ora.b #!FlagDirection
  sta !LWFlags,y                                 ; set upside down flag if this spawn point is upside down
+:
  ldx $15e9|!addr                                ; restore clobbered x
  clc                                            ; c clear = spawn succeeded
.Return:
  rts

;-----------------------------------------------------------------------------------------
; phase 1 - emerging
;-----------------------------------------------------------------------------------------

Phase1:
  lda !LWFlags,x : and.b #!FlagDirection
  bne +
  lda.b #-!EmergeSpeed                ; emerge speed (for normal spawns, movement is upward, so make negative)
  bra ++
+:
  lda.b #!EmergeSpeed                 ; or leave positive for upside down spawns
++:
  sta !RAM_SpriteSpeedY,x             ; set it
  jsl $01801A                         ; and update sprite y position

  lda !LWPhaseTimer,x                 ; if time's not up, return
  bne .Return
  lda.b #!TimeVulnerable : sta !LWPhaseTimer,x      ; set time to wait at top of pipe
  lda !LWFlags,x
  and.b #~!FlagPaused
  sta !LWFlags,x                      ; unpause animation counter
  inc !LWPhase,x                      ; set phase 2
.Return:
  rts

;-----------------------------------------------------------------------------------------
; phase 2 - vulernable
;-----------------------------------------------------------------------------------------

Phase2:
  jsr GetClipping                 ; (A), this only needs to be done once and is used by all the various interaction routines
  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy                      ; separate checks for dummy

  ; after each interaction, bail out if our phase was changed

  if !BossMarioInteract : jsr MarioInteract : lda !LWPhase,x : cmp #2 : bne .Return
  if !BossSpriteInteract : jsr SpriteInteract : lda !LWPhase,x : cmp #2 : bne .Return
  if !BossFireballInteract : jsr FireballInteract : lda !LWPhase,x : cmp #2 : bne .Return
  bra .Continue

.Dummy:
  if !DummyMarioInteract : jsr MarioInteract : lda !LWPhase,x : cmp #2 : bne .Return
  if !DummySpriteInteract : jsr SpriteInteract : lda !LWPhase,x : cmp #2 : bne .Return
  if !DummyFireballInteract : jsr FireballInteract : lda !LWPhase,x : cmp #2 : bne .Return

.Continue:
  lda !LWPhaseTimer,x             ; if time's not up, return
  bne .Return

  lda.b #!TimeRetreat : sta !LWPhaseTimer,x  ; set time to retreat
  lda !LWFlags,x
  ora.b #!FlagPaused
  sta !LWFlags,x                  ; pause animation counter
  inc !LWPhase,x                  ; set phase 3
.Return:
  rts

;-----------------------------------------------------------------------------------------
; phase 3 - retreating
;-----------------------------------------------------------------------------------------

Phase3:
  lda !LWFlags,x : and.b #!FlagDirection
  bne +
  lda.b #!RetreatSpeed               ; normally downward movement, so keep positive
  bra ++
+:
  lda.b #-!RetreatSpeed              ; negative if spawn point is upside down
++:
  sta !RAM_SpriteSpeedY,x            ; set it
  jsl $01801A                        ; update sprite y position

  lda !LWPhaseTimer,x                ; if time's not up, return
  bne .Return

  lda !LWFlags,x : and.b #!FlagDummy
  beq +
  stz !RAM_SpriteStatus,x                    ; if dummy, erase sprite and return
  rts

+:
  lda !LWLocationOffset,x
  clc : adc.b #!PatternsPerCycle
  sta !LWLocationOffset,x                    ; updated offset into the spawn tables for the next cycle

  inc !LWCycle,x                             ; cycle counter
  lda !LWCycle,x
  cmp.b #!NumCycles
  bne .ToPhase0                              ; skip if there are still cycles remaining

  if !RepeatCycles == 0
    stz !RAM_SpriteStatus,x
    rts                                      ; configured not to repeat, so erase sprite
  else
    lda.b #!NumCycles-!RepeatCycles
    sta !LWCycle,x                           ; reset to the specified cycle
    lda.b #!RepeatOffset
    sta !LWLocationOffset,x                  ; and set the location offset for this cycle
    if !ManualCycles == 1                    ; repeating but with manual cycles...reset the timer to some sane value so things don't totally break
      lda !LWCycle,x
      bne +
      stz !LWTimeLo,x                        ; if we're resetting back to cycle 0, reset the timer to 0
      stz !LWTimeHi,x
      bra .ToPhase0
    +:
      dec
      asl
      tay
      lda EmergeTimes,y : sta !LWTimeLo,x    ; otherwise reset it to the start of the previous cycle
      lda EmergeTimes+1,y : sta !LWTimeHi,x
    endif
  endif

.ToPhase0:
  stz !LWPhase,x                             ; set phase 0
  if !ManualCycles == 0
    lda.b #!TimeHiding : sta !LWPhaseTimer,x ; set timer
  endif
  lda #$ff : sta !LWAnimation,x              ; disable gfx

.Return:
  rts

;-----------------------------------------------------------------------------------------
; phase 4 - stomped
;-----------------------------------------------------------------------------------------

Phase4:
  lda !LWPhaseTimer,x               ; if time's not up, see if it's time to play ding/buzzer
  bne +
  lda !LWFlags,x : and.b #!FlagDummy  ; if dummy, go to phase 3
  bne .ToPhase3
  lda !LWRemainingHP,x              ; if hp still not 0, go to phase 3
  bne .ToPhase3

  inc !LWPhase,x                  ; set phase 5 (falling)
  stz !RAM_SpriteSpeedY,x         ; clear sprite y speed
  lda #$23 : sta $1DF9|!addr      ; play falling sound
  rts

+:
  lda !LWFlags,x : and.b #!FlagDummy
  bne .Dummy                        ; if dummy, branch
  lda !LWPhaseTimer,x
  cmp #$24                        ; if timer != $24, return
  bne .Return
  ldy #$29                        ; ding (correct)
  lda !LWRemainingHP,x
  bpl .Damaged                    ; if HP >= 0, then damage was done to get here
  eor #$ff : inc                  ; otherwise, it wasn't
  sta !LWRemainingHP,x            ; so make it positive again for next time and play:
  ldy #$2A                        ; buzzer (incorrect)
.Damaged
  sty $1DFC|!addr                 ; play ding or buzzer
  rts

.Dummy:
  lda !LWPhaseTimer,x
  cmp #$10                        ; if timer != $10, return
  bne .Return
  lda #$2A : sta $1DFC|!addr      ; play buzzer (incorrect)
  rts

.ToPhase3:
  lda.b #!TimeRetreat : sta !LWPhaseTimer,x  ; set time to retreat
  lda !LWFlags,x
  ora.b #!FlagPaused
  sta !LWFlags,x                  ; pause animation counter
  dec !LWPhase,x                  ; set phase 3
.Return:
  rts


;-----------------------------------------------------------------------------------------
; phase 5 - falling
;-----------------------------------------------------------------------------------------

; note: phase 5 is timer-less
Phase5:
  ldy #$40
  lda !RAM_SpriteSpeedY,x
  clc : adc #$03                  ; accelerate downward by 3/16 px/frame^2
  cmp #$40
  bpl +                           ; but cap speed at $40
  tay
+:
  sty !RAM_SpriteSpeedY,x
  jsl $01801A                     ; update y position

  if !EndingPhase == 1              ; sink in lava
    lda !LWFlags,x
    and.b #!FlagDirection
    rep #$20
    bne +
    lda.w #!SinkHeight
    bra ++
  +:
    lda.w #!SinkHeightUD
  ++:
    sta $00
    sep #$20

    lda !RAM_SpriteYHi,x
    xba
    lda !RAM_SpriteYLo,x
    rep #$20 : cmp $00 : sep #$20
    bmi .Return                     ; haven't reached the specified y pos, so return

    inc !LWPhase,x                           ; set phase 6 (sinking in lava)
    lda.b #!TimeEnding : sta !LWPhaseTimer,x   ; set timer
    lda !LWFlags,x
    ora.b #!FlagPaused
    sta !LWFlags,x                  ; pause animation counter
    lda #$20 : sta $1DFC|!addr      ; play sound effect
    jsl $028528                     ; spawn lava splash

  elseif !EndingPhase == 2          ; fall offscreen
    lda !LWFlags,x
    and.b #!FlagDirection
    sta $04
    jsr GetDrawInfo
    bcc .Return                     ; still on screen, so return

    inc !LWPhase,x                           ; set phase 6 (just waiting)
    lda.b #!TimeEnding : sta !LWPhaseTimer,x ; set timer
    lda #$ff : sta !LWAnimation,x            ; disable gfx
    lda #$18 : sta $1dfc|!addr               ; thunder sfx
  endif

.Return:
  rts

;-----------------------------------------------------------------------------------------
; phase 6 - ending
;-----------------------------------------------------------------------------------------

Phase6:
  if !EndingPhase == 1
    lda #$04 : sta !RAM_SpriteSpeedY,x  ; set sprite y speed
    jsl $01801A                         ; update sprite y position
  endif

  lda !LWPhaseTimer,x                 ; if time's not up, return
  bne .Return

  stz !RAM_SpriteStatus,x         ; erase sprite

  if !DefeatAction == 1
    lda #$ff
    sta $13c6|!addr                                ; end level like a boss fight
    sta $1493|!addr                                ; and prevent walking
    lda #$0b : sta $1dfb|!addr                     ; set music
  endif

.Return:
  rts
