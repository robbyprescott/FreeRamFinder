; For use with ExGFX113 in SP3 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Frozen sprite - Ice block
;This is an ice block that sprites turn into when hit with iceball.
;
;It acts like a solid sprite, which disappears after a short amount of time.
;It can also sparkle and float on water surface.
;Note that it requires buoyancy enabled to float underwater.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tile = $65			;sprite tile

!DisableSparkles = 0		;if you want to

!DisappearSound = $10		;
!DisappearBank = $1DF9		;

!FloatSpeedLimit = $F8		;floating speed limit for ice block when underwater

!FloatAcceleration = $03	;used when underwater to make it move to surface. also used to slow gravity when underwater.

;Don't touch tables down below
Map16CheckYDisp:
db $00,$F0,$00,$F0

Map16CheckXDisp:
db $00,$00,$10,$10

Print "MAIN ",pc
PHB
PHK
PLB
JSR Iceblock
PLB
Print "INIT ",pc
RTL

Kill:
STZ !14C8,x			;

LDA #!DisappearSound		;
STA !DisappearBank|!Base2	;sound effect

LDA !15A0,x			;if offscreen, prevent smoke wrapping
ORA !186C,x			;
BNE Re				;

LDA #$1B			;spawn smoke sprite
STA $02				;
STZ $00				;
STZ $01				;
LDA #$01			;
%SpawnSmoke()			;so it'll look like it disappears

Re:
RTS				;

Iceblock:
LDA $64				;priority
PHA				;

LDA !1632,x			;
BEQ .NotbehindNet		;

LDA #$10			;
STA $64				;

.NotbehindNet
JSR GFX				;Graphics!

PLA				;
STA $64				;

LDA !14C8,x			;generic checks
EOR #$08			;
ORA $9D				;
BNE Re				;
%SubOffScreen()			;

LDA !1540,x			;if it's timer is zero
BEQ Kill			;make it disappear

if not(!DisableSparkles)	;if you don't like shiny things, alright
  LDA $13                 	;\$13 or $14, doesn't matter
  AND #$1F                	;/only occasionaly spawn sparkle
  BNE NoSparkl			;return

  JSL $01ACF9|!BankB     	;\ random number - sprite position
  AND #$0F                	;/
  CLC                     	;
  ADC #$FC                	;set x location
  STA $00                 	;

  LDA $148E|!Base2        	; \ set y location
  AND #$0F                	;  |
  CLC                     	;  |
  ADC #$FE                	;  |
  STA $01                 	; /

  STZ $02 : STZ $03		;No X, no Y speed
  LDA #$05			;Sprite numer 5 - blue sparkle
  %SpawnMinorExtended()		;call this lame routine
  BCS NoSparkl			;if no sparkle being generated, no timer for it

  LDA #$17			;\ sparkle timer
  STA $1850|!Base2,y		;/

NoSparkl:
endif

JSL $01B44F|!BankB		;solid interaction routine

LDA !1632,x			;if it's not behind net
BEQ .NoResetPriority		;no point in checking and wasting cycles

LDY #$03			;check four corner pixels. GetMap16 doesn't check for whole hitbox, but rather it's position, which is usually up-left pixel.

.Map16CheckLoop
LDA !D8,x			;setup for %GetMap16
CLC : ADC Map16CheckYDisp,y	;we check 4 points, so we have to displace 'em.
STA $98				;

LDA !14D4,x			;
ADC #$00
STA $99				;

LDA !E4,x			;
CLC : ADC Map16CheckXDisp,y	;
STA $9A				;

LDA !14E0,x			;
ADC #$00			;
STA $9B				;

STZ $1933|!Base2		;layer 1 (to do add layer 2 check. for now it acts like other net enemies (aka net koopas) that check only layer 1)

PHY				;save checking point index
%GetMap16()			;
XBA				;low byte
TYA				;Y contained map16 tile hih byte
XBA				;swap
PLY				;restore check point

REP #$30			;enter 16-bit mode
CMP #$0007			;check for net tiles
BCC .CheckNext			;LIMITATION: It doesn't check for acts-like setting, but for specific tile value
CMP #$001D			;it checks for all vanilla net tiles
BCS .CheckNext			;you'll have to add checks for custom net tiles yourself if necessary
SEP #$30			;
BRA .NoResetPriority		;

.CheckNext
SEP #$30			;

DEY				;if it's not net tile
BPL .Map16CheckLoop		;check different spot

STZ !1632,x			;if it's not behind net in any of checking points, make it appear in front

.NoResetPriority
LDA !1588,x			;if ground or ceiling, reset gravity
AND #$0C			;
BEQ .Continue			;

STZ !AA,x			;

.Continue
LDA !164A,x			;if underwater, float to surface
BNE DifGravity			;

JSL $01802A|!BankB		;gravity and interaction
RTS				;

DifGravity:
JSL $01801A|!BankB		;update Y-speed
JSL $019138|!BankB		;enable object interaction

LDA !AA,x			;
BPL .NotRe			;
CMP #!FloatSpeedLimit		;limit upward speed
BCC .Re				;

.NotRe
SEC				;
SBC #!FloatAcceleration		;decrease speed to upward speed
STA !AA,x			;

.Re
RTS				;

GFX:
%GetDrawInfo()			;

LDA $00				;
STA $0300|!Base2,y		;

LDA $01				;
STA $0301|!Base2,y		;

LDA #!Tile			;
STA $0302|!Base2,y		;

LDA !15F6,x			;
ORA $64				;
STA $0303|!Base2,y		;

LDY #$02 			; This means the tile drawn is 16x16.
LDA #$00 			; The number of tiles I wrote - 1.
JSL $01B7B3|!BankB		;
RTS				;