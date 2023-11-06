; ------------------------- ;
;       Special Berry       ;
;        by JamesD28        ;
; ------------------------- ;

; Very slight modifications by SJC. (E.g. removed the INC on line 476 to make it use the first GFX page)

; Extra byte 1: Powerup to award.
	; $00: Coin. Extra byte 2 controls number of coins awarded.
	; $01: Fire shot. Extra byte 2 controls number of fire shots.
	; $02: Yoshi stomp. Extra byte 2 controls number of Yoshi stomps.
	; $03: Yoshi flight power. Extra byte 2 controls duration (value of 1 = 8 frames) of Yoshi flight.
	; $04: Add seconds to the timer. Extra byte 2 controls the number of seconds added.
	; $05: Change Yoshi type. Extra byte 2 controls the palette (and thus type) Yoshi will turn into. Recommended to only use 2-5.
	; $06: Trigger the goal sequence. Extra byte 2 controls the exit type (0 = normal exit, 1 = secret exit 1, 2 = secret exit 2, 3 = secret exit 3).
	; $07: Give a Yoshi Coin.
	; $08: Lay an egg with the Mushroom inside.
	; $09: Lay an egg with the coin game cloud inside.
	; $0A: Increment the "Red Berries" eaten counter.
	; $0B: Increment the "Pink Berries" eaten counter.

; Extra byte 2: Parameter for rewards that use one.

; Extra byte 3: Tile enable flag and palette. Format: !----ppp: binary, then convert to hex
	; !: If set, a warning tile will be drawn next to Yoshi when his limited-use powers are about to run out.
		; For fire shots and stomps, this will appear when he has 1 left.
		; For flight, this will appear when he has less than 2 (real time) seconds of flight left.
	; p: Palette.
	
	; 000 - Palette 8 (Mario)
	; 001 - Palette 9 (Grey)
	; 010 - Palette A (Yellow)
	; 011 - Palette B (Blue)
	; 100 - Palette C (Red)
	; 101 - Palette D (Green)
	; 110 - Palette E
	; 111 - Palette F 

	; So 1----100 (10000100 = hex 84) would set the warning tile and is custom yellow, which is on the C palette row. Custom red is 81. Custom blue is 85
	; For more format and conversion info: https://www.smwcentral.net/?p=viewthread&t=25106

; Extra byte 4: Initial X/Y offsets. Format: YYYYXXXX
	; Y: Y offset ($10 = 1 pixel down).
	; X: X offset ($01 = 1 pixel right).

; -------------------------

!AnimationRate = 3		; Berry's animation speed. 1 = fastest. 6 = slowest. Values higher than 6 will not animate properly.

!Frame1Tile = $80 ; 6D
!Frame2Tile = $C0 ; 46
!Frame3Tile = $C2 ; 48
!Frame4Tile = $C0 ; 46

!Screens = 2	; If Mario is more than this number of screens away from Yoshi, any power Yoshi has will be removed. Can prevent a permanently-filled sprite slot.

!WarningFrame = $1D		; Tile number to use if drawing a warning tile next to Yoshi. Default is the ! tile.
!WarningPalette = 4		; Palette for the warning tile.

!SFXAdd = $29			; SFX to use if the reward is extra time.
!SFXAddBank = $1DFC		; SFX Bank.

!GoalSong = $0C			; Song number (in $1DFB) to use for the goal sequence reward.

!FireballXSpeed = $28	; X speed for the fireballs Yoshi shoots if awarded fire shot power.
!FireballYSpeed = $00	; Y speed for the fireballs Yoshi shoots if awarded fire shot power.

Frames:
db !Frame1Tile,!Frame2Tile,!Frame3Tile,!Frame4Tile

; -------------------------

print "INIT ",pc

LDA !extra_byte_4,x		;/
PHA						;|
AND #$0F				;|
CLC						;|
ADC !E4,x				;|
STA !E4,x				;|
LDA !14E0,x				;|
ADC #$00				;|
STA !14E0,x				;| Initial X and Y offsets for the Berry, if applicable.
						;|
