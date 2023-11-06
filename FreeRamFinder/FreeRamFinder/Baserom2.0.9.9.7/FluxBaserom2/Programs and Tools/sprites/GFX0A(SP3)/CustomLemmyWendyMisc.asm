;--------------------------------------------------------------------------
; Kill remaining sprites routine
;--------------------------------------------------------------------------

if !KillSprites == 1
KillMostSprites:
  phy
  ldy.b #!SprSize-2               ; ignore reserved sprites
.OuterLoop:
  dey
  bmi .Return
  lda !RAM_SpriteStatus,y         ; if empty, continue
  beq .OuterLoop
  lda !RAM_SpriteNum,y            ; if sprite is...
  cmp #$29

  if !KillDummies == 0
    beq .OuterLoop                ; boss or dummy, don't kill
  else
    bne +
    lda !LWFlags,y
    and.b #!FlagDummy
    beq .OuterLoop                ; boss, don't kill
    bra .Kill                     ; dummy, kill
  +:
  endif

  ldx.b #!DontKillSpritesNum
.InnerLoop:
  dex
  bmi .Kill                       ; no match, so kill
  cmp DontKillSprites,x
  beq .OuterLoop                  ; match, don't kill
  bra .InnerLoop

.Kill:
  lda #$04 : sta !RAM_SpriteStatus,y   ; set sprite status (killed by spinjump)
  lda #$1F : sta !1540,y               ; set time to show smoke cloud
  bra .OuterLoop

.Return:
  ldx $15e9|!addr
  ply
  rts
endif

;--------------------------------------------------------------------------
; Routine to change specified map16 tiles upon boss death
;--------------------------------------------------------------------------

; %ChangeMap16() preserves P, X, lower 8 bits of Y, and not A
; clobbers a few scratch mem locations
; no need to include this if it's not being used
if !TilesToChange > 0
ChangeTiles:
  phy
  lda.b #!TileChangeLayer : sta $1933|!addr
  ldy #$00
  rep #$20                                  ; 16-bit A

.Loop:
  lda TileChangeDataX,y : asl #4            ; tile x coord * 16 to get the pixel value
  if !TilesRelativeMario
    clc : adc $d1                           ; plus Mario's x position this frame if configured
  endif
  sta $9a 

  lda TileChangeDataY,y : asl #4            ; tile y coord * 16 to get the pixel value
  if !TilesRelativeMario
    clc : adc $d3                           ; plus Mario's y position this frame if configured
  endif
  sta $98

  lda TileChangeDataNum,y                   ; map16 value
  %ChangeMap16()
  iny #2                                    ; table of 2-byte values
  cpy.b #!TilesToChange*2
  bne .Loop

  sep #$20                                  ; 8-bit A
  ply
  rts
endif

;-----------------------------------------------------------------------------------------
; random number helper routine
;-----------------------------------------------------------------------------------------

; pass max in A (8-bit), returns a random number in [0,A] inclusive
; there's a small amount of modulo bias, but it's fairly negligible (and it's much better than Pixi's in this respect,
; especially for large upper bounds)
GetRandRange:
  cmp #0
  beq .Return                     ; input was 0, so there's nothing to do
  inc
  bne +
  jsl $01ACF9
  rts                             ; input was 255, so just return one of the 1-byte values that the PRNG generates
+:
  pha
  jsl $01ACF9                             ; first byte in both A and RAM_RandomByte1, second in RAM_RandomByte2

  if not(!sa1)
    sta $4204                               ; dividend, low byte
    lda !RAM_RandomByte2 : sta $4205        ; dividend, high byte
    pla
    sta $4206                       ; divisor -- now we have to wait at least 16 cycles
    nop #8                          ; this should be sufficient
    lda $4216                       ; remainder, low byte (why is there even a high byte when the divisor is max 255 anyway!?)
  else
    lda #$01 : sta $2250                    ; enable division
    lda !RAM_RandomByte1 : sta $2251        ; dividend, low byte
    lda !RAM_RandomByte2 : sta $2252        ; dividend, high byte
    pla
    sta $2253                               ; divisor, low byte
    stz $2254                               ; divisor, high byte
    nop : bra $00                           ; finding vague information about the required wait time, but 5 cycles seems to be safe
    lda $2308                               ; remainder, low byte
  endif

.Return:
  rts
