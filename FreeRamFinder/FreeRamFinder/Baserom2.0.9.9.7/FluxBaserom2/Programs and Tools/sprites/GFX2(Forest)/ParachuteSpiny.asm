;Parachute Spiny, it's a spiny but with a parachute like Para-Bomb and Para-Goomba.

incsrc ParachuteSpinyPropDefines.txt			;no touch

!Def_SpriteToDrop = $14				;sprite number for the parachute enemy 

;used to increase/decrease angle value
SwingingAngle_AddValues:
db $01,$FF

;max/min angle values
SwingingAngle_AngleMaxMin:
db $0F,$00

;all of the tables below depend on the angle
Parachute_XSpeeds:
db $00,$02,$04,$06,$08,$0A,$0C,$0E		;swinging
db $0E,$0C,$0A,$08,$06,$04,$02,$00		;going back from the swing

;parachute's graphical tables

;tilted, normal
ParachuteTilemap:
db $E6,$E2

!ParachutePalette = !PaletteB			;hardcoded palette

;8x8 tiles
ParachuteSpinyTilemap:
db $84,$BC ; $84,$94

ParachuteFrames:
db $00,$00,$00,$00,$01,$01,$01,$01
db $01,$01,$01,$01,$00,$00,$00,$00

;ParachuteFrames:
;db $0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C
;db $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D

;for parachute's swinging
;0 - facing right, 1 - facing left
GFXFacingDirection:
db $00,$00,$00,$00,$00,$00,$00,$00
db $01,$01,$01,$01,$01,$01,$01,$01

ParachuteEnemyXDisp:
db $F8,$F8,$FA,$FA,$FC,$FC,$FE,$FE
db $02,$02,$04,$04,$06,$06,$08,$08

ParachuteEnemyXDispHigh:
db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
db $00,$00,$00,$00,$00,$00,$00,$00

ParachuteEnemyYDisp:
db $0E,$0E,$0F,$0F,$10,$10,$10,$10
db $10,$10,$10,$10,$0F,$0F,$0E,$0E

ParachuteEnemy_GFXXDisp:
db $00,$08,$00,$08

ParachuteEnemy_GFXYDisp:
db $00,$00,$08,$08

ParachuteEnemy_Flips:
db $00,!PropXFlip,!PropYFlip,!PropYFlip|!PropXFlip

;some common defines
!SpriteRAM_ActsAs = !9E,x

!SpriteRAM_VerticalSpeed = !AA,x
!SpriteRAM_HorizontalSpeed = !B6,x

!SpriteRAM_SpriteXPositionLow = !E4,x
!SpriteRAM_SpriteXPositionHigh = !14E0,X

!SpriteRAM_SpriteYPositionLow = !D8,x
!SpriteRAM_SpriteYPositionHigh = !14D4,X

!SpriteRAM_SpriteState = !14C8,x

!SpriteRAM_FaceDirection = !157C,x
!SpriteRAM_BlockedStatus = !1588,x
!SpriteRAM_SlopeStatus = !15B8,x
!SpriteRAM_OAMIndex = !15EA,x
!SpriteRAM_GraphicalProps = !15F6,x

;this sprite's specific tables
!SpriteRAM_SwingDirection = !C2,x		;even values - swinging right, odd values - swinging left
!SpriteRAM_TouchedWallFlag = !151C,x		;when touched a wall, this flag is set so it slides across said wall
!SpriteRAM_LandingTimer = !1540,x		;if set, the sprite has landed, remain stationary on the ground
!SpriteRAM_BobOmbFuse = !1540,x			;for when it turns into a bobomb
!SpriteRAM_AngleValue = !1570,x			;angle value of the swing (from 0 to F)
!SpriteRAM_Misc_AnimationFrame = !1602,x
!SpriteRAM_SpinyAnimCounter = !1504,x

Print "MAIN ",pc
PHB
PHK
PLB
JSR ParaEnemy
PLB

Print "INIT ",pc
RTL

ParaEnemy:
LDA !SpriteRAM_SpriteState				;check sprite state. is it alive and well?
CMP #$08						;
BEQ .Alive						;
JMP .LoseParachute					;it's not alive and well, also it lost its parachute

.Alive
LDA $9D							;if 9D (freeze flag) is set, don't move the sprite (only show GFX... though technically it can do other things)
BNE .GFX						;

INC !SpriteRAM_SpinyAnimCounter				;animate like normal spiny egg

LDA !SpriteRAM_LandingTimer				;if it has landed
BNE .GFX						;don't swing and stuff

LDA $13							;move down every other frame
LSR							;
BCC .NotDescending					;

INC !SpriteRAM_SpriteYPositionLow			;go down 1 pixel
BNE .NoYHi						;didn't reach the border

INC !SpriteRAM_SpriteYPositionHigh			;high position also goes down

.NoYHi
.NotDescending
LDA !SpriteRAM_TouchedWallFlag				;touched wall flag
BNE .GFX						;