PLA						;|
LSR #4					;|
CLC						;|
ADC !D8,x				;|
STA !D8,x				;|
LDA !14D4,x				;|
ADC #$00				;|
STA !14D4,x				;\

RTL

; -------------------------

print "MAIN ",pc
PHB
PHK
PLB
JSR Main
PLB
RTL

Return2:
RTS

Main:

LDA !C2,x				;/
BEQ +					;|
JMP PowerActive			;| Jump to power handling if the Berry is in it's "active power" state.
+						;\

JSR Graphics			; It's not really a Berry in it's "active power" state, so no graphics are drawn for the sprite if in that state.

LDA $9D					;/
ORA !15D0,x				;| Return if sprites locked, the sprite is on Yoshi's tongue, or the goal sequence is active.
ORA $1493|!addr			;|
BNE Return2				;\

%SubOffScreen()

LDY $18E2|!addr			;/
BEQ Return2				;\ Return if there isn't a Yoshi spawned.
LDA !160E-1,y			;/
CMP #$FF				;| Return if there's already a sprite on Yoshi's tongue.
BNE Return2				;\
LDA $187A|!addr			;/
BEQ .Return				;\ Return if not riding Yoshi.
LDA !1594-1,y			;/ Return if Yoshi's mouth is in one of the open phases.
BNE .Return				;\ Remove these two lines and directly eat a Berry sprite while Yoshi's tongue is out for funny jank

DEY
TYX

LDY !157C,x				;/
LDA !E4,x				;|
PHA						;|
CLC						;|
ADC YoshiHeadXLo,y		;|
STA !E4,x				;|
LDA !14E0,x				;|
PHA						;|
ADC YoshiHeadXHi,y		;|
STA !14E0,x				;|
LDA !D8,x				;|
PHA						;| Modify Yoshi's clipping to be a (roughly) 8x8 square centered on Yoshi's head.
CLC						;| This probably isn't the most efficient but for some reason setting the clippings in scratch RAM manually didn't work.
ADC #$08				;|
AND #$F0				;|
STA !D8,x				;|
LDA !14D4,x				;|
PHA						;|
ADC #$00				;|
STA !14D4,x				;|
LDA !1662,x				;|
PHA						;|
LDA #$39				;|
STA !1662,x				;\

JSL $03B69F|!BankB		; Get clippings in scratch RAM.

PLA						;/
STA !1662,x				;|
PLA						;|
STA !14D4,x				;|
PLA						;| Restore Yoshi's default clipping and position.
STA !D8,x				;|
PLA						;|
STA !14E0,x				;|
PLA						;|
STA !E4,x				;\

LDX $15E9|!addr			;/
JSL $03B6E5|!BankB		;\ Get clippings for the Berry.
JSL $03B72B|!BankB		;/
BCC .Return				;\ Return if no contact.

LDA #$07				;/
STA !14C8,x				;\ Set to "in mouth" status. The MOUTH routine will handle giving the actual reward.
LDA #$08				;/
STA !1540,x				;\ Set the "player freeze" timer.
LDA $7B					;/
STA !151C,x				;|
LDA $7D					;| Backup the player's X and Y speed for when unfrozen.
STA !1528,x				;\
.Return
RTS

YoshiHeadXLo:
	db $08,$F8

YoshiHeadXHi:
	db $00,$FF

; -------------------------

PowerActive:

LDA $9D					;/
BNE KillPower_Return	;\ Return if locked.

LDY $18E2|!addr			;/
BEQ KillPower			;\ Kill the power sprite if there's no longer a Yoshi spawned.

LDA $94			;/
STA !E4,x		;|
LDA $95			;|
STA !14E0,x		;|
LDA $96			;| Lock the power sprite to Mario's position, so Mario can dismount and leave Yoshi behind without the power being lost.
STA !D8,x		;|
LDA $97			;|
STA !14D4,x		;\

LDA !14E0-1,y			;/
XBA						;|
LDA.w !E4-1,y			;|
REP #$20				;|
SEC						;|
SBC $94					;| However, kill the sprite if it (and thus Mario) is more than the defined number of screens away from Yoshi. The idea of having this is to allow
BPL +					;| the player to abandon Yoshi without using up the power, without then having a sprite slot permanently stuck to Mario for the rest of the level.
EOR #$FFFF				;|
INC						;|
+						;|
CMP.w #!Screens*256		;|
SEP #$20				;|
BCS KillPower			;\

