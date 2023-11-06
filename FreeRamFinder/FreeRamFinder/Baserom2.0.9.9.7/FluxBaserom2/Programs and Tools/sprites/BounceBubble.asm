;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Springy Bubble/Bubble Platform
;This is a bubble that player can stand on or bounce on.
;It can either move in straight line or have gravity and float on water. Once it comes in contact with solid object, it'll pop.
;
;Extra bit:
;Not set - Float on water
;Set - Move in straight line. Extra bytes 1 and 2 set X and Y speeds for it.
;
;Extra Property byte 1:
;Not set - player will bounce on top of it
;Set - player will stand on top of it like any regular platform.
;
;By RussianMan. Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FreezeTime = $0E		;how many frames to stay in place once in contact with object before popping
!FreezeTimer = !1570,x		;used for when it comes in contact with object. I'll stay in place for a short amount of time, then pop.

!BounceSpeed = $A0

!BounceSound = $08
!BounceBank = $1DFC|!Base2

!PopSound = $19
!PopBank = $1DFC|!Base2

!MaxGravity = $16		;maximum downward speed, if it uses gravity (aka float on water) when not in water

!FloatSpeedLimit = $FB		;floating speed limit for when bubble's underwater

!FloatAcceleration = $02	;used when underwater to make it move to surface. also used to slow gravity when underwater.

BubbleTileDispX:
db $00,$10,$00,$10,$07
db $01,$0F,$01,$0F,$08
db $02,$0E,$02,$0E,$08

BubbleTileDispY:
db $FD,$FD,$09,$09,$03
db $FC,$FC,$0A,$0A,$03
db $FB,$FB,$0B,$0B,$02

;db $06,$06,$12,$12,$0C		;used for reference
;db $05,$05,$13,$13,$0C
;db $04,$04,$14,$14,$0B

BubbleTiles:
db $CC,$CC,$CC,$CC,$83 ; $A0,$A0,$A0,$A0,$99

Flips:
db $00,$40,$80,$C0,$00

BubbleSize:
db $02,$02,$02,$02,$00

GeneralOffset:
db $00,$05,$0A,$05	;used to fetch correct tile, X-pos and Y-pos values for each animation frame

!PopTile1 = $64		;these tiles are shown briefly after bubble pops
!PopTile2 = $66		;

Print "INIT ",pc
LDA !extra_bits,x	;		
AND #$04		;
STA !157C,x		;this address can be easily set if used with shooter
BEQ InitReturn		;

LDA !extra_byte_1,x	;set speeds with extra bytes
STA !B6,x		;

LDA !extra_byte_2,x	;and since this it set in init and not in main code you can use shooter and set variable speed with just B6 and AA.
STA !AA,x		;

InitReturn:
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Bubble
PLB
RTL

Bubble:
JSR GFX				;

LDA !14C8,x			;check if dead or game has stopped
EOR #$08			;
ORA $9D				;
BNE .Re				;
%SubOffScreen()			;offscreen, too

LDA !FreezeTimer		;if it's not time to pop, carry on like normal
BEQ .Normal			;

STZ !AA,x			;no Y
STZ !B6,x			;and X-speed

JSR UpdateSpds			;reset zero and fix player sliding glitch (if has X-speed)

DEC !FreezeTimer		;decrease timer, obviously
BNE .ActualInteraction		;continue if it's not zero

LDA #!PopSound			;play sound effect
STA !PopBank			;

STZ !14C8,x			;no sprite. rip sprite. minute of silence.

.Re
RTS				;

.Normal
LDA !157C,x			;if extra bit isn't set, move straight
BNE .MoveStraight		;

.Underwater
JSL $01801A|!BankB		;update speed vertically
STA $1491|!Base2		;

LDA !AA,x			;apply laws of physics (or something)
CMP #!MaxGravity		;
BPL .NoIncYSpeed		;by increasing speed when falling and not in water

INC !AA,x			;

.NoIncYSpeed			;
LDA !164A,x			;if underwater (or in lava), float
BEQ .NoDecYSpeed		;otherwise, do other things

