;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iceball
;; This is a iceball that freezes enemies and turn them into custom ice block sprites.
;; It moves the same way as fireball, except it's bouncing speed is slightly higher.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Disappear on power loss
;If option is enabled, projectile will disappear if player have lost power.
;Freeram should be the same as in uberasm!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DisappearOnPowerLoss = 1
!PowerValue = $03		;which power allows shooting ice ball? use value from power-up's cfg property, it's calculated automatically
!FreeRam = $0DC4|!Base2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Weakness check:
;Check for config setting.
;It'll check for following weaknesses if enabled.
;If not it'll kill regardless if protection is enabled or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FireKill = 0
!CapeKill = 1
!SlideKill = 1
!OtherKill = 1

!166EBits = 0			;don't edit this one

if !FireKill
  !166EBits := !166EBits|$10
endif

if !CapeKill
  !166EBits := !166EBits|$20
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Iceblock settings
;Sprite number and timer for it's life.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!IceBlockSprNum = $26		;ice block's sprite number that sprites turn into when frozen

!IceBlockTimer = $80		;initial timer for ice block to stay on-screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sound effects stuff
;https://www.smwcentral.net/?p=viewthread&t=6665 for more info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FreezeSound = $01

!FreezeSoundBank = $1DFC|!Base2		;Note that 1DF9 sounds won't work because they're replaced with standart hit object sound.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX related
;GFX tile and props
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;IceballTiles:
;	db $85,$2D,$2C,$2D

!IceballTile = $64 ; default 85

IceballProps:
	db $07,$47,$C7,$87 ; $08,$48,$C8,$88 changed by SJC

SlopeYSpd:
;db $00,$B8,$C0,$C8,$D0,$D8,$E0,$E8,$F0		;original fireball slope speeds used as reference
db $00,$B0,$B8,$C0,$C8,$D0,$D8,$E0,$E8		;edited

DATA_029FA2:
db $00,$05,$03,$02,$02,$02,$02,$02,$02

Smoke:
LDA #$01			;
STA $1DF9|!Base2		;Sound effect

NoPowerDeath:
LDA #$01
STA $170B|!Base2,x		;Turn into extended smoke

LDA #$0F			;
STA $176F|!Base2,x		;Set animation timer
RTS				;

Print "MAIN ",pc
Iceball:
LDA $9D				;don't do things
BNE GFX				;

If !DisappearOnPowerLoss
  LDA !FreeRam
  CMP #!PowerValue+1
  BEQ .Continue

  JSR NoPowerDeath
  RTL
endif

.Continue
LDA $173D|!Base2,x		;If downward speed is high enough
CMP #$30			;
BPL .NoYSpeedInc		;no more gravity
CLC : ADC #$04			;
STA $173D|!Base2,x		;otherwise do increase

.NoYSpeedInc
JSR ObjInteraction		;Interaction with blocks
BCC .NoAccumulating		;

INC $175B|!Base2,x		;

LDA $175B|!Base2,x		;If fireball hits stuff
CMP #$02			;
BCC .NoSmoke			;"kill"
JSR Smoke
RTL

.NoSmoke
LDA $1747|!Base2,x		;
BPL .SkipSlope			;

LDA $0B				;Reverse slope hitbox?
EOR #$FF			;
INC A				;Depending on it's X speed
STA $0B				;

.SkipSlope
LDA $0B				;
CLC : ADC #$04			;
TAY				;
LDA SlopeYSpd,y			;
STA $173D|!Base2,x 		;Sprite's Y speed depends on slope type

LDA $1715|!Base2,x		;
SEC 				;
SBC DATA_029FA2,y		;
STA $1715|!Base2,X		;
BCS .NoHitReset			;

DEC $1729|!Base2,x		;
BRA .NoHitReset			;

.NoAccumulating
STZ $175B|!Base2,x		;

.NoHitReset
LDY #$00			;
LDA $1747|!Base2,x		;Check direction by X speed
BPL .MovesRight			;
DEY				;

.MovesRight
CLC : ADC $171F|!Base2,x	;%ExtendedSpeed() doesn't update X-position, so we have to do so manually
STA $171F|!Base2,x		;

TYA				;update high byte depending on "facing"
ADC $1733|!Base2,x		;
STA $1733|!Base2,x		;

