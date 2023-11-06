;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Springboard disassembly by RussianMan
;; Modified by dtothefourth to add numbered multi hit functionality
;; 
;; Extension/Extra Byte - Number of hits, over 9 = infinite
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!LowYSpeed = $B0		;Y speed when not holding A or B when bouncing off it

!HighYSpeed = $80		;Y speed when bouncing off it with A or B. Do note that 80 is the maximum upward Y speed you can get. (1-7F are downward speed values)

!SoundEf = $08			;used for when bouncing on springy
!SoundBank = $1DFC		;

!DisappearSound = $08		;used for when springboard disappears
!DisappearBank = $1DF9		;

!NumberTile1 = #$23 ;0,1,2,3
!NumberTile2 = #$25 ;4,5,6,7
!NumberTile3 = #$27 ;9,inf

Tilemap:			;all those are 8x8
db $28,$28,$28,$28		;Normal
db $4C,$4C,$4C,$4C		;slightly pressed
db $83,$83,$6F,$6F		;pressed

XDisplay:
db $00,$08,$00,$08

YDisplay:
db $00,$00,$08,$08

Flips:
db $00,$40,$80,$C0

FrameToShow:
db $00,$01,$02,$02,$02,$01,$01,$00,$00

;offset when player's on springboard for "sinking" animation
MarioOnSpringOffset:
db $1E,$1B,$18,$18,$18,$1A,$1C,$1D,$1E

;used for "sinking" animation to displace tiles correctly

AdditionalYDisp:
db $00,$02,$00

;I'm not sure what are those tables, I'll document them later if I'll figure it all out

DATA_0197AF:
	db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
	db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
	db $E8,$E8,$E8,$00,$00,$00,$00,$FE
	db $FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0
	db $DC,$D8,$D4,$D0,$CC,$C8

DATA_01AB2D:
	db $01,$00,$FF,$FF

Print "MAIN ",pc
LDA !14C8,x
CMP #$08
BNE NumberOnly
PHB
PHK
PLB
JSR Springy
PLB
RTL
Print "INIT ",pc
LDA !extra_byte_1,x
STA !151C,x
RTL

NumberOnly:

%GetDrawInfo()			;
	
	LDA $0300|!Base2,y
	sta $0310|!Base2,y
	LDA $0301|!Base2,y
	sta $0311|!Base2,y
	LDA $0302|!Base2,y
	sta $0312|!Base2,y
	LDA $0303|!Base2,y
	sta $0313|!Base2,y


	lda $00 : sta $0300|!Base2,y
	lda $01 : sta $0301|!Base2,y
	lda #$33 : sta $0303|!Base2,y

	lda !151C,x
	cmp #$04
	bpl +

	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CLC
	ADC !NumberTile1
	sta $0302|!Base2,y

	bra ++
	+
	cmp #$08
	bpl +

	AND #$03
	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CLC
	ADC !NumberTile2
	sta $0302|!Base2,y

	bra ++
	+

	AND #$03
	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CMP #$15
	BMI +
	LDA #$14
	+
	CLC
	ADC !NumberTile3
	sta $0302|!Base2,y

	++

LDA #$04			;5 tiles
LDY #$00			;8x8 size
JSL $01B7B3|!BankB		;write 'em

RTL

Springy:
LDA $9D				;No freeze flag = do things
BEQ .Continue			;
JMP End			;don't do hella lot of things when freeze flag is set

.Continue
%SubOffScreen()			;original sprite doesn't actually despawn offscreen, because of CFG setting. So... what's point of this?
				;but I'll leave it as is. Uncheck "process when offscreen" if you want it to despawn.

LDA !151C,x
BNE NotDead

STZ !14C8,x		

LDA #$1B			
STA $02				
STZ $00				
STZ $01				
LDA #$01			
%SpawnSmoke()		

LDA #!DisappearSound		
STA !DisappearBank|!Base2	
RTS

NotDead:

JSL $01802A|!BankB		;gravity and etc. - check

LDA !1588,x			;check ground
AND #$04			;
BEQ .NotGround			;

JSR HandleXY			;handle "bouncy" gravity and interaction

.NotGround
LDA !1588,x			;check wall
AND #$03			;
BEQ .NotWall			;

;LDA !15AC,x			;timer for changing direction
;BNE .Skip			;

;LDA #$08			;i don't think it's needed
;STA !15AC,x			;

LDA !B6,x			;invert speed
EOR #$FF			;
INC				;
STA !B6,x			;

LDA !157C,x			;flip direction
EOR #$01			;
STA !157C,x			;

LDA !B6,x			;after inverting make it slightly slower?
ASL				;
PHP				;
ROR !B6,x			;
PLP				;
ROR !B6,x			;

.NotWall
LDA !1588,x			;check ceiling
AND #$08			;
BEQ .NotCeiling			;

STZ !AA,x			;reset Y-speed

.NotCeiling
LDA !1540,x			;if animation timer isn't set
BNE .OnIt			;don't do bouncing on it
JMP .NotOnIt			;branch out of bounds

;(fun (or not?) fact: it doesn't matter where spring board is at this rate, you can bounce off air if springboard isn't under you for whatever reason)
;(unless it disappears, like despawns or something)

.OnIt
LSR				;calculate Y-displacement
TAY				;
LDA $187A|!Base2		;check if on yoshi
CMP #$01			;Moderator changed this to LSR, but I restored it 'cause it offsets player on yoshi incorrectly while turning.
LDA MarioOnSpringOffset,y	;
BCC .NoADC			;
ADC #$11			;add to displacement

.NoADC
STA $00				;

LDA FrameToShow,y		;those are frames for sprite to show
STA !1602,x			;do small pressing and unpressing animation

