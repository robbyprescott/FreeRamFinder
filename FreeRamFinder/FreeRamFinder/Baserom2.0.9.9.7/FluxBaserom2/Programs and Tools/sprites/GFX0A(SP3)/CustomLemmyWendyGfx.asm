;-----------------------------------------------------------------------------------------
; graphics routine
;-----------------------------------------------------------------------------------------

; clobbers:
; $00-$01 = 16-bit x coord
; $02-$03 = 16-bit y coord
; $04 = upside down flag
; $05 = loop counter
; $0F is a temp scratch value
; Y = OAM offset
; (also uses X as an offset into tile data tables, but restores before returning)

SpriteGraphics:
  lda !LWAnimation,x
  cmp #$ff
  beq .Return                     ; gfx disabled

  lda !LWFlags,x : and.b #!FlagDirection
  sta $04                         ; $04 = upside down flag
  jsr GetDrawInfo
  bcs .Return                     ; offscreen

  lda !LWAnimation,x
  tay
  lda AnimationOffsets,y
  sta $0f                         ; $0f = offset for the first image in current animation
  lda !LWFrameCounter,x
  lsr #2
  clc : adc $0f                   ; add frame/4 to get the actual offset
  tay
  lda AnimationImages,y
  sta $0f                         ; $0f = actual image to display
  tay
  lda TilesPerImage,y : sta $05   ; $05 = loop counter

  ldy !15EA,x                     ; Y = OAM table offset
  lda $0f
  asl                             ; image * 2 (note: carry bit clear since there are at most 42 images)
  adc $0f                         ; image * 3
  asl                             ; image * 6
  tax                             ; X = offset into the tile data tables

.Loop:
  dec $05
  bmi .Return
  jsr DrawTile
  iny #4                         ; next OAM slot
  inx                            ; next tile index
  bra .Loop

.Return:
  ldx $15e9|!addr                 ; restore sprite index
  rts

;--------------------------------------------------------------------

; simplified version of Pixi's %GetDrawInfo() that just sets and checks what we need
; fairly reasonable bounds are given to make sure still-visible sprites get drawn without causing unwanted wrapping
; these can be tweaked if needed

; if the current tile has an offset of 0 and a size of 8, it occupies pixels 0-7, so when
; upside down, it should be pixels -7 to 0, so an offset of -7
; normal formula is YOFF + yoff (YOFF result from getdrawinfo(), yoff the tile data)
; if upside down, use YOFF + -(yoff + size - 1) = YOFF + 1 - (yoff + size)

; pass: $04 = upside down flag
; returns: carry bit set if sprite is off-screen and shouldn't be drawn (rest is undefined in this case), and clear if it's okay to draw
; $00-$01 = x coordinate
; $02-$03 = y coordinate

GetDrawInfo:
  lda !RAM_SpriteXHi,x
  xba
  lda !RAM_SpriteXLo,x
  rep #$20                ; 16-bit A
  sec : sbc $1a
  sta $00
  cmp #$ffe0
  bmi .Quit               ; x < -32
  cmp #$0110
  bpl .Quit               ; x >= 256+16
  sep #$20                ; 8-bit A
  
  lda !RAM_SpriteYHi,x
  xba
  lda !RAM_SpriteYLo,x
  rep #$20               ; 16-bit A
  sec : sbc $1c
  sta $02
  sep #$20 : lda $04 : rep #$20
  bne +                            ; upside down
  lda #$0018
  bra ++
+:
  lda #$0008
++:
  clc : adc $02
  bmi .Quit                        ; y < -24 (rightside up), y < -8 (upside down)
  cmp #$0100
  bpl .Quit                        ; y >= 224+8 (rightside up), y >= 224+24 (upside down)

  sep #$20                         ; 8-bit A
  clc                              ; on-screen (or close enough)
  rts

.Quit:
  sep #$20                        ; restore 8-bit A
  sec                             ; off-screen
  rts

;--------------------------------------------------------------------

; pass $00/01 = x coord of sprite
; $02/$03 = y coord of sprite
; $04 = 0 if normal spawn, non-0 if upside down
; Y = OAM table offset
; X = offset into tile data table
; clobbers: $0f

DrawTile:
  stz $0f                         ; $0f = tmp high byte of x offset
  lda TileXPositions,x
  bpl +
  dec $0f                         ; if the tile offset is negative, set this to $ff
+:
  
  clc : adc $00                   ; low byte of sprite x pos + tile x offset
  sta !OAM_DispX,y
  lda $0f
  adc $01                         ; high byte of result
  and #$01                        ; this shouldn't be anything other than 0 or 1, but just in case

  ora TileSizes,x                 ; might as well set the size bit while we're here
  sta $0f                         ; $0f = %000000sx

  phy
  tya : lsr #2 : tay
  lda $0f : sta !OAM_TileSize,y   ; and set the OAM entry
  ply

;---

  lda TileYPositions,x : sta $0f  ; $0f = extra y offset
  lda $04
  beq +                           ; if not upside down, nothing else to do
  lda $0f

  lda TileSizes,x
  and #$02                        ; 0 if 8x8, 2 if 16x16 (this step shouldn't be necessary since this data shouldn't have any other bits set)
  lsr : inc : asl #3              ; converts 2,0 to 16,8 respectively
  clc : adc $0f
  eor #$ff : inc                  ; negate
  inc                             ; and add 1
  sta $0f

+:
  lda $02                         ; Y coord
  clc : adc $0f                   ; plus the offset
  sta !OAM_DispY,y

;----

  lda TileNumbers,x : sta !OAM_Tile,y   ; set tile number

  lda $04
  beq +
  lda #%10000000                  ; toggle the flip-vertical bit of the property byte if we're upside down
+:
  eor TileProperties,x
  ora #$10                        ; set priority 1 -- this is expecting the tile data to leave the priority bits empty
  sta !OAM_Prop,y

  rts
