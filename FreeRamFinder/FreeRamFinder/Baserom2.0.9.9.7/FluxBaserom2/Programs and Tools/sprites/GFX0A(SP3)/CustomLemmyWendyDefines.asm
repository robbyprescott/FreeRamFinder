!RAM_MarioSpeedY        = $7D
!RAM_SpritesLocked      = $9D
!OAM_DispX              = $0300|!addr
!OAM_DispY              = $0301|!addr
!OAM_Tile               = $0302|!addr
!OAM_Prop               = $0303|!addr
!OAM_TileSize           = $0460|!addr
!RAM_IsSpinJump         = $140D|!addr
!RAM_RandomByte1        = $148D|!addr
!RAM_RandomByte2        = $148E|!addr
!RAM_OnYoshi            = $187A|!addr

!RAM_SpriteNum          = !9E
!RAM_SpriteSpeedY       = !AA
!RAM_SpriteSpeedX       = !B6
!RAM_SpriteState        = !C2
!RAM_SpriteYLo          = !D8
!RAM_SpriteXLo          = !E4
!RAM_SpriteStatus       = !14C8
!RAM_SpriteYHi          = !14D4
!RAM_SpriteXHi          = !14E0
!RAM_DisableInter       = !154C  ; disable interaction with mario timer
!RAM_OffscreenHorz      = !15A0
!RAM_Tweaker1662        = !1662
!RAM_OffscreenVert      = !186C

; still unused: 157C?, 160E, 1626, 187B
!LWKid = !C2               ; which kid: $05 = Lemmy, $06 = Wendy, probably not important
!LWTimeLo = !1504          ; number of frames since sprite spawned, low byte
!LWTimeHi = !1510          ; ditto, high byte
!LWPhase = !151C           ; Current phase: 0 - 6
!LWAnimation = !1528       ; current animation -- $ff to disable gfx
!LWRemainingHP = !1534     ; current remaining hp for the boss; ignored for dummies
!LWPhaseTimer = !1540      ; phase timer (counts down to 0)
!LWFlags = !1570           ; bit field of flags to keep track of
  !FlagDummy = $01         ; bit 0 is 1 if this sprite is a dummy, 0 if the boss
  !FlagDirection = $02     ; bit 1 is 1 if the current spawn point is upside down, and 0 if not
  !FlagPaused = $04        ; bit 2 is 1 if the animation frame counter is paused, 0 if it's running
!LWLocationOffset = !1594  ; starts at 0 and increments by !NumPatterns each cycle -- used to get the offset into the location tables
!LWFrameCounter = !1602    ; Frame counter for the current animation, may be paused
!LWCycle = !1FD6           ; counts which cycle we're on (unused sprite table)

!HurtMario = $00F5B7
!DisplayContactGfx = $01AB99
!BoostMarioSpeed = $01AA33
!GetMarioClipping = $03B664
!CheckForContact = $03B72B
!GetSpriteClippingA = $03B69F
!GetSpriteClippingB = $03B6E5
!ShatterBlock = $028663

; sprite-safe jump (not jsr!) table macro
; A holds the 0-based index of the table entry to jump to
; the table should contain consecutive 2-byte addresses within the current bank (max 128 entries)
; A and X/Y should both be 8-bit
; preserves X, clobbers (both bytes of) A and Y
macro SpriteJumpTable(table)
  asl
  tay
  rep #$20                         ; 16-bit A
  lda <table>,y
  dec
  pha
  sep #$20                        ; 8-bit A
  rts                             ; this rts is effectively a jump (not a jsr) to the appropriate entry in the table
endmacro

; accum must be 8-bit
macro jslrts(addr)
  if bank(<addr>) == $01
    !rtladdr = $0180ca
  elseif bank(<addr>) == $02
    !rtladdr = $02b889
  else
    error "Unsupported bank for %jslrts()"
  endif

  phb
  pha : lda.b #bank(<addr>) : pha : plb : pla
  phk : pea.w ?jslrtsreturn-1
  pea.w !rtladdr-1
  jml <addr>
?jslrtsreturn:
  plb
endmacro

macro DefineAnimation(...)
  assert sizeof(...) <= 64,"Animation length can be at most 64 images."

  if not(defined("tmp_numanims"))
    AnimationImages:
    !tmp_numanims #= 0
  endif

  BeginAnimation!{tmp_numanims}:
  !tmp_idx #= 0
  while !tmp_idx < sizeof(...)
    db <!tmp_idx>
    !tmp_idx #= !tmp_idx+1
  endif

  !tmp_numanims #= !tmp_numanims+1
  EndAnimation!{tmp_numanims}:
endmacro

macro MakeImagesPerAnimation()
  ImagesPerAnimation:
  !tmp_idx #= 0
  while !tmp_idx < !tmp_numanims
    db datasize(BeginAnimation!{tmp_idx})
    !tmp_idx #= !tmp_idx+1
  endif
endmacro

macro MakeAnimationOffsets()
  AnimationOffsets:
  !tmp_idx #= 0
  while !tmp_idx < !tmp_numanims
     db BeginAnimation!{tmp_idx}-AnimationImages
    !tmp_idx #= !tmp_idx+1
  endif
endmacro

;--------------------------------------------------------------------------------

macro BeginImageData(num)
  assert <num> >= 1 && <num> <= 42,"Number of images must be from 1 to 42."
  !NumImages #= <num>
  !TileTableSize #= 6*<num>
  !tileidx #= 0
  !imageidx #= 0

  TilesPerImage:
    skip !NumImages
  TileXPositions:
    skip !TileTableSize
  TileYPositions:
    skip !TileTableSize
  TileNumbers:
    skip !TileTableSize
  TileProperties:
    skip !TileTableSize
  TileSizes:
    skip -4*!TileTableSize
    skip -!NumImages
endmacro

; pc starts at very beginning
; set pc to end of data
macro EndImageData()
  skip !NumImages
  skip !TileTableSize*5
endmacro

; pc starts at very beginning
; set to current entry in XPos table
macro BeginImage()
  !imagetiles #= 0
  !tileidx #= 6*!imageidx
  skip !NumImages
  skip !tileidx
endmacro

; pc starts at next entry in XPos
; set to very beginning
macro EndImage()
  skip -!tileidx
  skip -!NumImages
  skip !imageidx
  db !imagetiles
  !imageidx #= !imageidx+1
  skip -!imageidx  
endmacro

; pc starts at current entry in XPos table
; set to the next entry
macro MakeTile(x,y,tile,prop,size)
  !imagetiles #= !imagetiles+1
  assert !imagetiles <= 6,"Images may contain at most 6 tiles."
  !tileidx #= !tileidx+1
  db <x>
  skip !TileTableSize-1
  db <y>
  skip !TileTableSize-1
  db <tile>
  skip !TileTableSize-1
  db <prop>
  skip !TileTableSize-1
  db <size>
  skip -4*!TileTableSize
endmacro