LDA $13							;only change swinging angle every other frame
LSR							;
BCC .NoAngleChange					;

LDA !SpriteRAM_SwingDirection				;swing in one direction
AND #$01						;
TAY							;
LDA !SpriteRAM_AngleValue				;
CLC : ADC SwingingAngle_AddValues,y			;next angle
STA !SpriteRAM_AngleValue				;
CMP SwingingAngle_AngleMaxMin,y				;already at the max/min angle?
BNE .NoSwingDirChange					;if not, don't change swing direction

INC !SpriteRAM_SwingDirection				;change swinging direction

.NoAngleChange
.NoSwingDirChange
LDA !SpriteRAM_HorizontalSpeed				;save base x-speed (it can be non-zero if spawned by generator)
PHA							;
LDY !SpriteRAM_AngleValue				;
LDA !SpriteRAM_SwingDirection				;
LSR							;
LDA Parachute_XSpeeds,y					;add swing speed depending on angle
BCC .NoInvert						;
EOR #$FF						;swing left
INC							;

.NoInvert
CLC : ADC !SpriteRAM_HorizontalSpeed			;
STA !SpriteRAM_HorizontalSpeed				;
JSL $018022|!bank					;x-position update
PLA							;
STA !SpriteRAM_HorizontalSpeed				;
;BRA .GFX						;yes, a pointless BRA. did they have something behind it that would've been skipped?

.GFX
LDA #$00						;
%SubOffScreen()						;

;JMP .ActuallyGFX					;jumps over some tables, but we moved them above, so no need for this

.ActuallyGFX
;draw parachute first
STZ $185E|!addr						;

LDY #$F0						;
LDA !SpriteRAM_LandingTimer				;is it landing?
BEQ .ParachuteAbove					;
LSR							;if so, the parachute is going down
EOR #$0F						;
STA $185E|!addr						;
CLC : ADC #$F0						;position of the parachute
TAY							;

.ParachuteAbove
STY $00							;

LDA !SpriteRAM_SpriteYPositionLow			;save y-position because we're modifying it for graphical display (doesn't affect interaction)
PHA							;
CLC : ADC $00						;
STA !SpriteRAM_SpriteYPositionLow			;

LDA !SpriteRAM_SpriteYPositionHigh			;
PHA							;
ADC #$FF						;
STA !SpriteRAM_SpriteYPositionHigh			;

LDA !SpriteRAM_GraphicalProps				;
PHA							;
AND #$F0|!SP3SP4					;clear palette bits, save SP3/4 bit (and flips and priority I suppose)
ORA #!ParachutePalette					;blue palette for the parachute (by default anyway)
STA !SpriteRAM_GraphicalProps				;

LDY !SpriteRAM_AngleValue				;
LDA ParachuteFrames,Y					;animation frame for the parachute
STA !SpriteRAM_Misc_AnimationFrame			;slightly different values for pretty much the same result

LDA GFXFacingDirection,Y				;
STA !SpriteRAM_FaceDirection				;

JSR ParachuteGFX					;SubSprGfx2Entry1

PLA							;
STA !SpriteRAM_GraphicalProps				;restore graphical prop for the enemy

LDA !SpriteRAM_OAMIndex					;+4 to OAM offset, to get the next tile
CLC : ADC #$04						;
STA !SpriteRAM_OAMIndex					;

LDY !SpriteRAM_AngleValue				;adjust x-pos based on parachute angle
LDA !SpriteRAM_SpriteXPositionLow			;
PHA							;
CLC : ADC ParachuteEnemyXDisp,y				;
STA !SpriteRAM_SpriteXPositionLow			;

LDA !SpriteRAM_SpriteXPositionHigh			;
PHA							;
ADC ParachuteEnemyXDispHigh,y				;
STA !SpriteRAM_SpriteXPositionHigh			;

STZ $00

LDA ParachuteEnemyYDisp,y				;
SEC : SBC $185E|!addr					;
BPL .NoHigh						;

DEC $00							;

.NoHigh
CLC							;
ADC !SpriteRAM_SpriteYPositionLow			;
STA !SpriteRAM_SpriteYPositionLow			;

LDA !SpriteRAM_SpriteYPositionHigh			;
ADC $00							;
STA !SpriteRAM_SpriteYPositionHigh			;

;LDA !SpriteRAM_Misc_AnimationFrame			;more shared stuff nonsense stuffs
;SEC : SBC #$0C
;CMP #$01
;BNE .NoFacingAgain
;CLC : ADC !SpriteRAM_FaceDirection			;facing different directions (when swinging) counts as individual frames

.NoFacingAgain
;STA !SpriteRAM_Misc_AnimationFrame

;LDA !SpriteRAM_LandingTimer				;landing timer
;BEQ .NoLandedFrame					;if landed, don't appear as l

;STZ !SpriteRAM_Misc_AnimationFrame			;not tilted

.NoLandedFrame
;animate spiny...

LDA !SpriteRAM_SpinyAnimCounter				;tile depending on its animation counter
LSR #3							;
AND #$01						;
TAY							;
LDA ParachuteSpinyTilemap,y				;
STA $02							;