; another removed sprite number check

LDA !AA,x			; check the sprite's Y speed
BPL .DecYSpeed			; if positive, decrement it
CMP #!FloatSpeedLimit		; also decrement it if it is negative
BCC .NoDecYSpeed		; and no less than F8

.DecYSpeed			;
SEC				;
SBC #!FloatAcceleration		;decrement the sprite's Y speed by 2
STA !AA,x			;

.NoDecYSpeed
JSR UpdateYSpd			;update position with only Y-speed
BRA .Interact			;

.MoveStraight

JSR UpdateSpds			;update X and Y positions

.Interact
JSR ObjectCollisionOffset	;call object interaction

.CheckObj
LDA !1588,x			;if interaction with FG objects in any way, it'll pop
BEQ .ActualInteraction		;

LDA #!FreezeTime		;freeze in panic
STA !FreezeTimer		;

.ActualInteraction
JSL $01B44F|!BankB		;invisible solid block/platform routine
BCC .Re

;LDA #$03			;\ set Mario on sprite platform flag
;STA !160E,x			; |
;STA $1471|!Base2		;/ (probably not necessary)

LDA !extra_prop_1,x		;if not set to bounce, player can just stay on top, i guess
BNE .Re				;

LDA #!BounceSpeed		;set mario's speed
STA $7D				;wee~

LDA #!BounceSound		;sound effect
STA !BounceBank			;
RTS

;from disassembly
GFX:
LDA $14				;animate
LSR #3				;
AND #$03			;
TAY				;
LDA GeneralOffset,Y		;
STA $02				;

%GetDrawInfo()

LDA !FreezeTimer		;save timer
STA $03				;

LDA !15F6,x			;save property from CFG
STA $04				;

LDX #$04			;5 tiles to display

.Loop
PHX				;get correct X-position offset
TXA				;
CLC : ADC $02			;
TAX				;
LDA $00				;
CLC				;
ADC BubbleTileDispX,X		;
STA $0300|!Base2,Y		;tile's X-pos

LDA $01				;
CLC				;
ADC BubbleTileDispY,X		;
STA $0301|!Base2,Y		;tile's Y-pos
PLX				;

LDA BubbleTiles,X		;show tiles
STA $0302|!Base2,Y		;

LDA $04				;CFG property
ORA Flips,x			;+ X or Y (or both) flips
ORA $64				;+ priority
STA $0303|!Base2,Y		;= tile ptoperties

LDA $03				;check timer
BEQ .NoTile			;
CMP #$06			;
BCS .NoTile			;
CMP #$03			;
LDA #$02			;
ORA $64				;
STA $0303|!Base2,Y		;pop effect's property

LDA #!PopTile1			;
BCS .StoreTile			;

LDA #!PopTile2			;

.StoreTile
STA $0302|!Base2,Y		;

.NoTile
PHY				;set tile sizes
TYA				;
LSR #2				;
TAY				;
LDA BubbleSize,X		;
STA $0460|!Base2,Y		;
PLY				;
INY #4

DEX				;
BPL .Loop			;

LDX $15E9|!Base2

LDY.b #$FF			;variable size
LDA.b #$04			;5 sprites
JSL $01B7B3|!BankB		;
RTS				;

;Purpose of this routine is to offset bubble's position for object collision, without need to mess with custom clippings.
;it's because of graphical offset i made and object collision doesn't match.
ObjectCollisionOffset:
LDA !14D4,x
PHA
LDA !D8,x			;move collision slightly above
PHA				;
CLC : ADC #-$03
STA !D8,x			;

.DoIt
LDA !14D4,x			;
ADC #$FF			;
STA !14D4,x			;

JSL $019138|!BankB		;

.End
PLA				;
STA !D8,x			;
PLA				;
STA !14D4,x			;
RTS				;

UpdateSpds:
JSL $018022|!BankB		;update position horizontally
STA !1528,x			;

UpdateYSpd:
JSL $01801A|!BankB		;update position vertically
STA $1491|!Base2		;
RTS