LDA !C2,x
DEC
ASL
TAX
JMP (Powers,x)

KillPower:
STZ !14C8,x				; Kill the power sprite.
.Return
RTS

Powers:					; This has potential for some cool future expansion powers, but the request only needed these 3 and I couldn't immediately think of other ideas.
dw FireShot
dw Stomp
dw Flight

FireShot:
LDX $15E9|!addr

LDA !1504,x				;/
CMP #$01				;|
BNE .NoGFX				;|
LDA !extra_byte_3,x		;| If on the last fire shot, draw the warning tile next to Yoshi if enabled.
BPL .NoGFX				;|
JSR WarningGFX			;|
.NoGFX					;\

LDA $187A|!addr			;/
BEQ .End				;\ Return if not on Yoshi.
LDA $16					;/
ORA $18					;|
AND #$40				;| If X or Y hasn't just been pressed, don't fire a shot.
BEQ .End				;\

STZ $14A3|!addr			; Zero the timer that changes Mario's pose for hitting Yoshi. Note that the pose will still appear for a frame, but this usually isn't noticeable.

LDX $18E2|!addr
LDY !157C-1,x			;/
LDA !E4-1,x				;|
CLC						;|
ADC FireXLoOffset,y		;|
STA $00					;| Fire's X offset from Yoshi depending on his direction.
LDA !14E0-1,x			;|
ADC FireXHiOffset,y		;|
STA $01					;\

JSR ShootFire			; Shoot fireball.

LDA #$10				;/
STA !1558-1,x			;|	
LDA #$03				;| Set Yoshi's mouth to the spitting phase.
STA !1594-1,x			;\

LDX $15E9|!addr

LDA #$17				;/
STA $1DFC|!addr			;\ Fireball SFX.

DEC !1504,x				;/
BEQ KillPower			;\ Reduce the shots counter, and kill the power sprite if out of shots.

.End
RTS

ShootFire:
PHK						;/
PEA.w .Return-1			;|
PEA $80C9				;| Find a free extended sprite slot.
JML $018EEF|!BankB		;\
.Return

LDA #$11				;/
STA $170B|!addr,y		;|
LDA $00					;|
STA $171F|!addr,y		;|
LDA $01					;|
STA $1733|!addr,y		;|
LDA !D8-1,x				;|
STA $1715|!addr,y		;|
LDA !14D4-1,x			;|
STA $1729|!addr,y		;|
LDA #$00				;|
STA $1779|!addr,y		;| Setup fireball position and speed.
LDA !157C-1,x			;|
LSR						;|
LDA #!FireballXSpeed	;|
BCC +					;|
EOR #$FF				;|
INC A					;|
+						;|
STA $1747|!addr,y		;|
LDA #!FireballYSpeed	;|
STA $173D|!addr,y		;|
LDA #$A0				;|
STA $176F|!addr,y		;\
RTS

FireXLoOffset:
db $10,$F0

FireXHiOffset:
db $00,$FF

; -------------------------

Stomp:

LDX $15E9|!addr

LDA !1504,x				;/
CMP #$01				;|
BNE .NoGFX				;|
LDA !extra_byte_3,x		;| If on the last stomp, draw the warning tile next to Yoshi if enabled.
BPL .NoGFX				;|
JSR WarningGFX			;|
.NoGFX					;\

LDA $187A|!addr			;/
BEQ .End				;\ Return if not riding Yoshi.

LDA !1510,x				;/
BNE .CheckStomp			;\ Set when the player is in the air, then cleared when they land.

LDA $77					;/
AND #$04				;|
BNE .DontSetFlag		;| If the player is in the air (not blocked from below), set the air flag.
INC !1510,x				;|
.DontSetFlag			;\
RTS

.CheckStomp
LDA $77					;/
AND #$04				;| Don't stomp if the player hasn't just landed.
BEQ .End				;\

