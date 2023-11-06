;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang (for Boomerang Mario), actually by RussianMan and partially by Sonikku
;; 'Cause Sonikku's Boomerang physics are the best IMO.
;; Original 1524's code was used as reference.
;;
;; Description: This is a boomerang that Mario can throw and kill enemies with.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Disappear on power loss
;If option is enabled, projectile will disappear if player have lost power.
;Freeram should be the same as in uberasm!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DisappearOnPowerLoss = 1
!PowerValue = $01		;which power allows shooting boomerang? use value from power-up's cfg property, it's calculated automatically
!FreeRam = $0DC4|!Base2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Weakness check:
;Check for config setting.
;It'll check for following weaknesses if enabled.
;If not it'll kill regardless if protection is enabled or not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FireKill = 0
!CapeKill = 1
!SlideKill = 0
!OtherKill = 1

!166EBits = 0			;don't edit this one

if !FireKill
  !166EBits := !166EBits|$10
endif

if !CapeKill
  !166EBits := !166EBits|$20
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Death type:
;0 - make sprite fall down
;1 and high - disappear in puff of smoke
;option 0 probably may not work 
;if sprite already has "disappear in puff of smoke" option enabled in CFG file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DeathType = 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sound effects stuff
;https://www.smwcentral.net/?p=viewthread&t=6665 for more info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!KillSound = $25

!KillSoundBank = $1DFC|!Base2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Score
;view ROM address $02ACE5 in ROM map.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DoGiveScore = 1		;Does it gives you score?

!Score = $04			;1000 by default

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Speeds
;First table is "Killed Sprite's X speed", which is used when !DeathType = 0
;Other tables are speed related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KillXSpeed:
	db $F0,$10

X_Accel:
	db $01,$FF

X_Speed_Max:
	db $20,$E0

Y_Accel:
	db $01,$FF

Y_Speed_Max:
	db $12,$EE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX tiles and props
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Properties:
	db $40,$40,$80,$80

	db $00,$00,$C0,$C0

Sprite_Tiles:
	db $69,$67,$69,$67 ; default 82 and 80

!Palette = $03			;PPPT format. T is set for SP3/4 GFX page.

SmokeDeath:
LDA #$01			;
STA $170B|!Base2,x		;Turn into extended smoke

LDA #$0F			;
STA $176F|!Base2,x		;Set animation timer
RTL

Print "MAIN ",pc
Boom:
JSR GFX				;show gfx

LDA $9D				;return on freeze flag set
BNE .Re				;

If !DisappearOnPowerLoss
  LDA !FreeRam			;disappear if lost power
  CMP #!PowerValue+1		;
  BNE SmokeDeath		;
endif

LDA #$01			;
%ExtendedSpeed()		; no gravity speed

JSR SpriteInteract

LDA $176F|!Base2,x              ; if timer isn't zero, branch.
BNE .NoDec

LDA $1765|!Base2,x
		; Extended sprite's direction
TAY
				; speeds'n stuff based on it
LDA $1747|!Base2,x              ; accelerate sprite based on "direction."
CMP X_Speed_Max,y
BEQ .NoDec

LDA $1747|!Base2,x
CLC : ADC X_Accel,y
STA $1747|!Base2,x

.NoDec
LDA $14                         ; run every other frame.
LSR A

BCS .Re

LDA $0E05|!Base2,x
CMP #$01
BCS ++

LDA $0E05|!Base2,x              ; increment/decrement y speed based on stuff.

AND #$01
TAY

LDA $173D|!Base2,x
CMP Y_Speed_Max,y
BNE +

INC $0E05|!Base2,x

+
LDA $173D|!Base2,x

CLC : ADC Y_Accel,y
STA $173D|!Base2,x
RTL

++
LDA $173D|!Base2,x

BEQ .Re
DEC $173D|!Base2,x              ; decrement timer used by the x speed.

.Re
RTL

GFX:
%ExtendedGetDrawInfo()

LDA $1747|!Base2,x
STA $03				;

LDA $1779|!Base2,x		;Store "Behind layer" flag
STA $04				;

LDA $01				;
STA $0200|!Base2,y		;

LDA $02				;
STA $0201|!Base2,y		;

LDA $14				;
LSR #2				;
AND #$03			;
PHX				;
TAX				;

LDA Sprite_Tiles,x		;
STA $0202|!Base2,y		;

LDA #!Palette                   ; palette
PHY
TXY
LDX $03                         ; flip based on direction.
BPL +				;

INY #4				;

+
ORA Properties,y                ; set properties.
    
ORA $64				;
PLY				;
LDX $04				;
BEQ .NotBehind			;
AND #$CF			;
ORA #$10			;

.NotBehind			;
STA $0203|!Base2,y		;

.NoFlip
TYA				;
LSR #2				;
TAY				;
LDA #$02			;
STA $0420|!Base2,y		;16x16 tile
PLX				;restore sprite's X index
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interact with other sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteInteract:
LDY #!SprSize-1			;go through loop

Loopityloop:
LDA !14C8,y			;if sprite's in normal state
CMP #$08			;
BCC .Not			;don't bother them

if !OtherKill
  LDA !167A,y			;if sprite cant interact with stuff like fire
  AND #$02			;
  ORA !1632,y			;Or if sprite's behind layers
else
  LDA !1632,y			;
endif
EOR $1779|!Base2,x		;Unless projectile is also behind layers
BNE .Not			;

If !166EBits
  LDA !166E,y
  AND #!166EBits
  BNE .Not
endif

if !SlideKill
  LDA !190F,y
  AND #$04
  BNE .Not
endif

PHX				;
TYX				;
JSL $03B69F|!BankB		;get sprite's clipping
PLX				;
JSR GetExClipping		;Get Extended Sprite's Clipping
JSL $03B72B|!BankB		;interact
BCC .Not			;if no interaction, no interaction, next please

If !DeathType			;check if it should die in smoke pain...
  LDA !1656,y			;
  ORA #$80			;
  STA !1656,y			;
else				;...or just in pain.
  LDA #$D0			;Upward speed
  STA !AA,y			;

  LDA !157C,y
  TAX
  LDA KillXSpeed,x		;X speed depending on it's facing
  STA !B6,y			;

  TYX				;do transfer magic.
  %SubHorzPos()			;Make dead sprite face mario?
  TYA				;
  TXY				;
  EOR #$01			;Flip it's direction, so it doesn't actually face mario.
  STA !157C,y			;

  LDX $15E9|!Base2		;
endif

LDA #$02			;make sprite RIP
STA !14C8,y			;

LDA #!KillSound			;under some sound effect
STA !KillSoundBank		;

If !DoGiveScore			;if the result should be rewarding
 TYX
 if !SA1 == 1
  REP #$20
  TXA
  CLC : ADC #!sprite_y_low
  STA $CC
  TXA
  CLC : ADC #!sprite_x_low
  STA $EE
  SEP #$20
 endif
 LDA #!Score			;here's your score! Not sure if it's usefull though
 JSL $02ACE5|!BankB		;
 TXY
 LDX $15E9|!Base2
endif				;
RTS				;

.Not
DEY				;
BMI .Re				;
JMP Loopityloop			;have a feeling the branch distance is out of bounds (with CFG checks enabled)

.Re
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