JSR EnemyGFX						;show the enemy (using 8x8 tiles)

JSL $01A7DC|!bank					;interact with the player

.DidntGetStomped
LDA !SpriteRAM_LandingTimer				;check if landed timer is ticking
BEQ .DidntLand						;if not, check for object interaction
DEC							;
BNE .LandingProcedure					;if did land, stay still for a bit

STZ !SpriteRAM_VerticalSpeed				;no vertical speed

PLA							;\
PLA							;/place the sprite at where the enemy display was (don't restore parachute's x-pos)
PLA							;\do restore Y-position
STA !SpriteRAM_SpriteYPositionHigh			;|
PLA							;|
STA !SpriteRAM_SpriteYPositionLow			;/

.LoseParachute
LDA #!Def_SpriteToDrop					;change into spiny
STA !SpriteRAM_ActsAs					;

JSL $07F78B|!bank					;set vanilla configurations

LDA #$00						;\
STA !extra_bits,x					;/change from custom to vanilla
RTS							;

.LandingProcedure
JSL $019138|!bank					;interact with objects

LDA !SpriteRAM_BlockedStatus				;check if grounded
AND #$04						;
BEQ .NoGround

LDA !SpriteRAM_BlockedStatus				;check if on layer 2
BMI .Speed2						;
LDA #$00						;
LDY !15B8,x						;check if on slope
BEQ .Store						;

.Speed2
LDA #$18						;some vertical speed on slope

.Store
STA !SpriteRAM_VerticalSpeed				;

.NoGround
JSL $01801A|!bank					;

INC !SpriteRAM_VerticalSpeed				;don't sink into the ground, i think? does it matter even
BRA .RestoreReturn					;

.DidntLand
TXA							;run every other frame
EOR $13							;
LSR							;
BCS .RestoreReturn					;

JSL $019138|!bank					;interact with objects

LDA !SpriteRAM_BlockedStatus				;check if touched a wall
AND #$03						;
BEQ .NoWall						;

LDA #$01						;contacted a wall (won't do its tilting movement)
STA !SpriteRAM_TouchedWallFlag				;

LDA #$07						;only this angle when sliding down the wall
STA !SpriteRAM_AngleValue				;

.NoWall
LDA !SpriteRAM_BlockedStatus				;check if grounded
AND #$04						;
BEQ .RestoreReturn					;

LDA #$20						;
STA !SpriteRAM_LandingTimer				;landing timer

.RestoreReturn
PLA							;restore enemy's base position
STA !SpriteRAM_SpriteXPositionHigh			;
PLA							;
STA !SpriteRAM_SpriteXPositionLow			;
PLA							;
STA !SpriteRAM_SpriteYPositionHigh			;
PLA							;
STA !SpriteRAM_SpriteYPositionLow			;
RTS							;

!OAM_XPos = $0300|!addr
!OAM_YPos = $0301|!addr
!OAM_Tile = $0302|!addr
!OAM_Prop = $0303|!addr
!OAM_Size = $0460|!addr					;usually just for size (x high is handled elsewhere)

ParachuteGFX:
%GetDrawInfo()

LDA !SpriteRAM_Misc_AnimationFrame			;
TAX							;
LDA ParachuteTilemap,x					;parachute's tile depending on its angle (only straight and tilted really)
STA !OAM_Tile,y						;

LDX $15E9|!addr						;

LDA $00							;
STA !OAM_XPos,y						;

LDA $01							;
STA !OAM_YPos,y						;

LDA !SpriteRAM_FaceDirection				;
LSR							;
LDA #$00						;
ORA !SpriteRAM_GraphicalProps				;
BCS .NoGFXFlip						;
EOR #$40						;flip horizontally or not flip depending on parachute's facing

.NoGFXFlip
ORA $64							;
STA !OAM_Prop,y						;

LDA #$00						;parachute is a single tile
LDY #$02						;16x16
%FinishOAMWrite()					;
RTS							;

EnemyGFX:
%GetDrawInfo()						;

LDA !SpriteRAM_GraphicalProps				;
ORA $64							;
STA $03							;

LDX #$03						;

Loop:
STX $04							;save x here (so no PHX/PLX)

LDA $00							;
CLC : ADC ParachuteEnemy_GFXXDisp,x			;
STA !OAM_XPos,y						;

LDA $01							;
CLC : ADC ParachuteEnemy_GFXYDisp,x			;
STA !OAM_YPos,y						;

LDA $02							;
STA !OAM_Tile,y						;

LDA ParachuteEnemy_Flips,x				;
ORA $03							;
STA !OAM_Prop,y						;

INY #4							;

LDX $04							;
DEX							;
BPL Loop						;

LDX $15E9|!Base2					;original uses PHX PLX, but i replaced them for optimization sake

LDA #$03						;4 tiles
LDY #$00						;8x8 size
%FinishOAMWrite()					;write 'em
RTS							;