;A more customizable version of monty mole sprites
;Extra bit: clear - ground dwelling, set - ledge dwelling
;Extra byte 1 - Jumping X-speed				\note that these apply only when jumping out (so its initial state is between 0 and 2)
;Extra Byte 2 - Jumping Y-speed				/If you want vanilla jumping Y speed, set this to $B0
;Extra Byte 3 - Extra options:
;Bits 0 and 1 - initial state for the mole to appear in. 0 - waiting for the player, 1 - dirt animation, 2 - jumped out, 3 - move like normal. recommended are 0, 2 and 3.
;Bit 2 - chasing or hopping. set: hopping, clear: chasing
;Extra Byte 4 - Spawn timer, applicable to dirt animation.

incsrc MontyMolePropDefines.txt

;makes hidden/dirt animation mole undestructable (applies cape/shell/yoshi/fire/etc. protection). you probably don't want this if you already made mole undestructable via configuration options
!Def_Fix_HidingMontyMoleFix = 1

;this will make jumping mole not able to go through ceilings, but also through objects in general, so use this with caution
;note that this only affects jumping out from the dirt part, normal mole already has ceiling interaction fixed
!Def_Fix_CeilingFix = 0

!Def_HorzProximity = $0060			;how close the player needs to be to the mole?

!Def_HopVertSpeed = -$28

!Def_HopTime = $50				;how long does it take for the hopping kind to hop

!Def_GenMap16 = $00C6				;if you want original map16 generation (that uses 9C format), leave this at -1. otherwise you can change this to any map16 tile number you want.

;a tile to generate. NOTE: Uses $9C and $00BEB0 format. see RAM map $9C for possible values. By default $08 - Mole hole (map16 tile 0C6)
;only used if !Def_GenMap16 = -1
!Def_9CMap16Tile = $08

Table_ChasingMoleMaxXSpeed:
db $18,-$18

Table_ChasingMoleXAcceleration:
db $01,-$01

Table_HoppingMoleXSpeed:
db $10,-$10

;UNUSED!!!
;in this order: Main map; Yoshi's Island; Vanilla Dome; Forest of Illusion; Valley of Bowser; Special World; Star World.
;Table_PerSubmapAppearTime:
;db $20,$68,$20,$20,$20,$20,$20

;mole walk 1, mole walk 2, mole jump up, ledge dwelling tile
Table_16x16Tilemap:
db $82,$84,$86,$8C

!Def_GroundDwellingTile1 = $88			;first sprite tile
!Def_GroundDwellingTile2 = $89			;second one

Table_GroundDwellingXFlip:
db $00,!PropXFlip

Table_GroundDwellingXDisp:
db $00,$08,$00

;some common defines
!SpriteRAM_VerticalSpeed = !AA,x
!SpriteRAM_HorizontalSpeed = !B6,x

!SpriteRAM_SpriteXPositionLow = !E4,x
!SpriteRAM_SpriteXPositionHigh = !14E0,X

!SpriteRAM_SpriteYPositionLow = !D8,x
!SpriteRAM_SpriteYPositionHigh = !14D4,X

!SpriteRAM_SpriteState = !14C8,x
!SpriteRAM_FaceDirection = !157C,x
!SpriteRAM_BlockedStatus = !1588,x
!SpriteRAM_HorzOffscreenFlag = !15A0,x
!SpriteRAM_SlopeStatus = !15B8,x
!SpriteRAM_OnYoshiTongueFlag = !15D0,x
!SpriteRAM_GraphicalProps = !15F6,x		;palette and SP3/4 bit to be specific
!SpriteRAM_VertOffscreenFlag = !186C,x

!SpriteRAM_Tweaker_166E = !166E,x
!SpriteRAM_Tweaker_167A = !167A,x
!SpriteRAM_Tweaker_1686 = !1686,x
!SpriteRAM_Tweaker_190F = !190F,x

;this sprite's specific tables
!SpriteRAM_Misc_PhasePointer = !C2,x
!SpriteRAM_Misc_HopFlag = !151C,x		;0 - follows the player, non-0 - hopping
!SpriteRAM_Misc_Timer = !1540,x			;used for various purposes. used as a timer to jump out of the ground, and how long should it stay behind foreground (unused)
!SpriteRAM_Misc_HopTimer = !1558,x		;used for the hopping mole, when runs out the mole hops
!SpriteRAM_Misc_AnimationFrameCounter = !1570,x	;can have other uses depending on the sprites but moslty acts as a frame counter for something
!SpriteRAM_Misc_AnimationFrame = !1602,x	;usually used as such by sprites, but there are exceptions