LDA #$03			;
%ExtendedSpeed()		;

JSR SpriteInteract		;interact with sprites

INC $1765|!Base2,x		;frame counter

GFX:
%ExtendedGetDrawInfo()

LDA $01				;
STA $0200|!Base2,y		;

LDA $02				;
STA $0201|!Base2,y		;

LDA $1779|!Base2,x		;save "behind layers" info
STA $01				;

LDA #!IceballTile
STA $0202|!Base2,y		;

LDA $1765|!Base2,x		;
LSR #2				;
AND #$03			;
TAX				;
;LDA IceballTiles,x		;tiles, tiles, of course!

LDA IceballProps,x		;
EOR $00				;
ORA $64				;
STA $0203|!Base2,y		;

LDX $01				;
BEQ .NoFlips			;
AND #$CF			;
ORA #$10			;
STA $0203|!Base2,y		;Do various flips to create an illusion of rolling

.NoFlips
TYA				;
LSR #2				;
TAY				;
LDA #$00			;8x8 tile
STA $0420|!Base2,y		;
LDX $15E9|!Base2		;
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interact with other sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteInteract:
TXY
LDX #!SprSize-1			;go through loop

Loopityloop:
LDA !14C8,x			;if sprite's in normal state
CMP #$08			;
BCC .Not			;don't bother them

if !OtherKill
  LDA !167A,x			;if sprite cant interact with stuff like fire
  AND #$02			;
  ORA !1632,x			;Or if sprite's behind layers
else
  LDA !1632,x			;
endif
EOR $1779|!Base2,y		;Unless projectile is also behind layers
BNE .Not			;


JSL $03B69F|!BankB		;get sprite's clipping
PHX
TYX
JSR GetExClipping		;Get Extended Sprite's Clipping
PLX
JSL $03B72B|!BankB		;interact
BCC .Not			;if no interaction, no interaction, next please

;LDA !166E,x			;If sprite cannot be killed with fireballs
;AND #$10			;
;BNE .PreDead			;don't do harm to sprite but disappear in puff of smoke

If !166EBits
  LDA !166E,x
  AND #!166EBits
  BNE .PreDead
endif

if !SlideKill
  LDA !190F,x
  AND #$04
  BNE .PreDead
endif

JSL $07F7D2|!BankB		;\reset some things
JSL $0187A7|!BankB		;/

LDA #$01			;
STA !14C8,x			;sprite status

LDA #!IceBlockTimer		;set timer before disappearing
STA !1540,x			;

LDA $1779|!Base2,y		;sadly priority was reset, so we have to store it back
STA !1632,x			;

LDA #!IceBlockSprNum
STA !7FAB9E,x			;custom sprite

LDA #$08			;custom sprite is spawned
STA !7FAB10,x			;

LDA #!FreezeSound		;
STA !FreezeSoundBank		;

.PreDead
LDX $15E9|!Base2		;

.Dead
JMP Smoke			;and turn into smoke

.Not
DEX				;
BMI .Re				;
JMP Loopityloop			;have a feeling the branch distance is out of bounds (with CFG checks enabled)

.Re
LDX $15E9|!Base2		;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Hit Box Thingy
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetExClipping:
LDA $171F|!Base2,x		;Get X position
SEC				;Calculate hitbox
SBC #$02			;
STA $00				;

LDA $1733|!Base2,x		;
SBC #$00			;Take care of high byte
STA $08				;

LDA #$0C			;length
STA $02				;

LDA $1715|!Base2,x		;Y pos
SEC				;
SBC #$04			;
STA $01				;

LDA $1729|!Base2,x		;
SBC #$00			;
STA $09				;

LDA #$13			;length
STA $03				;
RTS				;

ObjInteraction:
PHK				;you may ask me "Hey Russ, Why don't you use %ExtendedBlockInteraction()?"
PEA.w .Re-1			;well, my dear friend, I noticed some bad collision detection it provides compared to SMW's, and it bugs me.
PEA.w $02A772|!BankB-1		;I'm kinda lazy to investigate on why it doesn't works right
JML $02A56E|!BankB		;so I'll use this method for now, untill that subroutine is fixed.

.Re
RTS				;