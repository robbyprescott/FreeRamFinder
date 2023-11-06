;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Springboard Disassembly (feature-rich version)
;This is a dissasembly of sprite 2F in SMW - Springboard.
;
;By RussianMan. Credit is optional.
; Edits by KnightOfTime, replacing separate cfgs/property bytes with extra bytes
;
;Extra bytes (1, 2, 3 respectively):

;04,00- no gravity
;00,01- forces a regular jump
;00,02- forces a spin jump
;10,00- gives limited bounces (1)
;40,00- no solid sides
;01,00- works either on On or Off
;00,00- original one
;08,00- disappears and reappears
;02,00- is stationary and can't be carried
;24,00- tracks Mario's X position
;
; Extra byte 3: Controls the palette the bubble has.							;
; 00 = Palette 8 (Mario) (000)
; 02 = Palette 9 (Grey) (001)
; 04 = Palette A (Yellow) (010)
; Palette B (Blue)
; Palette C (Red)
; 0A = Palette D (Green)
; Palette E
; Palette F 
;
; Former extra Property byte 1 options:
;
;Bit 0 - On/Off
;-Springboard will bounce you only on On/Off Switch being on or off (requested by Mario78)
;
;Bit 1 - Non-carryable (stationary)
;-Makes it so Springboard can't be carried
;
;Bit 2 - Floating
;-Disables any gravity, and automatically makes it stationary (no need for bit 1). Comes from imamelia's springboard pack.
;
;Bit 3 - Disappear and Reappear (NEW!)
;-Springboard will disappear after bouncing on it, but will reappear after a short amount of time (suggested by GreenHammerBro)
;
;Bit 4 - Limited use (previously define option)
;-Makes springboard use limited amount of bounces.
;Note that this option is ignored if bit 3 is enabled.
;
;Bit 5 - Track Player's X-position
;-Inspired by DKC3's "Tracker Barrel Trek"'s barrels, with this springboard with track player's X-position for limited range.
;Automatically makes it non-carryable (no need for bit 1). it's recommended to enable Bit 2, but not required.
;
;Bit 6 - Disable solid sides
;Disables solidity from sides (basically bit 1, except you can pass through it's sides. can still be picked up though, bit 1 is your friend).
;
;Extra Property byte 2 - Forced Jump/Spinjump
;0 - Don't force 
;1 - Force to normal jump off it
;2 - Force to spinjump off it
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!LowYSpeed = $B0		;Y speed when not holding A or B when bouncing off it

!HighYSpeed = $80		;Y speed when bouncing off it with A or B. Do note that 80 is the maximum upward Y speed you can get. (1-7F are downward speed values)

!SoundEf = $08			;used for when bouncing on springy
!SoundBank = $1DFC		;

!OnOffSwitch = 0		;0 - Allows to bounce off it on ON, 1+ - on OFF. (Requires Extra Byte 1 Bit 0)

!XSpeed = $00			;any non-zero value enables this, gives Mario X-speed, depending on facing. Comes from imamelia's springboard pack.
  !NoFacing = 0			;this option disables Facing-depending X-speed.

!LimitedUse = $01		;how many bounces player can perform. 0 counts as 1.

!ReappearTime = #$50		;how long it takes untill springboard reappears (Extra byte bit 3)

!DisappearSound = $10		;used for when springboard disappears (if either limited use or disappear option is enabled)
!DisappearBank = $1DF9		;

!TrackDistance = #$0070		;how far it can track player's position for tracking option. (Extra prop. byte bit 4)

!TrackFlag = !1534,x		;used for tracker to start X-position tracking.

!DisappearedFlag = !C2,x	;used with "Disappear and Reappear" option. set if sprite's invisible.

!Prop1Storage = !1570,x		;mirror of !extra_byte_1,x, saves 1 byte each time it's needed.

!OrigXPosLoStorage = !160E,x	;stores initial X-position for tracking
!OrigXPosHiStorage = !187B,x	;

!ReappearTimer = !1564,x	;timer 

XSpeedTbl:
db $00-!XSpeed,!XSpeed		;

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

Print "INIT ",pc
If not(!LimitedUse)		;\set quote on quote hitpoints.
  LDA #!LimitedUse+1		;|0 makes it disappear, but we don't want it to disappear in an instant
else				;|
  LDA #!LimitedUse		;|
endif				;|
STA !151C,x			;/

LDA !extra_byte_1,x		;
STA !Prop1Storage		;
AND #$20			;tracker spring will use these, otherwise they'd mess up everything with normal sprite
BEQ Nothing			;no glitch zone

LDA !E4,x			;
STA !OrigXPosLoStorage		;

LDA !14E0,x			;
STA !OrigXPosHiStorage		;
RTL				;

Print "MAIN ",pc
LDA !14C8,x
CMP #$08
BNE Nothing
PHB
PHK
PLB
JSR Springy
PLB
Nothing:
RTL

Dead:
STZ !14C8,x			;ded

Smoke:
LDA #$1B			;spawn smoke sprite
STA $02				;
STZ $00				;
STZ $01				;
LDA #$01			;
%SpawnSmoke()			;so it'll look like it disappears

LDA #!DisappearSound		;
STA !DisappearBank|!Base2	;sound effect

Return:
RTS

NonExistant:
LDA !ReappearTimer		;not time to reappear yet
BNE Return			;
STA !DisappearedFlag		;

BRA Smoke			;

Springy:
LDA !DisappearedFlag		;
BNE NonExistant			;

LDA $9D				;No freeze flag = do things
BEQ .Continue			;
JMP .End			;don't do hella lot of things when freeze flag is set

.Continue
%SubOffScreen()			;original sprite doesn't actually despawn offscreen, because of CFG setting. So... what's point of this?
				;but I'll leave it as is. Uncheck "process when offscreen" if you want it to despawn.

LDA !151C,x			;check if springboard shall perish from it's existance
BEQ Dead			;

LDA !Prop1Storage		;
AND #$20			;
BEQ .NoTrack			;

LDA !TrackFlag			;don't track if didn't bounce on once
BEQ .NoTrack			;

JSR TrackX			;track X-position

.NoTrack
LDA !Prop1Storage		;
AND #$04			;
BNE .NotCeiling			;skip all gravity shenanigans if set to

JSL $01802A|!BankB		;gravity and etc. - check

LDA !1588,x			;check ground
AND #$04			;
BEQ .NotGround			;

JSR HandleXY			;handle "bouncy" gravity and interaction

.NotGround
LDA !1588,x			;check wall
AND #$03			;
BEQ .NotWall			;

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
STA !TrackFlag			;it's easier to just store track flag without checking, which can waste more time checking property bit

LDA !1540,x			;check if it's time to make actual bounce
CMP #$07			;
BCS .NoBounceYet		;

STZ $1471|!Base2		;Mario's not on springboard anymore

LDY #!LowYSpeed			;

LDA !extra_byte_2,x		;check for forced jump option
BEQ .VanillaWay			;if not set, do it vanilla way
DEC				;
STA $140D|!Base2		;always (spin)jump from it

LDA $17				;check for A or B
ORA $15				;
BPL .NoB			;
BRA .Higher			;

.VanillaWay
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

If !XSpeed			;if allowed to give X-Speed
  If !NoFacing			;check if it should depend on player's direction
    LDA #!XSpeed		;if not, just give whatever speed needed
    STA $7B			;
  else				;
    LDY $76			;else load direcion
    LDA XSpeedTbl,y		;and with that direction in mind, load speed
    STA $7B			;store speed
  endif				;
endif				;

LDA #!SoundEf			;sound effect
STA !SoundBank|!Base2		;

LDA !Prop1Storage		;check if it should use timer for reappearing or "hitpoints"
AND #$18			;
BEQ .End			;

LDA !1540,x			;only decrease "use counter" on last possible frame
DEC				;
BNE .End			;so it won't decrease multiple times

LDA !Prop1Storage		;if should reappear
AND #$08			;do it
BEQ .NoDisappearCheck		;otherwise it should take a hit

LDA !ReappearTime		;
STA !ReappearTimer		;
STA !DisappearedFlag		;has disappeared flag enabled

JSR Smoke			;smokey thing

.NoBounceYet
BRA .End			;

.NoDisappearCheck
DEC !151C,x			;-1 hitpoint. HAHA.
BRA .End			;

.NotOnIt
JSR Interactio			;moved to subroutine to avoid out of bounds errors due to lengthy branches

.End
LDY !1602,x			;
LDA AdditionalYDisp,y		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX routine goes here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:
STA $0F				;

%GetDrawInfo()			;
LDA $0F				;
CLC				;
ADC $01				;
STA $01				;

LDA !1602,x			;
ASL #2				;
STA $02				;

;LDA !15F6,x			;
;ORA $64				;
;STA $03				;
LDA !extra_byte_3,x			;\ Palette extra byte for later 
ORA $64				;
STA $03				;

;LDA #$03			;
;STA $04			;04 was used for tiles loop, but we don't need it actually tbh.

LDX #$03			;

Loop:
;LDX $04

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

LDX $15E9|!Base2		;no comments*2

LDA #$03			;4 tiles
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

TrackX:
LDA !OrigXPosLoStorage		;store original X-positions
STA $00				;low byte

LDA !OrigXPosHiStorage		;
STA $01				;high byte

REP #$20			;
LDA $94				;if player didn't pass springboard's initial position
SEC : SBC $00			;
BCC .No2			;don't track
SEP #$20			;

LDA $95				;
STA !14E0,x			;
XBA				;Be at mario's X position!
LDA $94				;
STA !E4,x			;

REP #$20			;
SEC : SBC $00			;
BPL .NoInvertion		;
EOR #$FFFF			;
INC				;

.NoInvertion
CMP !TrackDistance		;can't go further tracking limit
BPL .No				;place at boundary

.No2
SEP #$20			;
RTS				;

.No
LDA $00				;original position + tracking distance
CLC : ADC !TrackDistance	;
SEP #$20			;
STA !E4,x			;\
XBA				;|keep sprite's position at it's traking boundary
STA !14E0,x			;/
RTS

Interactio:
JSL $01A7DC|!BankB		;no, it actually uses 01A7F6. Of course it's a JSR routine.
BCC .End			;which is illegal
STZ !154C,x			;

LDA !D8,x			;welp, it's a solid one
SEC : SBC $96			;
CLC : ADC #$04			;
CMP #$1C			;check if touching from below
BCC .NotBelow			;
BPL .AlmostEnd			;or from above

LDA $7D				;
BPL .End			;

STZ $7D				;if touching from below and Mario moves upwards, act like ceiling of some sorts
BRA .End			;but it doesn't works?

.NotBelow
LDA !Prop1Storage		;check if it should be stationary
AND #$26			;check if it's non-carryable, floating, or tracks X-position
BNE .NotCarrying		;act like stationary (can't be picked up) if any of those options are set

BIT $15				;check XY
BVC .NotCarrying		;if not holding 'em, don't carry it

LDA $1470|!Base2		;if holding something already
ORA $187A|!Base2		;or on yoshi
BNE .NotCarrying		;can't carry it!

LDA #$0B			;make sprite carryable
STA !14C8,x			;

STZ !1602,x			;reset frame

.NotCarrying
LDA !Prop1Storage		;disable solid sides
AND #$40			;
BNE .End			;

JSR HandleSolidX		;handles horizontal solidity.
RTS

.AlmostEnd
LDA $7D				;check if mario falls on it
BMI .End			;

LDA !Prop1Storage		;
AND #$01			;
BEQ .RightSwitchState		;

LDA $14AF|!Base2		;
If !OnOffSwitch			;
  BNE .RightSwitchState		;
else				;
  BEQ .RightSwitchState		;
endif				;
JSL $01B44F|!BankB		;be solid if can't bounce

.End
RTS

.RightSwitchState
LDA #$11			;make a small little bounce off it
STA !1540,x			;
RTS