Print "INIT ",pc
MontyMoleInit:
LDA !extra_byte_3,x				;bits 0 and 1 determine initial state of being
AND #$03					;
STA !SpriteRAM_Misc_PhasePointer		;
CMP #$01					;check if set to appear in dirty animation so it can set extra byte timer
BNE .NotDirtAnim				;

LDA !extra_byte_4,x				;if spawned in dirt anim, set its extra byte timer here
STA !SpriteRAM_Misc_Timer			;
BRA .NotJumping					;in dirt animation phase, not in jumping

.NotDirtAnim
CMP #$02					;check if jumped out
BNE .NotJumping					;if not, continue

LDA !extra_byte_1,x				;since can't take extra bytes from state 1, set them in the init
STA !SpriteRAM_HorizontalSpeed			;set speed from extra bytes

LDA !extra_byte_2,x				;
STA !SpriteRAM_VerticalSpeed			;

.NotJumping
LDA !SpriteRAM_Misc_PhasePointer		;if it spawned as jumped out or as moving
CMP #$02					;it should face the player on init
BCC .NoFacing					;

JSR FaceMario					;best works for hopping kind, really

.NoFacing
LDA !extra_byte_3,x				;
AND #$04					;bit 2 determines if it should hop
STA !SpriteRAM_Misc_HopFlag			;

;a fix from isikoro's "Hiding Monty Mole Fix"
if !Def_Fix_HidingMontyMoleFix
	;LDA !SpriteRAM_Tweaker_166E		;enable "Disable Fireball Killing"
	;ORA #$30				;and "Disable Cape Killing" bits
	;STA !SpriteRAM_Tweaker_166E		;(probably unecessary because of invincible bit below)

	LDA !SpriteRAM_Tweaker_167A		;enable "Invincible to star/cape/fire/bouncing blk" bit
	ORA #$02				;
	STA !SpriteRAM_Tweaker_167A		;

	LDA !SpriteRAM_Tweaker_1686		;enable "Inedible"
	ORA #$09				;and "Don't interact with other sprites" bits
	STA !SpriteRAM_Tweaker_1686		;

	LDA !SpriteRAM_Tweaker_190F		;enable "Can't be killed by sliding"
	ORA #$44				;and "Don't turn into a coin with silver POW"
	STA !SpriteRAM_Tweaker_190F		;
endif
RTL						;

Print "MAIN ",pc
PHB
PHK
PLB
JSR MontyMoleMain
PLB
RTL

MontyMoleMain:
LDA #$00					;erase offscreen
%SubOffScreen()					;

LDA !SpriteRAM_Misc_PhasePointer		;run moley's code
JSL $0086DF|!bank				;

dw Mole_Hidden
dw Mole_DirtAnimation
dw Mole_JumpingOut
dw Mole_Moving

Mole_Hidden:
;this fixes wraparound the original mole has
LDA.b #!Def_HorzProximity			;check if the player is close enough
STA $00						;
LDA.b #!Def_HorzProximity>>8			;
STA $01						;
%ProximityHorz()				;
BCS .NotClose					;if not close, welp

;LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen horizontally, return
;BNE .NotClose					;(probably don't even need since there's no wraparoun or w/e)

INC !SpriteRAM_Misc_PhasePointer		;set to appear on-screen

;per-OW timer. replaced with extra byte 4
;LDY $0DB3|!addr				;get current player
;LDA $1F11|!addr,y				;get the map on which the player's at
;TAY						;
;LDA Table_PerSubmapAppearTime,y		;get the timer depending on the timer
;STA !SpriteRAM_Misc_Timer			;

LDA !extra_byte_4,x				;extra byte determines jumping timer
STA !SpriteRAM_Misc_Timer			;

.NotClose
%GetDrawInfo()					;invisible but do exist
RTS						;

Mole_DirtAnimation:
LDA !SpriteRAM_Misc_Timer			;if coming out timer hasn't expired
ORA !SpriteRAM_OnYoshiTongueFlag		;and not being licked
BNE .NotComingOut				;not coming out then

INC !SpriteRAM_Misc_PhasePointer		;jump out

LDA !extra_byte_1,x				;extra bytes determine jumping out speed
STA !SpriteRAM_HorizontalSpeed			;

