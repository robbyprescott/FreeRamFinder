; Each animation loops the given images.  Each image is displayed for 4 frames before moving to the next
; The animations must be given in the order:
;    Main boss animations (with as many animations as specified below) -- one is selected at random to display while in the vulnerable phase
;    Main dummy animations (with as many animations as specified below) -- likewise for the dummies
;    Hurt boss animation (exactly one)
;    Hurt dummy animation (exactly one)
; Notes: Animations can be at most 64 images long, and there is a limit of 256 total length across all animations

!NumBossAnimations = 8
!NumDummyAnimations = 1

; main boss animations:
%DefineAnimation($02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02)
%DefineAnimation($04,$04,$04,$04,$05,$05,$04,$05,$05,$04,$05,$05,$04,$04,$04,$04)
%DefineAnimation($06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07,$06,$06,$06,$06)
%DefineAnimation($08,$08,$08,$08,$08,$09,$09,$08,$08,$09,$09,$08,$08,$08,$08,$08)
%DefineAnimation($0B,$0B,$0B,$0B,$0A,$0B,$0A,$0B,$0A,$0B,$0A,$0B,$0B,$0B,$0B,$0B)
%DefineAnimation($0D,$0D,$0D,$0D,$0C,$0D,$0C,$0D,$0C,$0D,$0C,$0D,$0C,$0C,$0C,$0C)
%DefineAnimation($0E,$0E,$0E,$0E,$0F,$0E,$0F,$0E,$0F,$0E,$0F,$0E,$0E,$0E,$0E,$0E)
%DefineAnimation($11,$11,$11,$11,$10,$11,$12,$11,$10,$11,$12,$11,$10,$10,$10,$10)

; main dummy animations
%DefineAnimation($13)

; boss hurt animation
%DefineAnimation($00,$01)

; dummy hurt animation
%DefineAnimation($14,$14,$15,$15,$16,$16,$16,$16)

; don't change these
%MakeImagesPerAnimation()
%MakeAnimationOffsets()

;-------------------------------------------------------------------------------------
;
; The times that the emerge phase (phase 1) should least for each main animation type --
; Each of the main animation types (but not the hurt animations) contains a time to emerge, which when combined with the
;   emerge speed gives the actual y-coordinate that the sprite sits at while vulnerable (and hence determines how far the hitbox extends)

TimeEmerge:
  db $50,$4A,$50,$4A,$4A,$40,$4A,$48   ; boss animations
  db $4A                               ; dummy animations

;-------------------------------------------------------------------------------------
;
; Here the the actual tile data for each image is given
; Each image is made up of 1-6 tiles, and there is a max of 42 total images
;
; The overall format is:
; %BeginImageData(<images>), where <images> is the total number of images given
; 
; Then a sequence of images as:
;  %BeginImage()
;
;    Then 1-6 tiles like:
;    %MakeTile(x,y,tile,prop,size)
;    ...
;  %EndImage()
;
;  ...
;
; %EndImageData()
;
; The arguments to %MakeTile() are:
;   x,y - the x,y offset to place the tile relative to the sprite's position
;   tile - the (lower 8 bits) of the tile number to use
;   prop - the property byte in YXPPCCCT format
;            YX flip the tile vertically or horizontally
;            PP should be 00 -- the priority bits are set to 01 in the graphics routine
;            CCC is the palette to use (0-7, which appears as 8-F in Lunar Magic, etc)
;            T is the 9th bit of the tile number, which should usually be 1 in order to use tiles on SP3/4
;  size - this should be $00 for an 8x8 tile or $02 for a 16x16 tile
;
; Note: The tiles that make up a given image are placed in the OAM table in the order given.  This means that
;       earlier tiles will appear on top of later tiles.