PHB						;/
LDA #$00				;|
PHA						;|
PLB						;|
PHK						;| We kinda jump to the middle of the player-ground routine where the Yoshi stomp happens, but we have to skip the check for $18E7.
PEA .Return-1			;| We don't just use $18E7 because it gets cleared by Yoshi each frame then uses the shell in his mouth to determine whether it should be set again.
PEA $F05A				;| That would be fine if the Berry power code ran after Yoshi, but that's not guaranteed because it depends on their sprite slots.
JML $00EF8C|!BankB		;|
.Return					;|
PLB						;\
LDX $15E9|!addr

STZ !1510,x				; Reset the air flag to prevent consecutive stomps every frame the player is on the ground.
DEC !1504,x				;/
BNE .End				;| Decrement the stomps counter, and kill the sprite if out of stomps.
STZ !14C8,x				;\
.End
RTS

; -------------------------

Flight:

LDX $15E9|!addr
LDA $14					;/
AND #$07				;|
BNE +					;|
DEC !1504,x				;| Decrement the flight counter once every 8 frames, and kill the power sprite if out of flight time.
BNE +					;|
STZ !14C8,x				;|
RTS						;\
+
LDA !1504,x				;/
CMP #$10				;|
BCS .NoGFX				;| If enabled, draw the warning tile next to Yoshi if there's 15x8=120 frames (2 seconds) or less left of flight time.
LDA !extra_byte_3,x		;|
BPL .NoGFX				;|
JSR WarningGFX			;\
.NoGFX

PHB						;/
LDA $187A|!addr			;|
BEQ .Return				;|
LDA #$00				;|
PHA						;|
PLB						;|
PHK						;| Run the flight routine.
PEA .Return-1			;|
PEA $E383				;|
LDA #$02				;|
STA $1410|!addr			;|
STA $141E|!addr			;|
JML $00D7E4|!BankB		;\
.Return

LDA #$01
PHA
PLB
PHK
PEA .Return2-1
PEA $F75A
LDX $18E2|!addr
DEX
if !SA1					;/
TXA						;|
CLC						;|
ADC.b #!E4				;|
STA $EE					;|
LDA.b #!E4/256			;|
ADC #$00				;|
STA $EF					;| Yoshi's XLo and YLo positions haven't yet been stored in the pointers for SA-1's remap, so we have to do that ourselves or the wings will be
TXA						;| at the wrong position relative to Yoshi.
CLC						;|
ADC.b #!D8				;|
STA $CC					;|
LDA.b #!D8/256			;|
ADC #$00				;|
STA $CD					;|
endif					;\
JML $01EEE6|!BankB		; Draw wings on Yoshi.
.Return2
PLB

LDX $15E9|!addr
RTS

; -------------------------

Graphics:

LDA !extra_byte_3,x		;/
AND #$07				;|
ASL						;| Preserve the palette.
STA $02					;\

%GetDrawInfo()

LDA $00
STA $0300|!addr,y
LDA $01
STA $0301|!addr,y

LDA $14
LSR #!AnimationRate		; More LSRs = slower animation.
AND #$03
TAX
LDA Frames,x
STA $0302|!addr,y

LDA $02
;INC
ORA $64
STA $0303|!addr,y

LDX $15E9|!addr
LDA #$00
LDY #$02
%FinishOAMWrite()
RTS

WarningGFX:

LDA !E4,x		;/
STA $03			;|
LDA !14E0,x		;|
STA $04			;|
LDA !D8,x		;| GetDrawInfo's yucky return will cause a crash if we try to put these on the stack, so we put them in scratch instead.
STA $05			;|
LDA !14D4,x		;|
STA $06			;\

LDY $18E2|!addr		;/
DEY					;|
LDA.w !E4,y			;|
STA !E4,x			;|
LDA !14E0,y			;|
STA !14E0,x			;| Dupe GetDrawInfo into getting the offsets for Yoshi.
LDA.w !D8,y			;|
STA !D8,x			;|
LDA !14D4,y			;|
STA !14D4,x			;\

%GetDrawInfo()

LDX $18E2|!addr		;/
LDA !157C-1,x		;|
TAX					;|
					;|
