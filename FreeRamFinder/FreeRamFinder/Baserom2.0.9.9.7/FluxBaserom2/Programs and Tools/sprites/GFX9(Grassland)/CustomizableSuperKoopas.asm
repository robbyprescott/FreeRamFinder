;A custom version of Super Koopas (sprites 71-73)
;Extra Bit set - swooping, otherwise grounded
;
;Extra Byte 2 sets initial X-speed, valid values: 0-7F for swooping koopas, and 0-80 for grounded. For grounded if 80, will use vanilla acceleration.
;
;Extra Byte 3 sets initial Y-speed (for swooping koopa ONLY (extra bit set))
;
;This sprite uses extra byte for settings. Format: FOKKSCCC
;CCC: cape color values for which are:
;0 - palette 8
;1 - palette 9
;2 - palette A
;3 - palette B
;4 - palette C
;5 - palette D
;6 - palette E
;7 - palette F
;S: solid, rideable (similar to mega moles, hurts from sides but can carry the player when on top). do note that setting this makes it impossible to get a cape feather from S bit (and dropping koopa along the way).
;KK: koopa's color (the appropriate koopa will drop if it has a feather):
;00 - Yellow Koopa
;10 - Blue Koopa
;20 - Red Koopa
;30 - Green Koopa
;O: object interaction & gravity - the sprite will be able to interact with objects, they'll face away from walls and bump into ceilings and floors (grounded super koopa will also be affected by gravity before taking off)
;F: Gives feather, makes cape flash (ignoring CCC settings), and drops koopa (also works for swooping ones)
;
;here are some examples:
;red cape green koopa: $34
;blue caped yellow koopa that is solid on top: $0B
;feather cape blue koopa: $90
;yellow cape red koopa that interacts with objects: $62

;some defines
!Def_GroundedTakeOffTime = $30
!Def_GroundedTakeOffUpwardSpeed = -$30
!Def_GroundedTakeOffDownwardAcceleration = $02
!Def_GroundedTakeOffDownwardMaxSpeed = $14	;when koopa starts flying
!Def_FlyingKoopaUpwardAcceleration = -$01	;used to negate remaining downward speed after takeoff turns into proper flight

!Def_SwoopingMaxUpwardSpeed = -$10
!Def_SwoopingUpwardAcceleration = -$01

!Def_CeilingBumpYSpeed = $10			;
!Def_GroundBumpYSpeed = -$10			;swooping koopa ONLY

