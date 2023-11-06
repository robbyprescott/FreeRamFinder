;-----------------------------------------------------------------------------------------
; Custom Lemmy/Wendy v1.0 , by Fernap
; based on the disassembly by yoshicookiezeus
;
; Uses extra bit: No
;
; Default Lemmy/Wendy gfx needs SP3 = 0A
;
; See CustomLemmyWendyConfig.asm for configuration options
;-----------------------------------------------------------------------------------------

incsrc "CustomLemmyWendyDefines.asm"
incsrc "CustomLemmyWendyConfig.asm"

;-----------------------------------------------------------------------------------------
; init
;-----------------------------------------------------------------------------------------

print "INIT ",pc
  phb
  phk
  plb
  jsr SpriteInit
  plb
  rtl

SpriteInit:
  lda.b #!IsWendy+$05 : sta !LWKid,x       ; $05 - Lemmy, $06 - Wendy...does this actually matter?
  stz !RAM_OffscreenHorz,x
  stz !RAM_OffscreenVert,x
  stz !LWTimeLo,x
  stz !LWTimeHi,x
  stz !LWCycle,x
  lda #$ff : sta !LWAnimation,x           ; disable gfx
  lda.b #!BossHP : sta !LWRemainingHP,x   ; start with full HP, but only for boss...irrelevant for dummy
  lda.b #!TimeStart : sta !LWPhaseTimer,x ; set time before appearing
  rts

;-----------------------------------------------------------------------------------------
; main
;-----------------------------------------------------------------------------------------

print "MAIN ",pc
  phb
  phk
  plb
  jsr SpriteMain
  plb
  rtl

SpriteMain:
  jsr SpriteGraphics
  lda !RAM_SpriteStatus,x         ; if sprite status not normal, return
  cmp #$08
  bne .Return
  lda !RAM_SpritesLocked          ; if sprites locked, return
  bne .Return

  if !ManualCycles
    inc !LWTimeLo,x                 ; increment timer
    bne +
    inc !LWTimeHi,x
  +:
  endif

  ldy !LWAnimation,x
  cpy #$ff
  beq +                           ; don't advance frame counter if gfx disabled
  lda !LWFlags,x
  and.b #!FlagPaused
  bne +                           ; or if the counter is paused

  inc !LWFrameCounter,x           ; otherwise increment it
  lda !LWFrameCounter,x
  lsr #2
  cmp ImagesPerAnimation,y
  bne +
  stz !LWFrameCounter,x           ; and reset to 0 if it's high enough

+:
  lda !LWPhase,x                     ; current phase
  %SpriteJumpTable(PhaseJumpTable)

.Return:
  rts

PhaseJumpTable:
  dw Phase0                  ; hiding
  dw Phase1                  ; emerging
  dw Phase2                  ; vulnerable
  dw Phase3                  ; retreating
  dw Phase4                  ; stomped
  dw Phase5                  ; falling
  dw Phase6                  ; sinking in lava

incsrc "CustomLemmyWendyPhases.asm"
incsrc "CustomLemmyWendyInteraction.asm"
incsrc "CustomLemmyWendyGfx.asm"
incsrc "CustomLemmyWendyMisc.asm"
