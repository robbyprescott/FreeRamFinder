;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use this patch to make more blocks edible than just the berries.
;;
;; About the files included with this patch:
;;  EdibleBlocks.asm        | This file. Patch only this one.
;;  BlockList.asm           | The list of blocks and related data. Edit this one!
;;  EatenBlockRoutines.asm  | Routines for what happens when Yoshi eats a sprite.
;;                          |  You can add your own routines into here if you want,
;;                          |  otherwise you can just leave it alone.
;;
;;
;; Coded by Thomas/kaizoman. No credit necessary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FixEating      =   1
    ; Set this to 1 to fix a number of bugs with how Baby Yoshi and Yoshi eat sprites.
    ; Highly recommended, as graphical glitches can occur with this patch otherwise.
    ; If you don't want those fixed, or already have them fixed elsewhere, set to 0.

!BlockList      =   BlockList.asm
!Routines       =   EatenBlockRoutines.asm
    ; Change these if you decide to rename or move the block list file.



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hijacks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
    sa1rom
    !Base               =   $6000
    !Base2              =   $3000
	!long				=	$000000
    !RAM_spriteID       =   $3200
    !RAM_tongueTimer    =   $32F2
    !RAM_tongueState    =   $3360
    !RAM_eatingSlot     =   $33E4
    !RAM_eatingTimer    =   $33FA
else
    lorom
    !Base               =   $0000
    !Base2              =   $0000
	!long				=	$800000
    !RAM_spriteID       =   $9E
    !RAM_tongueTimer    =   $1558
    !RAM_tongueState    =   $1594
    !RAM_eatingSlot     =   $160E
    !RAM_eatingTimer    =   $163E
endif



org $02BA9E
    autoclean JML BabyOrTongue
org $02BB01
    JSL GetTileAndActuallyPickUp
    PLX

org $02D1B9
    JML YoshiTouch
org $02D207
    JSL GetTile

org $01F0D3
    LDA $18D6+!Base
    BEQ ReturnNotBerry
    STZ $18D6+!Base
    PHX
    REP #$30
    AND #$00FF
    ASL #2
    TAX
    LDA.l EdibleBlockSettings-3,x
    AND #$00FF
    ASL
    TAX
    JSL BerryRoutines
    PLX
    RTS
  ReturnNotBerry:
    LDA #$06
    STA $1DF9+!Base
	LDA $0E1E
	BNE ReturnFlagThing
    JSL $05B34A|!long
  ReturnFlagThing:	
    RTS
    
    

org $01C358
    JSR $A365
    JSL BerryGFX
    RTS



freecode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Code begins
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc !BlockList

BabyOrTongue:
    LDY #$01 
    LDA !RAM_spriteID,x
    CMP #$35
    BEQ .tongue
    LDY #$02
  .tongue
    STY $03
    JSR CompareBlocks
    BCS .inList
    RTL
  .inList
    JML $02BAB2|!long

YoshiTouch:
    if !FixEating = 1       ; Prevent double-eat.
        LDA !RAM_tongueState,x
        BNE .skip
    endif
    LDA #$04
    STA $03
    JSR CompareBlocks
    BCS .inList
  .skip
    JML $02D1F0|!long
  .inList
    JML $02D1CD|!long


GetTileAndActuallyPickUp:
    if !FixEating = 1       ; Prevent not actually picking up the berry.
        PHX
        TXA
        LDX $15E9+!Base
        STA !RAM_eatingSlot,x
        LDA !RAM_spriteID,x
        CMP #$35
        BNE .babyYoshi
        LDA #$02
        STA !RAM_tongueState,x
        LDA #$0A
        STA !RAM_tongueTimer,x
        BRA .pickedUp
      .babyYoshi
        LDA #$37
        STA !RAM_eatingTimer,x
      .pickedUp
        PLX
    endif
GetTile:
    PHX
    LDY #$04
    REP #$30
    LDA $18D6+!Base
    AND #$00FF
    ASL #2
    TAX
    LDA.l EdibleBlockSettings-4,x
    SEP #$30
    ASL
    BCS .bushTile
    LDY #$02
  .bushTile
    STY $9C
    PLX
    RTL



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Check routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CompareBlocks:
    INC $07
    PHX
    STZ $04
    LDX #$00
  .checkLoop
    PHX
    REP #$30
    TXA
    ASL
    PHA
    ASL
    TAX
    LDA.l EdibleBlockSettings,x
    PLX
    AND $03
    BEQ .notRight
    SEP #$20
    LDA [$05]
    XBA
    LDA $1693+!Base
    REP #$20
    CMP.l EdibleBlockList,x
    BEQ .returnInList
  .notRight
    SEP #$30
    PLX
    INX
    CPX.b #(EdibleBlockSettings-EdibleBlockList)/2
    BNE .checkLoop
    PLX
    CLC
    RTS

  .returnInList:
    SEP #$30
    PLX
    TXA
    INC
    PLX
    SEC
    RTS



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Berry routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;'

incsrc !Routines

BerryRoutines:
    PHB
    PHK
    PLB
    LDA RoutinePointers,x
    STA $00
    SEP #$30
    LDX #$00
    JSR ($0000+!Base2,x)
    PLB
    RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; New GFX routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BerryGFX:
    PHX
    LDA $00
    STA $0300+!Base,y
    LDA $01
    STA $0301+!Base,y
    REP #$30
    LDA $18D6+!Base
    AND #$00FF
    ASL #2
    TAX
    SEP #$20
    LDA.l EdibleBlockSettings+2-4,x
    STA $0302+!Base,y
    LDA.l EdibleBlockSettings+3-4,x
    ORA $64
    STA $0303+!Base,y
    SEP #$10
    PLX
    LDA #$00
    LDY #$02
    JSL $01B7B3|!long
    RTL



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fix Yoshi's tongue and Baby Yoshi.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if !FixEating == 1      ; Prevent baby Yoshi from eating something while he's still eating something else.

Fix_Baby_Dbl_Eat:			; [Maarfy edit]
    LDA $0E24               ; SJC ed, restore double eat
	BNE .RestoreDoubleEat
	LDA !RAM_eatingTimer,x	; Check baby Yoshi swallowing timer ($163E)
	CMP #$20				; Check if swallowing event has been reached for first sprite contacted
	BCC .NormalEat			; If first sprite has been swallowed, begin normal swallow routine for second contacted sprite

	.QuickEat
	JML $02EAA0|!long		; If first sprite still not swallowed, quick-eat first sprite before processing the second

	.NormalEat
	JML $02EAA9|!long		; Bypass running quick-eat routine on a sprite that no longer exists
    
	.RestoreDoubleEat
	LDA $163E,x
	BNE .QuickEat
	JML $02EAA9|!long

	org $02EA9B							; Fixes the "double-eat" glitch for baby Yoshi in which eating two
		JML Fix_Baby_Dbl_Eat	; sprites with specific timing would result in consuming a 
		NOP								; non-existent third sprite. [/Maarfy edit]
        
    org $01F3D6         ; Stop Yoshi's tongue from still being out despite the sprite no longer being on it.
        RTS             ; (why are these ones even necessary, nintendo)
    org $01F3F4
        RTS
    org $01F3FA
        RTS
endif