%BeginImageData(23)

  %BeginImage()
    %MakeTile($00,$00,$08,$05,$02)
    %MakeTile($08,$14,$26,$45,$02)
    %MakeTile($F8,$14,$26,$05,$02)
    %MakeTile($08,$04,$20,$45,$02)
    %MakeTile($F8,$04,$20,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$00,$08,$05,$02)
    %MakeTile($08,$14,$24,$45,$02)
    %MakeTile($F8,$14,$24,$05,$02)
    %MakeTile($08,$04,$2E,$45,$02)
    %MakeTile($F8,$04,$2E,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($00,$F8,$02,$05,$00)
    %MakeTile($00,$08,$28,$05,$02)
    %MakeTile($F8,$00,$00,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($03,$F8,$12,$45,$00)
    %MakeTile($FB,$F8,$12,$05,$00)
    %MakeTile($00,$08,$28,$05,$02)
    %MakeTile($FB,$00,$04,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($08,$F8,$12,$45,$00)
    %MakeTile($00,$F8,$12,$05,$00)
    %MakeTile($00,$00,$04,$05,$02)
    %MakeTile($08,$05,$22,$45,$02)
    %MakeTile($F8,$05,$22,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$00,$08,$05,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($00,$F8,$02,$05,$00)
    %MakeTile($00,$08,$28,$05,$02)
    %MakeTile($F8,$00,$00,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($08,$00,$13,$05,$00)
    %MakeTile($00,$08,$28,$05,$02)
    %MakeTile($F8,$00,$0A,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($06,$F8,$02,$05,$00)
    %MakeTile($00,$00,$0C,$05,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($02,$F8,$02,$45,$00)
    %MakeTile($00,$00,$0C,$45,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($08,$F8,$12,$45,$00)
    %MakeTile($00,$F8,$12,$05,$00)
    %MakeTile($04,$0F,$03,$05,$00)
    %MakeTile($00,$00,$06,$05,$02)
    %MakeTile($08,$05,$22,$45,$02)
    %MakeTile($F8,$05,$22,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($08,$F8,$12,$45,$00)
    %MakeTile($00,$F8,$12,$05,$00)
    %MakeTile($00,$00,$06,$45,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($08,$00,$2A,$45,$02)
    %MakeTile($F8,$00,$2A,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($08,$00,$2C,$45,$02)
    %MakeTile($F8,$00,$2C,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($08,$F8,$12,$45,$00)
    %MakeTile($00,$F8,$12,$05,$00)
    %MakeTile($00,$00,$06,$45,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($08,$F8,$12,$45,$00)
    %MakeTile($00,$F8,$12,$05,$00)
    %MakeTile($00,$00,$06,$05,$02)
    %MakeTile($08,$05,$20,$45,$02)
    %MakeTile($F8,$05,$20,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($00,$02,$08,$05,$02)
    %MakeTile($08,$04,$22,$45,$02)
    %MakeTile($F8,$04,$22,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$01,$08,$05,$02)
    %MakeTile($08,$04,$20,$45,$02)
    %MakeTile($F8,$04,$20,$05,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$00,$08,$05,$02)
    %MakeTile($08,$04,$2E,$45,$02)
    %MakeTile($F8,$04,$2E,$05,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($08,$F8,$43,$47,$00)
    %MakeTile($00,$F8,$43,$07,$00)
    %MakeTile($00,$00,$60,$07,$02)
    %MakeTile($08,$05,$4E,$47,$02)
    %MakeTile($F8,$05,$4E,$07,$02)
  %EndImage()

;------

  %BeginImage()
    %MakeTile($00,$00,$64,$07,$02)
    %MakeTile($08,$05,$4E,$47,$02)
    %MakeTile($F8,$05,$4E,$07,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$03,$64,$07,$02)
    %MakeTile($08,$05,$62,$47,$02)
    %MakeTile($F8,$05,$62,$07,$02)
  %EndImage()

  %BeginImage()
    %MakeTile($00,$04,$64,$07,$02)
    %MakeTile($08,$05,$62,$47,$02)
    %MakeTile($F8,$05,$62,$07,$02)
  %EndImage()

%EndImageData()
