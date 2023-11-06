;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bubble projectile
;; This projectile moves straight right/left and pops on enemy/object contact.
;; Can be set to allow player bounce on top of it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Disappear on power loss
;If option is enabled, projectile will disappear if player have lost power.
;Freeram should be the same as in uberasm!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DisappearOnPowerLoss = 1
!PowerValue = $04		;which power allows shooting shuriken? use value from power-up's cfg property, it's calculated automatically	
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
;Bounce option and defines
;Allow player to bounce on top of it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CanBounce = 1			;
!BounceOnce = 1			;allow bouncing on the bubble only once, set to zero if you don't want that
!BounceSpd = $B0		;speed player gains

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Death type:
;0 - make sprite fall down
;1 and high - disappear in puff of smoke
;option 0 may not work 
;if sprite already has "disappear in puff of smoke" option enabled in CFG file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DeathType = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sound effects stuff
;https://www.smwcentral.net/?p=viewthread&t=6665 for more info
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!KillSound = $03
!KillSoundBank = $1DF9|!Base2

!PopSound = $19
!PopBank = $1DFC|!Base2

!BounceSound = $08
!BounceSndBnk = $1DFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Score
;view ROM address $02ACE5 in ROM map.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!DoGiveScore = 1		;Does it gives you score?

!Score = $01			;100 by default

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Tables
;First table is "Killed Sprite's X speed", which is used when !DeathType = 0
;Other two are GFX related.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KillXSpeed:
	db $F0,$10

BubbleTiles:
	db $40,$20,$22,$40 ; default $9B,$8C,$8E,$9B

BubbleSizes:
	db $00,$02,$02,$02

!BubbleFrame = $1765|!Base2
!BubbleTimer = $176F|!Base2

Timers:
db $08,$08		;time between each frame (for inflating)

!BubbleProp = #$07

;176F - timer for animation
;1765 - bubble state (graphical and interaction related

SmokeDeath:
LDA #$01			;
STA $170B|!Base2,x		;Turn into extended smoke

LDA #$0F			;
STA $176F|!Base2,x		;Set animation timer
RTS

Print "MAIN ",pc
PHB
PHK
PLB
JSR Bubble
PLB
RTL

Bubble:
LDA $9D				;don't do things
BNE GFX				;

If !DisappearOnPowerLoss
  LDA !FreeRam
  CMP #!PowerValue+1
  BNE SmokeDeath
endif

LDA #$02			;
%ExtendedSpeed()		;

LDA !BubbleFrame,x
CMP #$02
BEQ .NoTimerNonsense
TAY

LDA !BubbleTimer,x
BNE .NoTimerYet

LDA Timers,y
STA !BubbleTimer,x

INC !BubbleFrame,x

.NoTimerYet
if !CanBounce
  LDA !BubbleFrame,x		;if it's small tiny, can't bounce
  BEQ .OnlyObjInteraction	;
endif

.NoTimerNonsense
if !CanBounce
  JSR PlayerInteraction		;interact with player
endif

.OnlyObjInteraction
JSR SpriteInteract		;interact with sprites

JSR ObjInteraction		;i've explained this before, why not shared routine
BCC GFX				;

JMP Pop				;
;BRA GFX			;shold we?

GFX:
%ExtendedGetDrawInfo()		;

LDA !BubbleFrame,x		;check it's a first frame, which is an 8x8 sprite
TAX				;
BNE .NoDisplace			;

LDA $01				;8x8 tile should be in center
CLC : ADC #$04			;horizontally
STA $0200|!Base2,y		;

LDA $02				;vertically
CLC : ADC #$04			;
STA $0201|!Base2,y		;
BRA .Skip			;

.NoDisplace
LDA $01				;
STA $0200|!Base2,y		;

LDA $02				;
STA $0201|!Base2,y		;

.Skip
LDA $1779|!Base2,x		;save "behind layers" info
STA $01				;

LDA BubbleTiles,x		;
STA $0202|!Base2,y		;

PHX
LDA !BubbleProp			;
EOR $00				;
ORA $64				;
LDX $01				;
BEQ .NotBehind			;
AND #$CF			;Make it appear behind layers if it in fact is
ORA #$10			;

.NotBehind			;
STA $0203|!Base2,y		;
PLX

TYA				;
LSR #2				;
TAY				;
LDA BubbleSizes,x		;8x8 tile
STA $0420|!Base2,y		;
LDX $15E9|!Base2		;restore sprite slot
RTS				;

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

PHX				;
TYX				;
JSL $03B69F|!BankB		;get sprite's clipping
PLX				;
JSR GetExClipping		;Get Extended Sprite's Clipping
JSL $03B72B|!BankB		;interact
BCC .Not			;if no interaction, no interaction, next please

If !166EBits
  LDA !166E,y
  AND #!166EBits
  BNE .Pop
endif

if !SlideKill
  LDA !190F,y
  AND #$04
  BNE .Pop
endif

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

.Pop
JMP Pop				;pop

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

DiffGetExClipping:
LDA $171F|!Base2,x		;Get X position
CLC				;Calculate hitbox
ADC #$02			;
STA $04				;

LDA $1733|!Base2,x		;
ADC #$00			;Take care of high byte
STA $0A				;

LDA #$0C			;length
STA $06				;

LDA $1715|!Base2,x		;Y pos
;SEC				;
;SBC #$04			;
STA $05				;

LDA $1729|!Base2,x		;
;SBC #$00			;
STA $0B				;

LDA #$10			;length
STA $07				;
RTS				;

ObjInteraction:
PHK				;you may ask me "Hey Russ, Why don't you use %ExtendedBlockInteraction()?"
PEA.w .Re-1			;well, my dear friend, I noticed some bad collision detection it provides compared to SMW's, and it bugs me.
PEA.w $02A772|!BankB-1		;I'm kinda lazy to investigate on why it doesn't works right
JML $02A56E|!BankB		;so I'll use this method for now, untill that subroutine is fixed.

.Re
RTS				;

Pop:
LDA #!PopSound
STA !PopBank			;play "pop" sound

STZ $170B|!Base2,x

LDY #$03			; \ find a free slot to display effect

.loop
LDA $17C0|!Base2,y		; |
BEQ +				; |
DEY				; |
BPL .loop			; |
RTS				; /  RETURN if no slots open

+
LDA #$02			; \ set effect graphic to smoke graphic
STA $17C0|!Base2,y		; /

LDA #$10			; \ set time to show smoke
STA $17CC|!Base2,y		; /

LDA $1715|!Base2,x		; \
STA $17C4|!Base2,y		; /

LDA $171F|!Base2,x		; \
STA $17C8|!Base2,y		; /
RTS

if !CanBounce
PlayerInteraction:
JSR DiffGetExClipping		;
JSL $03B664|!BankB		;get mario's clipping

JSL $03B72B|!BankB		;
BCC .return			;

;LDY #$00
LDA $96				;check 
SEC
SBC $1715|!Base2,x
;STA $0F


;LDA $97

;SBC $1729|!Base2,x

;BPL +
;INY

;+

;LDA $0F
CMP #$E6

BPL .return

;CPY #$00
;BNE .return

LDA $7D
BMI .return

LDA #!BounceSpd
STA $7D

LDA #!BounceSound
STA !BounceSndBnk

if !BounceOnce			;check if it should pop after a bounce
  JMP Pop			;
endif				;

.return
RTS
endif