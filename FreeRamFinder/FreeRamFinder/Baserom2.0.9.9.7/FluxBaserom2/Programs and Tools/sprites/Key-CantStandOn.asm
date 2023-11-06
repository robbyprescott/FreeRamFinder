;Key
;This is a disassembly of sprite 80 in SMW - Key.
;By RussianMan. Please give credit if used.
;Requested by Hamtaro126.

!GFXTile = $EC			;tile to display. Normal EC, first

!BlockHitSound = $01
!BlockHitBank = $1DF9

Print "INIT ",pc
LDA #$09			;sprite status = carryable
STA !14C8,x			;
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Key
PLB
RTL

Key:
LDA $9D				;freeze flag
BEQ .RunMain			;
JMP RunGFX			;do graphics only (technically)

.RunMain
;JSR .HandleStun		;useless, handles stun that causes glitches

%SubOffScreen()			;originally at the end of the routine, I've moved it up here (Say no to LDA #$00)
				;you need to uncheck "Process when off screen" in CFG file to make it disappear offscreen

LDA !14C8,x			;this was subroutine
CMP #$0B			;
BNE .NotCarrying		;check if it's being carried

LDA $76				;it should face "away" from player (with player)
EOR #$01			;
STA !157C,x			;

BRA .Code			;skip interaction with objects to prevent jank

.NotCarrying
JSL $019138|!BankB		;enable object interaction

.Code
LDA !1588,x			;if it's on ground
AND #$04			;
BEQ .NoWallHit			;

JSR HandleLandingBounce		;do little upward bouncy

.NoBounce
LDA !1588,x			;if sprite meets with ceiling
AND #$08			;and it's like "hello there cutie"
BEQ .NoWall			;then no

LDA #$10			;just kidding. ceiling didn't said that. wrong text file.
STA !AA,x			;ceiling bump gives downward speed

.NoCeiling
LDA !1588,x			;check if it hits any wall
AND #$03			;
BEQ .NoWallHit			;

LDA !E4,x			;prepare for block interaction
CLC : ADC #$08			;
STA $9A				;

LDA !14E0,x			;
ADC #$00			;
STA $9B				;

LDA !D8,x			;
AND #$F0			;
STA $98				;

LDA !14D4,x			;
STA $99				;

LDA !1588,x			;
AND #$20			;
ASL #3				;
ROL				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $1868|!Base2		;
JSL $00F160|!BankB		;

LDA #$08			;
STA !1FE2,x			;

.NoWall
LDA !1588,x			;
AND #$03			;
BEQ .NoWallHit 			;

JSR HandleBlockHit		;almost the same as above

LDA !B6,x			;reverse X-speed
ASL				;
PHP				;
ROR !B6,x			;
ASL				;
ROR !B6,x			;
PLP				;
ROR !B6,x			;

.NoWallHit

JSR HandleInteraction		;

RunGFX:
;JSR HandleCarryingFacing	;
JSR HandleGFX			;
;LDA #$00			;
;%SubOffScreen()		;handle offscreen... always? I moved it on top
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutines
;
;HandleBlockHit, HandleInteraction, HandleLandingBounce
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HandleBlockHit:
;Handles block hit (Layer 2?)
;
;-----------------------------------------------------------------------
;HandleInteraction:
;Handles custom player interaction (being solid, carrying and etc.)
;
;-----------------------------------------------------------------------
;HandleLandingBounce:
;Handles lil' bounce when sprite's landing on ground with some downard Y-speed
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HandleBlockHit:
LDA #!BlockHitSound		;sound effect
STA !BlockHitBank|!Base2	;

;JSR .HandleBreak		;checks if it's a throw block. SPOILER! It's not.

LDA !15A0,x			;prevent sprite from triggering blocks when offscreen
BNE .Return			;

LDA !E4,x			;
SEC : SBC $1A			;
CLC : ADC #$14			;
CMP #$1C			;
BCC .Return			;

LDA !1588,x			;
AND #$40			;
ASL #2				;
ROR				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $18A7|!Base2		;
JSL $00F160|!BankB		;

LDA #$05			;
STA !1FE2,x			;

.Return
RTS				;

HandleLandingBounce:
LDA !B6,x			;
PHP				;
BPL .SkipInvertion		;

EOR #$FF			;
INC				;

.SkipInvertion
LSR				;
PLP				;
BPL .SkipInvertionx2		;

EOR #$FF			;
INC				;

.SkipInvertionx2
STA !B6,x			;
LDA !AA,x			;
PHA				;

LDA !1588,x			;
BMI .Speed2			;
LDA #$00			;
LDY !15B8,x			;
BEQ .Store			;

.Speed2
LDA #$18			;

.Store
STA !AA,x			;

PLA				;
LSR #2				;
TAY				;

LDA .BounceSpeeds,y		;
LDY !1588,x			;
BMI .Re				;
STA !AA,x			;

.Re
RTS				;

.BounceSpeeds:
db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
db $E8,$E8,$E8,$00,$00,$00,$00,$FE
db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
db $DC,$D8,$D4,$D0,$CC,$C8

HandleInteraction:
LDA !154C,x
BNE .Return
JSL $01803A|!BankB		;due to how original sprites work I have to make interaction works correctly myself
BCC .Return			;

;generic code from $01AA42
;LDA $140D|!Base2		;they probably wanted to disable carrying with spinjump, but it's ruined by speed check.
;ORA $187A|!Base2		;this is also pointless, because it's checked again later
;BNE RunGFX

;LDA $7D			;... and this is also pointless, because this sprite isn't shell
;BPL RunGFX			;

LDA $15				;check if player's pressing X or Y button
AND #$40			;
BEQ .CheckSpr			;

LDA $1470|!Base2		;this is better. if carrying something already, say no
ORA $148F|!Base2		;
ORA $187A|!Base2		;if on yoshi, double no
BNE .CheckSpr			;

LDA #$0B			;sprite's being carried
STA !14C8,x			;

.KeepCarried
INC $1470|!Base2		;carrying something flag

LDA #$08			;
STA $1498|!Base2		;picking up timer
RTS

.CheckSpr
LDA !14C8,x			;don't run this code if's being carried
CMP #$09			;
BNE .Return			;

STZ !154C,x			;always contact with player

LDA !D8,x
SEC : SBC $D3
CLC : ADC #$08
CMP #$20
BCC .SolidSides

.Return
RTS

.SolidSides
STZ $7B				;reset X speed
%SubHorzPos()			;
TYA				;
ASL				;
TAY				;
REP #$21			;
LDA $94				;
ADC .DATA_01AB2D,y		;
STA $94				;
SEP #$20			;
RTS				;

.DATA_01AB2D:
db $01,$00,$FF,$FF		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Graphics routine
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HandleGFX:
%GetDrawInfo()			;

LDA #!GFXTile			;
STA $0302|!Base2,y		;

LDA $00				;
STA $0300|!Base2,y		;

LDA $01				;
STA $0301|!Base2,y		;

LDA !157C,x			;facing
LSR				;
LDA #$00			;
ORA !15F6,x			;
BCS .NoFlip			;
EOR #$40			;

.NoFlip
ORA $64				;
STA $0303|!Base2,y		;

LDY #$02			;tile size = 16x16
LDA #$00			;tiles to display = 1
JSL $01B7B3|!BankB		;
RTS				;