LDA !extra_byte_2,x				;
STA !SpriteRAM_VerticalSpeed			;

if !Def_Fix_HidingMontyMoleFix
	JSL $0187A7|!bank			;restore configurations, making it weak again
endif

;JSR IsSprOffScreen

LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen in any way
ORA !SpriteRAM_VertOffscreenFlag		;
BNE .NoShatter					;fun fact: shatter spawn routine already has IsSprOffScreen check... so these lines are actually pointless
TAY						;

JSR SpawnShatter				;do what it says

.NoShatter
JSR FaceMario					;face the player

;checks if ledge dwelling or ground dwelling
;LDA !9E,x					;if ground dwelling, doesn't generate a tile
;CMP #$4E					;
;BNE .NoTileGeneration				;

LDA !extra_bits,x				;check if extra bit is set
AND #$04					;
BEQ .NoTileGeneration				;if not, no tile generation

;tile generation setup
LDA !SpriteRAM_SpriteXPositionLow		;
STA $9A						;

LDA !SpriteRAM_SpriteXPositionHigh		;
STA $9B						;

LDA !SpriteRAM_SpriteYPositionLow		;
STA $98						;

LDA !SpriteRAM_SpriteYPositionHigh		;
STA $99						;

if !Def_GenMap16 == -1
	LDA #!Def_9CMap16Tile			;mole tile
	STA $9C					;
	JSL $00BEB0|!bank			;
else
	REP #$30				;custom defined tile
	LDA.w #!Def_GenMap16			;
	%ChangeMap16()				;
	SEP #$30				;
endif

.NoTileGeneration
.NotComingOut
;now graphics also need to check what mole
;LDA !9E,x
;CMP #$4D
;BNE .LedgeDwellingGFX

LDA !extra_bits,x				;check if extra bit is set
AND #$04					;
BNE .LedgeDwellingGFX				;is ledge dwelling mole, display ledge dwelling GFX

;Ground Dwelling animation
LDA $14						;animate based on frame counter
LSR #4						;
AND #$01					;
JSR MontyMole_GroundDwellingGFX			;draw moley's holey/hilley/piley or w/ey
RTS

;Ledge Dwelling animation
.LedgeDwellingGFX
LDA $64						;save just in case, maybe
PHA						;

LDA $14						;
ASL #2						;
AND #!PropXFlip|!PropYFlip			;flip vertically and horizontally to create an animation
ORA #$30					;highest priority
STA $64						;

LDA #$03					;will show ledge dwelling animation in case it's a ledge dwelling kind
STA !SpriteRAM_Misc_AnimationFrame		;

JSR MontyMole_GFX				;display graphics

PLA						;
STA $64						;restore this we've messed with (better than actual sprite table)
RTS						;

Mole_JumpingOut:
JSR Mole_PhysicsAndGraphics			;handle some stuff

LDA #$02					;
STA !SpriteRAM_Misc_AnimationFrame		;show jumping frame

;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;check if the mole has landed
AND #$04					;
BEQ .NotGrounded				;don't start moving yet

INC !SpriteRAM_Misc_PhasePointer		;now perform as a normal functional member of mole society

.NotGrounded
if !Def_Fix_CeilingFix
	LDA !SpriteRAM_BlockedStatus		;check if touched ceiling
	AND #$08				;
	BEQ .NotCeilinged			;

	STZ !SpriteRAM_VerticalSpeed		;nullify y-speed
.NotCeilinged
endif
RTS						;

Mole_Moving:
JSR Mole_PhysicsAndGraphics			;well? physics and graphics

LDA !SpriteRAM_BlockedStatus			;this one is applied regardless of the fix. now you can use it on bouncing blocks without clipping through the ceiling!
AND #$08					;
BEQ .NotCeilinged				;

STZ !SpriteRAM_VerticalSpeed			;no vertical speed

.NotCeilinged
LDA !SpriteRAM_Misc_HopFlag			;check if it should hop like a hopping mole it is
BNE .Mole_Hop					;do its hippity hoppity thing

JSR SetAnimationFrame				;animate FAST
JSR SetAnimationFrame				;

JSL $01ACF9|!bank				;call RNG Reinforcements
AND #$01					;
BNE .Return					;let RNG decide if the mole should move and chase the player

JSR FaceMario					;always face the Mario

