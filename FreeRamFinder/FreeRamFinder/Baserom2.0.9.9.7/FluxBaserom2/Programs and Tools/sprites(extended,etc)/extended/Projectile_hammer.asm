;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hammer (for Hammer Mario), actually by RussianMan.
;; Based on my hammer disassembly, modified to act like a projectile player can use.
;; Coded from scratch, original 1524's code was used as reference.
;;
;; Description: This is a hammer that Mario can throw and kill enemies with.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Disappear on power loss
;If option is enabled, projectile will disappear if player have lost power.
;Freeram should be the same as in uberasm!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DisappearOnPowerLoss = 1
!PowerValue = $00		;which power allows shooting hammer? use value from power-up's cfg property, it's calculated automatically
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
;Death type:
;0 - make sprite fall down
;1 and high - disappear in puff of smoke
;option 0 may not work 
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
;Tables
;First table is "Killed Sprite's X speed", which is used when !DeathType = 0
;Other two are GFX related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KillXSpeed:
	db $F0,$10
HammerTiles:
	db $08,$6D,$6D,$08,$08,$6D,$6D,$08
HammerGfxProp:
	db $47,$47,$07,$07,$87,$87,$C7,$C7

SmokeDeath:
LDA #$01			;
STA $170B|!Base2,x		;Turn into extended smoke

LDA #$0F			;
STA $176F|!Base2,x		;Set animation timer
RTL

Print "MAIN ",pc
Hammer:
LDA $9D			;don't do things
BNE GFX			;

If !DisappearOnPowerLoss
  LDA !FreeRam
  CMP #!PowerValue+1
  BNE SmokeDeath
endif

LDA #$01		;speed
%ExtendedSpeed()	;

LDA $173D|!Base2,x	;some kind of gravity
CMP #$40		;
BPL .no			;
INC $173D|!Base2,x	;
INC $173D|!Base2,x	;

.no
JSR SpriteInteract	;interact with sprites
INC $1765|!Base2,x	;

GFX:
;LDA $170B|!Base2	;sprite check
;CMP #$08		;If it's not Piranha's fireball
;BNE HammerGFX		;It's hammer

%ExtendedGetDrawInfo()	;

LDA $1779|!Base2,x	;Store "Behind layer" flag
STA $03			;

LDA $01			;
STA $0200|!Base2,y	;

LDA $02			;
STA $0201|!Base2,y	;

LDA $1765|!Base2,x	;
LSR #3			;
AND #$07		;
PHX			;tile
TAX			;
LDA HammerTiles,x	;
STA $0202|!Base2,y	;

LDA HammerGfxProp,x	;props
EOR $00			;
EOR #$40		;>X flip
ORA $64			;
LDX $03			;
BEQ .NotBehind		;
AND #$CF		;Make it appear behind layers if it in fact is
ORA #$10		;
.NotBehind		;
STA $0203|!Base2,y	;

TYA			;
LSR #2			;
TAX			;
LDA #$02		;
STA $0420|!Base2,x	;tile size - checkmark
PLX			;
RTL			;

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