!Def_SolidSpinKill = 1				;set to 1 to enable spinkill when solid on top (doesn't count yoshi)

!HitboxWidth = 16				;\for custom interaction (solid on top)
!HitboxHeight = 16				;/

GroundedKoopa_XSpeedAcceleration:
db $01,-$01

GroundedKoopa_MaxXSpeed:
;db $18,-$18					;same values as for swooping koopa, you can uncomment if you want different values

;some non-graphical tables
SwoopingKoopa_XSpeed:
db $18,-$18

incsrc SuperKoopaEasyPropDefines.txt

;graphical tile tables.
;Frame values:
;0 - Walking 1
;1 - Walking 2
;2 - Flying 1
;3 - Flying 2
;4 - Dying 1
;5 - Dying 2
;6 - Running 1
;7 - Running 2 AND Jumping 1
;8 - Jumping 2

GFX_Tilemap:
	db $C8,$D8,$D0,$E0
	db $C9,$D9,$C0,$E2
	db $E4,$E5,$F2,$E0
	db $F4,$F5,$F2,$E0
	db $DA,$CA,$E0,$CF
	db $DB,$CB,$E0,$CF
	db $E4,$E5,$E0,$CF
	db $F4,$F5,$E2,$CF
	db $E4,$E5,$E2,$CF

GFX_TileYDisp:
	db $00,$08,$08,$00
	db $00,$08,$08,$00
	db $03,$03,$08,$00
	db $03,$03,$08,$00
	db $FF,$07,$00,$00
	db $FF,$07,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00

GFX_TileXDisp:
;facing left
	db $08,$08,$10,$00
	db $08,$08,$10,$00
	db $08,$10,$10,$00
	db $08,$10,$10,$00
	db $09,$09,$00,$00
	db $09,$09,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00

;facing right
	db $00,$00,$F8,$00
	db $00,$00,$F8,$00
	db $00,$F8,$F8,$00
	db $00,$F8,$F8,$00
	db $FF,$FF,$00,$00
	db $FF,$FF,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00

;00 - 8x8, 02 - 16x16
GFX_TileSizes:
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00

;for this custom version the cape tile indicator bit has been moved to bit 6 (X bit), which is set afterwards anyway, that means all palettes are available for cape
GFX_AdditionalProps:
	db $41,$41,$41,$00
	db $41,$41,$41,$00
	db $41,$41,$01,$01
	db $41,$41,$01,$01
	db $C1,$C1,$80,$00
	db $C1,$C1,$80,$00
	db $41,$41,$00,$01
	db $41,$41,$00,$01
	db $41,$41,$00,$01

GFX_CapeFlashingPalettes:
	db !Palette8,!PaletteC			;now you can change them to whatever you want

KoopaColors:
	db !PaletteA,!PaletteB,!PaletteC,!PaletteD

;some common defines
!SpriteRAM_VerticalSpeed = !AA,x
!SpriteRAM_HorizontalSpeed = !B6,x
!SpriteRAM_SpriteXPositionLow = !E4,x
!SpriteRAM_SpriteState = !14C8,x
!SpriteRAM_FaceDirection = !157C,x
!SpriteRAM_GraphicalProps =  !15F6,x		;palette and SP3/4 bit to be specific

!SpriteRAM_Tweaker_1656 = !1656,x
!SpriteRAM_Tweaker_1662 = !1662,x
!SpriteRAM_Tweaker_1686 = !1686,x

;misc defines uses by these sprites
!SpriteRAM_Misc_PhasePointer = !C2,x
!SpriteRAM_Misc_GroundedVanillaMoveFlag = !1504,x
!SpriteRAM_Misc_TakeOffTimer = !151C,x		;used by grounded super koopa when it's running
!SpriteRAM_Misc_CapeFlashFlag = !1534,x		;used by feathered super koopa to indicate that its cape is flashing
!SpriteRAM_Misc_SwoopFlag = !1570,x		;instead of checking for extra bit every time, using this is slightly cost efficient
!SpriteRAM_Misc_AnimationFrame = !1602,x	;usually used as such by sprites, but there are exceptions

Print "INIT ",pc
RunInit:
PHB
PHK
PLB
LDA !extra_byte_1,x
AND #$30
LSR #4
TAY
LDA !SpriteRAM_GraphicalProps
AND #$01					;save SP3/4 from cfg.
ORA KoopaColors,y
STA !SpriteRAM_GraphicalProps

LDA !extra_byte_1,x
BPL .WontSpawnFeather

;LDA !1656,x
;ORA #$20
;STA !1656,x

LDA !1686,x					;spawn new sprite when hit from above
ORA #$40
STA !1686,x

LDA !SpriteRAM_Tweaker_1662			;\
AND #$7F					;|disable "falls down when killed" bit
STA !SpriteRAM_Tweaker_1662			;/

INC !SpriteRAM_Misc_CapeFlashFlag		;show flashing cape

.WontSpawnFeather
%SubHorzPos()					;\common between swooping and non-swooping
TYA						;|
STA !SpriteRAM_FaceDirection			;/face player

LDA !extra_bits,x				;\extra bit == clear - normal grounded super koopa that is about to take off
AND #$04					;|
BEQ SuperKoopaGrounded_Init			;/

;otherwise it's a swooping SuperKoopa

SuperKoopaSwoop_Init:
LDA !extra_byte_3,x				;\swoop in (maybe?)
STA !SpriteRAM_VerticalSpeed			;/

INC !SpriteRAM_Misc_SwoopFlag			;set a flag indicating it's a swooping one

SuperKoopaGrounded_Init:
LDA !extra_byte_2,x
LDY !SpriteRAM_Misc_SwoopFlag
BNE .Set
CMP #$80
BCS .Default
;DEC

.Set
LDY !SpriteRAM_FaceDirection
BEQ .SetSet

EOR #$FF
INC

.SetSet
STA !SpriteRAM_HorizontalSpeed

PLB
RTL

.Default
;LDA #$01
;STA !SpriteRAM_Misc_GroundedVanillaMoveFlag

INC !SpriteRAM_Misc_GroundedVanillaMoveFlag

PLB						;
RTL						;

Print "MAIN ",pc
PHB
PHK
PLB
JSR SuperKoopa_Main
PLB
RTL

SuperKoopa_Main:
JSR SuperKoopa_Graphics				;handle graphical display

LDA !SpriteRAM_SpriteState			;\check if sprite state is "Killed, falling off screen"
CMP #$02					;|
BNE .Alive					;/if not, considered alive

;animate death
LDY #$04					;graphic frame = Death 1

LDA $14						;\depending on frame counter, show one frame or another
AND #$04					;|
BEQ .StoreDeathFrame				;/

INY						;graphic frame = Death 2

.StoreDeathFrame
TYA						;\show the frame
STA !SpriteRAM_Misc_AnimationFrame		;/
RTS						;return

.Alive
LDA $9D						;\check freeze flag
BNE .Return					;/don't run the code
%SubOffScreen()					;despawn offscreen

JSL $01801A|!bank				;this one for Y-position
JSL $018022|!bank				;update position with no gravity. this one for X-position

JSR PlayerInteraction

LDA !extra_byte_1,x				;\check for O bit for object interaction
;AND #$40					;|
ASL						;|
BPL .NoObjInteraction				;/

JSR HandleObjectCollision

.NoObjInteraction
;LDA !9E,x					;\check for grounded koopa, if it is, run it's coding.
;CMP #$73					;|
;BEQ .RunPointers				;/

LDA !SpriteRAM_Misc_SwoopFlag			;\check swooping flag
BEQ .RunPointers				;/

;otherwise it's a swooping koopa with simple pattern

;LDY !SpriteRAM_FaceDirection			;\set x-speed based on facing
;LDA SwoopingKoopa_XSpeed,y			;|
;STA !SpriteRAM_HorizontalSpeed			;/

JSR .AnimateFlyingKoopa				;should be self-explanatory

LDA $13						;slightly more optimal
LSR						;
BCS .Return					;

LDA !SpriteRAM_VerticalSpeed			;\if already hit limit
CMP #!Def_SwoopingMaxUpwardSpeed		;|
BMI .Return					;/don't accelerate anymore
CLC						;\
ADC #!Def_SwoopingUpwardAcceleration		;|do acceleration
STA !SpriteRAM_VerticalSpeed			;/

.Return
RTS						;

.RunPointers
LDA !SpriteRAM_Misc_PhasePointer		;\execute pointers
JSL $0086DF|!bank				;/

dw .SuperKoopaGrounded_Running
dw .SuperKoopaGrounded_Takeoff
dw .SuperKoopaGrounded_Flying

.SuperKoopaGrounded_Running

;apply custom gravity
LDA !extra_byte_1,x
ASL
BPL .NoGravity

LDA !SpriteRAM_VerticalSpeed			;gravity recreated, may not be accurate to other sprites (didn't check disassembly)
CMP #$40					;
BEQ .NoGravity					;

INC !SpriteRAM_VerticalSpeed			;
INC !SpriteRAM_VerticalSpeed			;

.NoGravity
STZ $00						;used for animation down the line

LDA !SpriteRAM_Misc_GroundedVanillaMoveFlag
BEQ .NoMoreHorizontalAcceleration

LDY !SpriteRAM_FaceDirection			;get direction
LDA !SpriteRAM_HorizontalSpeed			;\check if already hit max speed
CMP GroundedKoopa_MaxXSpeed,y			;|
BEQ .NoMoreHorizontalAcceleration		;/if so, don't accelerate anymore
CLC						;\acceleration
ADC GroundedKoopa_XSpeedAcceleration,y		; |
STA !SpriteRAM_HorizontalSpeed			;/

.NoMoreHorizontalAcceleration_Walk
INC $00						;indicates that koopa is walking, not running

.NoMoreHorizontalAcceleration
INC !SpriteRAM_Misc_TakeOffTimer		;tick the timer
LDA !SpriteRAM_Misc_TakeOffTimer		;\check if it's time to take off
CMP #!Def_GroundedTakeOffTime			;|
BEQ .TakeOffToNextPhase				;/

.AnimateGroundedKoopa
LDY #$00					;first frame of walking/running
LDA $13						;\animate walking/running/flying
AND #$04					;|
BEQ .NotOtherFrame				;/

INY						;second frame

.NotOtherFrame
TYA						;
LDY $00						;\check if the koopa is walking
BNE .Walking					;/

CLC						;\show running frames (06 or 07)
ADC #$06					;/

.Walking
STA !SpriteRAM_Misc_AnimationFrame		;store frame
RTS						;

.TakeOffToNextPhase
INC !SpriteRAM_Misc_PhasePointer		;next phase

LDA #!Def_GroundedTakeOffUpwardSpeed		;\initial upward speed (a small jump)
STA !SpriteRAM_VerticalSpeed			;/
RTS						;

.SuperKoopaGrounded_Takeoff
LDA !SpriteRAM_VerticalSpeed			;\accelerate downwards
CLC						;|
ADC #!Def_GroundedTakeOffDownwardAcceleration	;|
STA !SpriteRAM_VerticalSpeed			;/
CMP #!Def_GroundedTakeOffDownwardMaxSpeed	;\check if hit max downward speed to start actually flying
BMI .KeepTakeOff				;/

INC !SpriteRAM_Misc_PhasePointer		;next phase

.KeepTakeOff
STZ $00						;\show running frames
JSR .AnimateGroundedKoopa			;/
INC !SpriteRAM_Misc_AnimationFrame		;+1 to be like jump 1/jump 2
RTS						;

.SuperKoopaGrounded_Flying
;LDY !SpriteRAM_FaceDirection			;\set x-speed based on facing
;LDA SwoopingKoopa_XSpeed,y			;|(literally the same table)
;STA !SpriteRAM_HorizontalSpeed			;/

LDA !SpriteRAM_VerticalSpeed			;\get from downward speed to zero
BEQ .AnimateFlyingKoopa				;/if already zero, just animate
CLC						;\accelerate
ADC #!Def_FlyingKoopaUpwardAcceleration		;|
STA !SpriteRAM_VerticalSpeed			;/

.AnimateFlyingKoopa
LDY #$02					;by default animation frame = Flying 1
LDA $13						;\every few frames change animation frame
AND #$04					;|
BEQ .StoreFlyingFrame				;/

INY						;show Flying 2

.StoreFlyingFrame
TYA						;\show it
STA !SpriteRAM_Misc_AnimationFrame		;/
RTS						;

!OAM_XPos = $0300|!addr
!OAM_YPos = $0301|!addr
!OAM_Tile = $0302|!addr
!OAM_Prop = $0303|!addr
!OAM_Size = $0460|!addr				;usually just for size (x high is handled elsewhere)

SuperKoopa_Graphics:
%GetDrawInfo()					;get all the necessary info for drawing

STZ $06

LDA !SpriteRAM_FaceDirection			;\direction into scratch RAM for future use
STA $02						;/
;calculate facing x-disp offset beforehand (less costly than doing it every frame)
BNE .NotFacing

LDA #$24
STA $06

LDA #$40
BRA .YesFacing

.NotFacing
LDA #$00					;stupid but w/e

.YesFacing
ORA $64
STA $08

LDA !extra_byte_1,x				;\get cape palette from extra byte
AND #$07					;|
ASL						;|
STA $09						;/

LDA !SpriteRAM_GraphicalProps			;\store graphical props but filter SP3/4 bit (because it uses a mix of SP1/2 and SP3/4)
AND #$0E					;|
STA $05						;/

LDA !SpriteRAM_Misc_AnimationFrame		;\calculate offset for graphical information depending on currently displayed frame
ASL						;|
ASL						;|
STA $03						;/

LDA !SpriteRAM_Misc_CapeFlashFlag		;\don't need "reload sprite slot in the middle of the loop" nonsense
STA $07						;/just store beforehand

;PHX						;save X (which can be optimized)
STZ $04						;initialize currently processed tile to start from 0

.Loop:
LDA $03						;\calculate offset for each individual tile
CLC						;|
ADC $04						;|
TAX						;/

LDA $01						;\calculate tile's Y-position
CLC						;|
ADC GFX_TileYDisp,x				;|
STA !OAM_YPos,y					;/

LDA GFX_Tilemap,x				;\store sprite tile
STA !OAM_Tile,y					;/

PHY						;save Y for OAM
TYA						;\get actual slot value
LSR						;|
LSR						;|
TAY						;/
LDA GFX_TileSizes,x				;\store tile size
STA !OAM_Size,y					;/
PLY						;restore y for further OAM shenanigans

LDA GFX_AdditionalProps,x			;
AND #$40					;bit 1 indicates wether it's a cape tile or koopa tile
BEQ .ShowKoopa					;

;show cape
LDA $07						;\check if flashing cape
BEQ .NoCapeFlash				;/if not, well

LDA $14						;\depending on current frame, show one palette or another
LSR						;|
AND #$01					;|
PHY						;|
TAY						;|
LDA GFX_CapeFlashingPalettes,y			;/
PLY						;
BRA .ShowCape					;

.NoCapeFlash
LDA $09

.ShowCape
ORA GFX_AdditionalProps,x			;properties like y-flip and SP3/SP4
AND #$BF					;filters out X bit which is set afterwards anyway.
BRA .ContinueProps				;

.ShowKoopa
LDA GFX_AdditionalProps,x			;\koopa can be of any palette on the other hand
ORA $05						;/don't forget cfg settings for palette (minus SP3/4 which can be set by above table)

.ContinueProps
ORA $08						;
STA !OAM_Prop,y					;store property

;LDA $02
;BNE .NoOffset
;LDA $06
;BEQ .NoOffset
TXA
CLC
ADC $06
TAX

.NoOffset
LDA $00						;displace horizontally
CLC						;
ADC GFX_TileXDisp,x				;
STA !OAM_XPos,y					;

INY #4						;\next tile
INC $04						;/

LDA $04						;\check if processed all tiles
CMP #$04					;|
BNE .Loop					;/if not, loop
;PLX

LDX $15E9|!addr					;slightly more optimal than PHX : PLX

LDY #$FF					;variable size (both 8x8 and 16x16)
LDA #$03					;4 tiles to draw
%FinishOAMWrite()				;do the draw
RTS						;end of graphics routine

HandleObjectCollision:
JSL $019138|!bank				;object interaction

LDA !1588,x					;\check if interacted with wall
AND #$03					;|
BEQ .NoWall					;/

LDA !SpriteRAM_FaceDirection			;\face away
EOR #$01					;|
STA !SpriteRAM_FaceDirection			;/

LDA !SpriteRAM_HorizontalSpeed			;\invert speed
EOR #$FF					;|
INC						;|
STA !SpriteRAM_HorizontalSpeed			;/

.NoWall
LDA !1588,x					;\check if bumped into ceiling
AND #$08					;|
BEQ .NoCeiling					;/

LDA #!Def_CeilingBumpYSpeed			;\set bump speed
STA !SpriteRAM_VerticalSpeed			;/

.NoCeiling
LDA !1588,x					;\check if touched ground
AND #$04					;|
BEQ .NoGround					;/

;check slopes
LDA #$00					;\otherwise reset
LDA !15B8,x					;|unless it's on some slope
BEQ .Normal					;/

LDA #$18
LDY !SpriteRAM_Misc_SwoopFlag
BEQ .StoreSpeed

LDA #-$18					;\prevent clipping (unless it's a VERY steep slope, I can't help here)
STA !SpriteRAM_VerticalSpeed			;/
RTS

.Normal
LDA !SpriteRAM_Misc_SwoopFlag			;check if this is grounded koopa
BEQ .ZeroSpeed

;swooping koopa, bump up
LDA #!Def_GroundBumpYSpeed

.StoreSpeed
STA !SpriteRAM_VerticalSpeed
RTS

.ZeroSpeed
STZ !SpriteRAM_VerticalSpeed			;

.NoGround
RTS

PlayerInteraction:
LDA !extra_byte_1,x				;\check if should be solid on top
AND #$08					;|
BNE .Custom					;/process custom interaction

JSL $01803A|!bank				;interact with other sprites and with player

.Vanilla
;have to use hax to make this work: when you bop this sprite when it has feather, it will spawn said feather, but it won't turn into a blue koopa. additional check to the rescue
LDA !9E,x					;\check if the sprite's "acts as" setting changed during interaction (when hit from above it should turn into blue koopa)
CMP #$02					;|
BNE .DidntChangeIntoBlueKoopa			;/

LDA #$00					;\
STA !extra_bits,x				;/change from custom to vanilla

;but should it turn into blue koopa? check palette for answers
LDA !SpriteRAM_GraphicalProps			;
AND #$0E					;filter SP3/4 bit
LDY #$03					;start at yellow koopa
CMP #!PaletteA					;yellow palette?
BEQ .Store					;
LDY #$01					;red koopa
CMP #!PaletteC					;red palette?
BEQ .Store					;
DEY						;otherwise default to green shell-less koopa
CMP #!PaletteD					;
BNE .AlreadyBlueKoopa				;

.Store
TYA						;
STA !9E,x					;change into appropriate koopa

.AlreadyBlueKoopa
.DidntChangeIntoBlueKoopa
RTS

.Custom
JSL $018032|!bank				;interact with sprites only (for custom player interaction)

;stole all of this from BlindDevil's leaf platform (actually from toxic one partially by me)

%SetPlayerClippingAlternate()	;get player's hitbox

STZ $08				;no hitbox dispostition at all
STZ $09				;
STZ $0A				;
STZ $0B				;

LDA #!HitboxWidth		;16 pixels wide (by default, see define value)
STA $0C				;
STZ $0D				;doubt it would be more than 255, which means this doesnt matter

LDA #!HitboxHeight		;5 pixels tall (by default)
STA $0E				;
STZ $0F				;

%SetSpriteClippingAlternate()	;check collision
%CheckForContactAlternate()
BCC .Re				;no contact = return

%SubVertPos()
LDA $0F			;load sprite Y position relative to player
CMP #$E6		;compare to value
BPL .noride		;if positive, don't ride sprite.

LDA $7D			;load player's Y speed
BMI .Re			;if negative, don't ride sprite.

If !Def_SolidSpinKill
LDA $187A|!addr
BNE .NoSpinKill

  LDA $140D|!addr
  BNE .SpinKill

.NoSpinKill
endif

LDA #$01		;load value
STA $1471|!Base2	;store to type of platform player is riding address.
STZ $7D			;reset Y speed.
LDA #$E2		;load Y offset for player into A
LDY $187A|!Base2	;load riding Yoshi flag
BEQ +			;if not riding, don't change Y offset.
LDA #$D2		;else load new value for Y offset
+
CLC			;clear carry
ADC !D8,x		;add sprite's Y-pos, low byte, to it
STA $96			;store to player's Y-pos within the level, next frame, low byte.
LDA !14D4,x		;load sprite's Y-pos, high byte
ADC #$FF		;add value, with carry
STA $97			;store to player's Y-pos within the level, next frame, high byte.

LDA $77			;load player blocked status flags
AND #$03		;check if blocked on sides
BNE .Re			;if yes, don't update X-pos.

LDY #$00		;load value into Y
LDA $1491|!Base2	;load amount of pixels the sprite has moved horizontally
BPL +			;if positive, branch ahead
DEY			;else decrement Y
+
CLC			;clear carry
ADC $94			;add player's X-pos within the level, next frame, low byte, to it
STA $94			;store result to player's X-pos within the level, next frame, low byte.
TYA			;transfer Y to A
ADC $95			;add player's X-pos within the level, next frame, high byte, to it... with carry
STA $95			;store result to player's X-pos within the level, next frame, high byte.

.Re
RTS

.noride
LDA $1490|!addr       		;Branch if Mario has a star (should die?)
BNE .StarDeath			;don't hurt

JSL $00F5B7|!bank		;hurt!

.Continue
RTS

.StarDeath
%Star()				;star death
RTS

if !Def_SolidSpinKill
.SpinKill
%Stomp()
	LDA #$F8	        ; Set Mario Y speed
	STA $7D
        JSL $01AB99|!BankB	; display contact graphic
        LDA #$04                ; \ status = 4 (being killed by spin jump)
        STA !14C8,x             ; /   
        LDA #$1F                ; \ set spin jump animation timer
        STA !1540,x             ; /
        JSL $07FC3B|!BankB
        LDA #$08                ; \ play sound effect (replaces stomp sound)
        STA $1DF9|!Base2        ; /
RTS
endif