LDA !D8,x			;displace Mario vertically
SEC : SBC $00			;
STA $96				;

LDA !14D4,x			;
SBC #$00			;
STA $97				;don't forget about high byte

STZ $72				;Reset "in the air" flag, aka "kinda" on ground
STZ $7B				;no X speed

LDA #$02			;
STA $1471|!Base2		;Mario stands on springboard

LDA !1540,x			;check if it's time to make actual bounce
CMP #$07			;
BCS .NoBounceYet		;(.End is too far)

STZ $1471|!Base2		;Mario's not on springboard anymore

LDY #!LowYSpeed			;
LDA $17				;check for A button
BPL .NoA			;

LDA #$01			;
STA $140D|!Base2		;set spinjump flag
BRA .Higher			;and make player bounce higher

.NoA
LDA $15				;if failed to check for A, then check for B
BPL .NoB			;

.Higher
LDA #$0B			;now make it so Mario's actually in the air
STA $72				;

LDY #$80			;set special RAM to make screen scroll vertically (if enabled to)
STY $1406|!Base2		;

If !HighYSpeed != $80		;if Y speed isn't default value 80
  LDY #!HighYSpeed		;we load new value then
endif				;

.NoB
STY $7D				;make player bounce

LDA #!SoundEf			;sound effect
STA !SoundBank|!Base2		;

LDA !1540,x
BNE +
LDA #$03
STA !1540,x
+
CMP #$01
BNE .NoBounceYet

DEC !151C,x

.NoBounceYet
BRA End			;

.NotOnIt
JSL $01A7DC|!BankB		;no, it actually uses 01A7F6. Of course it's a JSR routine.
BCC End			;which is illegal

STZ !154C,x			;

LDA !D8,x			;welp, it's a solid one
SEC : SBC $96			;
CLC : ADC #$04			;
CMP #$1C			;check if touching from below
BCC .NotBelow			;
BPL .AlmostEnd			;or from above

LDA $7D				;
BPL End			;

STZ $7D				;if touching from below and Mario moves upwards, act like ceiling of some sorts
BRA End			;but it doesn't works?

.NotBelow
BIT $15				;check XY
BVC .NotCarrying		;if not holding 'em, don't carry it

LDA $1470|!Base2		;if holding something already
ORA $187A|!Base2		;or on yoshi
BNE .NotCarrying		;can't carry it!

LDA #$0B			;make sprite carryable
STA !14C8,x			;

STZ !1602,x			;reset frame

.NotCarrying
JSR HandleSolidX		;handles horizontal solidity.
BRA End			;

.AlmostEnd
LDA $7D				;check if mario falls on it
BMI End			;

.RightSwitchState
LDA #$11			;make a small little bounce off it
STA !1540,x			;

End:
LDY !1602,x			;
LDA AdditionalYDisp,y		;displace tiles with bouncing animation in mind
;TAY				;ok, unecessary

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX routine goes here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:
;STY $0F			;
STA $0F

%GetDrawInfo()			;
;LDY $0F			;again, why messing with Y if we can load it into A?
;TYA				;

LDA $0F				;displace tiles if necessary
CLC				;
ADC $01				;
STA $01				;

LDA !1602,x			;get correct display index
ASL #2				;
STA $02				;

LDA !15F6,x			;
ORA $64				;
STA $03				;

;LDY !15EA,x			;reload Y index for sprite tiles (again, unecessary)

;LDA #$03			;
;STA $04			;04 was used for tiles loop, but we don't need it actually tbh.

	lda $00 : sta $0300|!Base2,y
	lda $01 : sta $0301|!Base2,y
	lda #$33 : sta $0303|!Base2,y

	lda !151C,x
	cmp #$04
	bpl +

	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CLC
	ADC !NumberTile1
	sta $0302|!Base2,y

	bra ++
	+
	cmp #$08
	bpl +

	AND #$03
	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CLC
	ADC !NumberTile2
	sta $0302|!Base2,y

	bra ++
	+

	AND #$03
	CMP #$02
	BMI +++
	CLC : ADC #$0E
	+++
	CMP #$15
	BMI +
	LDA #$14
	+
	CLC
	ADC !NumberTile3
	sta $0302|!Base2,y

	++
	INY #4



LDX #$03			;

Loop:
;LDX $04			;

LDA $00				;
CLC : ADC XDisplay,x		;
STA $0300|!Base2,y		;

LDA $01				;
CLC : ADC YDisplay,x		;
STA $0301|!Base2,y		;

PHX				;
TXA				;
CLC : ADC $02			;

TAX				;
LDA Tilemap,x			;
STA $0302|!Base2,y		;
PLX				;

;LDA $05			;before we had "general" GFX routine, so we had to calculate flips
;ASL #2				;
;ADC $04			;
;TAX				;
LDA Flips,x			;now we don't need to
ORA $03				;
STA $0303|!Base2,y		;

INY #4				;

;DEC $04			;
DEX				;
BPL Loop			;


	



LDX $15E9|!Base2		;original uses PHX PLX, but i replaced them for optimization sake

LDA #$04			;5 tiles
LDY #$00			;8x8 size
JSL $01B7B3|!BankB		;write 'em
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

HandleSolidX:
STZ $7B				;reset X speed
%SubHorzPos()			;
TYA				;
ASL				;
TAY				;
REP #$21			;
LDA $94				;
ADC DATA_01AB2D,y		;
STA $94				;
SEP #$20			;
RTS				;

HandleXY:
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

;LDA !9E,x			;check for goomba
;CMP #$0F			;we're certainly 100% not goomba, so we don't care
;BNE .NotGoomba

.NotGoomba
LDA DATA_0197AF,y		;
LDY !1588,x			;
BMI .Re				;
STA !AA,x			;

.Re
RTS