LDA !SpriteRAM_HorizontalSpeed			;check if hit max x-speed
CMP Table_ChasingMoleMaxXSpeed,y		;
BEQ .Return					;if so, don't accelerate anymore
CLC : ADC Table_ChasingMoleXAcceleration,y	;do accelerate
STA !SpriteRAM_HorizontalSpeed			;
TYA						;
LSR						;
ROR						;
EOR !SpriteRAM_HorizontalSpeed			;check and see if the mole changed direction while chasing
BPL .Return					;if not, return

JSR SpawnDust					;kick some dust
JSR SetAnimationFrame				;oh and animate FASTER

.Return
RTS						;

.Mole_Hop
;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;check if grounded
AND #$04					;
BEQ .IsInAir					;if not, just fall and display a single frame

JSR SetAnimationFrame				;animate
JSR SetAnimationFrame				;

LDY !SpriteRAM_FaceDirection			;set moley's speed
LDA Table_HoppingMoleXSpeed,y			;
STA !SpriteRAM_HorizontalSpeed			;

LDA !SpriteRAM_Misc_HopTimer			;if the timer's still ticking
BNE .NoHop					;don't hop

LDA #!Def_HopTime				;restore timer for the next hop
STA !SpriteRAM_Misc_HopTimer			;

LDA #!Def_HopVertSpeed				;hop up speed
STA !SpriteRAM_VerticalSpeed			;

.NoHop
RTS						;

.IsInAir
LDA #$01					;only show one frame when airborn
STA !SpriteRAM_Misc_AnimationFrame		;
RTS						;

Mole_PhysicsAndGraphics:
;LDA $64					;
;PHA						;
;LDA !SpriteRAM_Misc_Timer			;send behind some stuff if this timer is set... which I don't think it is?
;BEQ .NoLowPriority				;

;LDA #$10					;lower priority, send behind FG
;STA $64					;

.NoLowPriority
JSR MontyMole_GFX				;show mole
;PLA						;
;STA $64					;restore priority

LDA !14C8,x					;is the sprite dead?
EOR #$08					;
ORA $9D						;is freeze flag set?
BNE .NoPhysics					;don't actually move and stuff

JSL $01803A|!bank				;interact with other sprites and with player
JSL $01802A|!bank				;interact with objects and apply speed and gravity

;JSR IsOnGround

LDA !SpriteRAM_BlockedStatus			;is grounded?
AND #$04					;
BEQ .NotTouchingGround				;

JSR SetGroundYSpeed				;set grounded speed

.NotTouchingGround
;JSR IsTouchingObjSide

LDA !SpriteRAM_BlockedStatus			;is walled?
AND #$03					;
BEQ .NotTouchingWall				;

;JSR FlipSpriteDir

LDA !SpriteRAM_FaceDirection			;face away
EOR #$01					;
STA !SpriteRAM_FaceDirection			;

LDA !SpriteRAM_HorizontalSpeed			;completely bamboozled myself by forgetting these lines (actually move away from the wall)
EOR #$FF					;
INC						;
STA !SpriteRAM_HorizontalSpeed			;

.NotTouchingWall
RTS						;

.NoPhysics
PLA						;terminate all further mole behavour
PLA						;
RTS						;

;----------------------------------------------------------------
;Subroutines:

FaceMario:
%SubHorzPos()					;face the player. 'nuff said
TYA						;
STA !SpriteRAM_FaceDirection			;
RTS						;

;set normal grounded or slope speed
SetGroundYSpeed:
LDA !SpriteRAM_BlockedStatus			;check if on layer 2
BMI .Speed2					;apply other speed

LDA #$00					;don't really pull the sprite
LDY !SpriteRAM_SlopeStatus			;check if on slope
BEQ .Store					;if not, apply normal speed

.Speed2
LDA #$18					;pull the sprite if on layer 2 or slope

.Store
STA !SpriteRAM_VerticalSpeed			;
RTS						;

;2 frame animation routine
SetAnimationFrame:
INC !SpriteRAM_Misc_AnimationFrameCounter	;count up
LDA !SpriteRAM_Misc_AnimationFrameCounter	;
LSR #3						;every 4th frame is a different anim frame
AND #$01					;
STA !SpriteRAM_Misc_AnimationFrame		;
RTS						;

;input Y - shatter property (0 - normal shatter, non-0 - rainbow shatter)
SpawnShatter:
;JSR IsSprOffScreen				;already has offscreen check of its own. don't really need it twice

LDA !SpriteRAM_SpriteXPositionLow		;\setup for shatter spawn routine
STA $9A						;|position for it
						;|