LDA $00				;| X offset indexed by Yoshi's direction.
CLC					;|
ADC XOffsets,x		;|
STA $0300|!addr,y	;\
LDA $01				;/
DEC					;|
DEC					;| Puts the tile just above Yoshi's nose.
STA $0301|!addr,y	;\

LDA #!WarningFrame
STA $0302|!addr,y

LDA #!WarningPalette*2
ORA $64
STA $0303|!addr,y

LDX $15E9|!addr
LDA #$00
TAY
%FinishOAMWrite()

LDA $06
STA !14D4,x
LDA $05
STA !D8,x
LDA $04
STA !14E0,x
LDA $03
STA !E4,x

RTS

XOffsets:
db $14,$F4

; -------------------------

print "MOUTH ",pc

LDA $187A|!addr		;/
BEQ ++				;|
LDA !1540,x			;|
BEQ ++				;|
DEC					;|
BEQ +				;|
STZ $7B				;|
STZ $7D				;|
LDY $18E2|!addr		;|
BEQ +++				;| This ugly blob handles freezing Mario and making Yoshi open his mouth when eating a Berry sprite directly, like with Berry objects.
LDA #$03			;| While this is running, the actual reward won't be given until this has ended.
STA !1594-1,y		;|
+++					;|
RTL					;|
+					;|
LDA !151C,x			;|
STA $7B				;|
LDA !1528,x			;|
STA $7D				;|
RTL					;\
++

LDY $18E2|!addr		;/
BEQ Return			;\ Return if there's no Yoshi. Might not be needed, but maybe if Yoshi despawns the same frame he eats a Berry?
STZ $18AC|!addr		;/
LDA #$00			;|
STA !1564-1,y		;| Zero Yoshi's swallow timer and mark his mouth as empty.
DEC					;|
STA !160E-1,y		;\

LDA #$06			;/
STA $1DF9|!addr		;\ Swallow SFX.

LDA !extra_byte_1,x
ASL
TAX
JMP (Rewards,x)

Rewards:

dw GiveCoins
dw GiveFireShot
dw GiveStomp
dw GiveFlight
dw GiveTime
dw GiveYoshiColour
dw GiveGoal
dw GiveYoshiCoin
dw GiveCoinCloud
dw GiveMushroomEgg
dw GiveRedBerry
dw GivePinkBerry

GiveCoins:
LDX $15E9|!addr
LDA !extra_byte_2,x		;/
JSL $05B329|!BankB		;\ Give the number of coins set in extra byte 2.
STZ !14C8,x
Return:
RTL

; -------------------------

GiveFireShot:
GiveStomp:
GiveFlight:
JSR ClearOtherPowers
LDX $15E9|!addr
LDA !extra_byte_1,x		;/
STA !C2,x				;|
LDA !extra_byte_2,x		;|
BNE +					;| Enabling the limited powers is pretty much just setting the respective value in C2 and setting the fire/stomps/flight counter.
INC						;|
+						;|
STA !1504,x				;|
LDA #$08				;|
STA !14C8,x				;\ The actual power is then handled in the normal sprite status.
RTL

; -------------------------

GiveTime:				; Shamelessly ripped from my +/- clocks.

LDX $15E9|!addr
LDA $0F31|!addr
ORA $0F32|!addr
ORA $0F33|!addr
PHP
LDA !extra_byte_2,x
-
CMP #$64
BCC Tens
SBC #$64
INC $0F31|!addr
LDY $0F31|!addr
CPY #$0A
BCS MaxTime
BRA -

Tens:
-
CMP #$0A
BCC Ones
SBC #$0A
INC $0F32|!addr
LDY $0F32|!addr
CPY #$0A
BCC -
STZ $0F32|!addr
INC $0F31|!addr
LDY $0F31|!addr
CPY #$0A
BCC -

MaxTime:
LDA #$09
STA $0F31|!addr
STA $0F32|!addr
STA $0F33|!addr
LDA #$28
STA $0F30|!addr
BRA AddSFX

Ones:
ADC $0F33|!addr
CMP #$0A
BCC +
SBC #$0A
STA $0F33|!addr
INC $0F32|!addr
LDA $0F32|!addr
CMP #$0A
BCC AddSFX
STZ $0F32|!addr
INC $0F31|!addr
LDA $0F31|!addr
CMP #$0A
BCS MaxTime
BRA AddSFX
+
STA $0F33|!addr

