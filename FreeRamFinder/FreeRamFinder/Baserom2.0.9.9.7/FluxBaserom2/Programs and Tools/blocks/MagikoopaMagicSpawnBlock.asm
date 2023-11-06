;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coded by Abdu.
;; A block when hit by the magic sprite it will 
;; spawn a sprite of your choice even custom sprites.
;;
;; Recommended act as: 130
;; note that if the block's act as is set to be the same as
;; turn block it will spawn teh same sprites that get spawned
;; when the magic hits a turn block.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

!SpriteNum              = $30   ; the sprite number to spawn
!Custom                 = 0     ; if set it will spawn a custom sprite
!CustomMagicSpriteNum   = $00   ; insert custom magic sprite number here.

!UseCustomState         = 0     ; if set !CustomSpawnedState will be the state of the spawned sprite.
; the state of the sprite that will get spawned 
; the state of the sprite is up to the user so put value that make sense depending on the sprite you are using.
!CustomSpawnedState     = $08
!UseCustomMagic         = 0

!ExtraBit               = $08

!MagicSpriteNum         = $20

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Valid !CustomSpawnedState values:
;; 00	Free slot, non-existent sprite.
;; 01	Initial phase of sprite.
;; 02	Killed, falling off screen.
;; 03	Smushed. Rex and shell-less Koopas can be in this state.
;; 04	Killed with a spinjump.
;; 05	Burning in lava; sinking in mud.
;; 06	Turn into coin at level end.
;; 07	Stay in Yoshi's mouth.
;; 08	Normal routine.
;; 09	Stationary / Carryable.
;; 0A	Kicked.
;; 0B	Carried.
;; 0C	Powerup from being carried past goaltape.
;;
;; Make sure the state you set the sprite as actually makes sense
;; like for example don't set a custom thwomp state to be kicked or carryable
;; or something of that sort because some weird things could happen.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SpriteV:
SpriteH:
    LDX $15E9|!addr
    
    if !UseCustomMagic
        LDA !7FAB10,x         ; 
        AND #!ExtraBit
        BEQ .noCustom             ;
        LDA !7FAB9E,x       ;\ Check if custom sprite 
        CMP #!CustomMagic   ;| is the custom magic sprite or whaver
        BEQ +               ;/ if it is then branch
    endif
    
    .noCustom
    LDA !9E,x                   ;\ check if sprite is the magic sprite
    CMP #!MagicSpriteNum        ;|
    BNE Ret                     ;/ if not return
  + LDA #!SpriteNum             ; load sprite number
    
    if !Custom
        SEC
    else
        CLC
    endif
    
    %spawn_sprite()
    BCS Ret
    if !UseCustomState
        TAX ; get spawened sprite index to X
        LDA #!CustomSpawnedState
        STA !14C8,x
        TXA                     ; get spawned sprite index back to A
    endif
    LDX $15E9|!addr
    
    PHA                         ; save the sprite index of the sprite we just spawned
    %sprite_block_position()    ; update the block position to be the position of block that the sprite is touching
    PLA                         ; get spawned sprite index back

    %move_spawn_into_block()    ; move the spawned sprite to position to the block position
    STZ !14C8,x                 ; kill magikoopa magic
    %create_smoke()
    %erase_block()

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:



MarioCape:
MarioFireball:
Ret:
RTL


    print "If hit by a magikoopa's magic, will spawn whichever sprite you set it to."