LDA !SpriteRAM_SpriteXPositionHigh		;|
STA $9B						;|
						;|
LDA !SpriteRAM_SpriteYPositionLow		;|
STA $98						;|
						;|
LDA !SpriteRAM_SpriteYPositionHigh		;|
STA $99						;/

PHB						;
LDA #$02					;bank 2 required for tables
PHA						;
PLB						;
TYA						;input
JSL $028663|!bank				;call shatter routine
PLB						;
RTS						;

SpawnDust:
LDA !SpriteRAM_BlockedStatus			;if not blocked in any direction, don't spawn dust
BEQ .Return					;(probably makes more sense if it checked for grounded but ehhh)

LDA $13						;spawn every 4 frames
AND #$03					;
ORA $86						;unless the level is slippery
BNE .Return					;

LDA #$04					;horizontal offset
STA $00						;

LDA #$0A					;vertical offset
STA $01						;

;JSR IsSprOffscreen

LDA !SpriteRAM_HorzOffscreenFlag		;if offscreen in any way
ORA !SpriteRAM_VertOffscreenFlag		;
BNE .Return					;don't spawn dust (to minimize wrapping... keyword minimize, not completely prevent)

LDA #$13					;how long to exist
STA $02						;

LDA #$03					;smoke sprite number
%SpawnSmoke()					;spawn it

.Return
RTS						;

;----------------------------------------------------------------
;Graphics Routines:

!OAM_XPos = $0300|!addr
!OAM_YPos = $0301|!addr
!OAM_Tile = $0302|!addr
!OAM_Prop = $0303|!addr

;optimized version compared to the original, unlooped and 2 tiles instead of 4
MontyMole_GroundDwellingGFX:
STA $04						;mole hill flipping

%GetDrawInfo()

LDA $01						;tile y pos
CLC : ADC #$08					;
STA !OAM_YPos,y					;
STA !OAM_YPos+4,y				;

LDA #!Def_GroundDwellingTile1			;tile
STA $0302|!addr,y				;
;INC						;next tile
LDA #!Def_GroundDwellingTile2			;
STA $0306|!addr,y				;

LDA $04						;x displacement based on current x flipping
TAX						;
LDA $00						;
CLC : ADC Table_GroundDwellingXDisp,x		;
STA !OAM_XPos,y					;

LDA $00						;second tile's x-disp
CLC : ADC Table_GroundDwellingXDisp+1,x		;
STA !OAM_XPos+4,y				;

LDA Table_GroundDwellingXFlip,x			;prop
LDX $15E9|!addr					;
ORA !SpriteRAM_GraphicalProps			;
ORA $64						;
STA !OAM_Prop,y					;
STA !OAM_Prop+4,y				;

LDY #$00					;8x8
LDA #$01					;2 tiles
%FinishOAMWrite()
RTS						;

;16x16. both ledge-dwelling and normal walking (it's all shared anyway)
MontyMole_GFX:
%GetDrawInfo()

;some dead stuff (since we have clipping bit enabled, we have to handle dead gfx ourselves)
STZ $04						;

LDA !14C8,x					;
CMP #$08					;check if alive
BEQ .NoVertFlip					;if so, no vertical flip

LDA #!PropYFlip					;vertical flip
STA $04						;

STZ !SpriteRAM_Misc_AnimationFrame		;also show only one frame just like vanilla mole

.NoVertFlip
LDA !SpriteRAM_Misc_AnimationFrame		;show a tile depending on the current graphical frame
TAX						;
LDA Table_16x16Tilemap,x			;
STA !OAM_Tile,y					;

LDX $15E9|!addr					;restore sprite slot in x we've messed with

LDA $00						;tile x
STA !OAM_XPos,y					;

LDA $01						;tile y
STA !OAM_YPos,y					;

LDA !SpriteRAM_FaceDirection			;load which way the sprite's facing
LSR						;
LDA #$00					;
ORA !SpriteRAM_GraphicalProps			;
ORA $64						;priority and potential flips (for dirt anim)
BCS .NoXFlip					;

EOR #!PropXFlip					;apply x-flip if facing a different direction (right)

.NoXFlip
ORA $04						;
STA !OAM_Prop,y					;

LDA #$00					;only 1 tile
LDY #$02					;size = 16x16
%FinishOAMWrite()				;display on-screen correctly
RTS						;
;MOLEY ON YOUR PHONE