AddSFX:
PLP
BNE +
LDA #$28
STA $0F30|!addr
+
LDA #!SFXAdd
STA !SFXAddBank|!addr
STZ !14C8,x
RTL

; -------------------------

GiveYoshiColour:
LDX $15E9|!addr
LDA !extra_byte_2,x		;/
AND #$07				;|
ASL						;|
STA $00					;|
LDA !15F6-1,y			;| Change Yoshi's palette (and thus his type). Doesn't check if it's actually a valid vanilla Yoshi colour.
AND #$F1				;|
ORA $00					;|
STA !15F6-1,y			;\
STZ !14C8,x
RTL

; -------------------------

GiveGoal:
LDX $15E9|!addr			;/
LDA #$FF				;|
STA $1493|!addr			;| Trigger the level end sequence.
STA $0DDA|!addr			;|
LDA !extra_byte_2,x		;|
AND #$03				;|
STA $141C|!addr			;| Exit type determined by extra byte 2.
LDA #!GoalSong			;|
STA $1DFB|!addr			;\ Goal music.
STZ !14C8,x
RTL

; -------------------------

GiveYoshiCoin:
LDX $15E9|!addr
STZ !14C8,x

JSL $00F377|!BankB		;/
INC.W $1422|!addr		;|
LDA.W $1422      		;|
CMP.B #$05       		;|
BCC ++					;|
PHX              		;|
						;|
LDA $13BF|!addr			;|
LSR						;|
LSR						;|
LSR						;|
TAY						;|
LDA $13BF|!addr			;| Give a Yoshi coin and handle the checks for all 5 being collected.
AND #$07				;|
TAX						;|
LDA.L $05B35B|!BankB,x	;|
						;|
ORA.W $1F2F|!addr,y		;|
STA.W $1F2F|!addr,y		;|
PLX						;|
++						;|
LDA #$1C				;|
STA $1DF9|!addr			;|
LDA.B #$01				;|
JML $05B330|!BankB		;\

; -------------------------

GiveMushroomEgg:
GiveCoinCloud:
LSR						;/
SEC						;|
SBC #$08				;|
TAX						;|
GiveBerryAward:			;| Get the index to the berry type and give the respective reward (Mushroom for red berries, coin game cloud for pink).
LDA BerryAwards,x		;|
STA $18DA|!addr			;|
LDA #$20				;|
STA $18DE|!addr			;|
STZ $18D4|!addr,x		;\
LDX $15E9|!addr
STZ !14C8,x
RTL

BerryAwards:
db $74,$6A

BerryAmounts:
db $0A,$02

; -------------------------

GiveRedBerry:
GivePinkBerry:
LSR						;/
SEC						;|
SBC #$0A				;| Get index for red or pink berry.
TAX						;\
LDA $18D4|!addr,x		;/
INC A					;|
STA $18D4|!addr,x		;| Increment the respective berry counter, and give a reward if the required amount is reached (10 for red berries, 2 for pink).
CMP BerryAmounts,x		;|
BCS GiveBerryAward		;\
LDX $15E9|!addr
STZ !14C8,x
RTL

; -------------------------

ClearOtherPowers:		; Erases any other Berry sprites with an active power, to prevent an ability from running several times per frame.
						; It also prevents having multiple abilities simultaneously, so Yoshi can only have the power of the most recently eaten Berry.
LDX $15E9|!addr

LDA !7FAB9E,x
STA $00

LDX #!SprSize-1

.loop
CPX $15E9|!addr			;/
BEQ .Next				;\ Skip if it's this sprite.
LDA !7FAB9E,x			;/
CMP $00					;|
BNE .Next				;|
LDA !7FAB10,x			;| Skip if the sprite isn't a custom Berry sprite.
AND #$08				;|
BEQ .Next				;\

LDA !C2,x				;/
BEQ .Next				;\ Skip if the sprite's Berry power isn't active.

STZ !14C8,x				; Erase the sprite.

.Next
DEX
BPL .loop
RTS