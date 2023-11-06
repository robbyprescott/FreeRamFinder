;NOT AN ACTUAL SHOOTER, it's a normal sprite
;Extra Byte 1 - Extended Sprite Number (add +$13 for a custom sprite, for example custom extended sprite 2 would be $15)
;Extra Byte 2 - Timer between each shot
;Extra Byte 3 - X-speed
;Extra Byte 4 - Y-speed
;Extra Byte 5 - Extra Properties:
;Bit 0 - Aimed, will only take extra byte 3 as aimed speed
;Bit 1 - Extended sprite direction based on player's position, if enabled, will invert speed to make the sprite go in player's direction (like vanilla bullet shooter), x-speed only
;        Bit 0 must be disabled. If speed is between 1 to 7F, the projectile will face the player, otherwise the projectile will be shot facing away
;Bit 2 - same as above but will invert Y-speed instead (if set or applicable)
;Bit 3 - Don't spawn smoke upon shooting
;Bit 4 - Ignore player proximity
;Bit 5 - No Sound Effect
;
;Extra Bit - if not set, will assume the extended sprite is 8x8 and offset it appropriatly, if set, assume it's 16x16.

!ShootSnd = $09
!ShootBnk = $1DFC|!addr

!HorzProximity = $0020			;how close the player should be for it to not shoot (ignored on bit 4)

;DONT CHANGE THESE
!ExtSprNum = !C2,x
;!Timer = !1540,x
!Timer = !1602,x			;manual
!TimerStore = !1570,x
!XSpd = !B6,x
!YSpd = !AA,x
!Props = !1504,x
!ExBit = !151C,x

Print "INIT ",pc
LDA !extra_byte_1,x			;set up indirect addressing to access extra byte tables
STA $00					;

LDA !extra_byte_2,x			;
STA $01					;

LDA !extra_byte_3,x			;
STA $02					;

LDY #$00
LDA [$00],y
STA !ExtSprNum

INY
LDA [$00],y
STA !Timer
STA !TimerStore

INY
LDA [$00],y
STA !XSpd

INY
LDA [$00],y
STA !YSpd

INY
LDA [$00],y
STA !Props

LDA !extra_bits,x
AND #$04
STA !ExBit
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Spawn
PLB
RTL

Spawn:
%GetDrawInfo()				;be there

LDA !14C8,x				;I doubt it can be killed, but just in case
EOR #$08
ORA $9D
ORA !15A0,x				;can't shoot offscreen (most extended sprites can't exist offscreen anyway, and this makes it closer to the standard shooter sprites)
ORA !186C,x
BNE .Re
%SubOffScreen()

LDA !Timer				;timer expired?
BEQ .Shoot

DEC !Timer				;-1 time unit

.Re
RTS

.Shoot
LDA !TimerStore				;restore timer
STA !Timer

LDA !Props				;proximity check
AND #$10
BNE .NoProximity

LDA.b #!HorzProximity			;check if the player is close enough
STA $00					;
LDA.b #!HorzProximity>>8		;
STA $01					;

%ProximityHorz()
BCC .Re					;close = return

.NoProximity
LDA !Props				;smoke check
AND #$08
BNE .NoSmoke

;Common combination:
		STZ $00 : STZ $01
		LDA #$1B : STA $02
		LDA #$01
		%SpawnSmoke()

.NoSmoke
LDA !Props				;sound check
AND #$20
BNE .NoSOUND

LDA #!ShootSnd				;sound effect
STA !ShootBnk

.NoSOUND
JSR SetExtSprPositionOffset

LDA !Props				;aim check
LSR
BCC .NotAimed

LDA $01
STA $02

STZ $01
STZ $03

LDA !14E0,x				;xpos aim
XBA
LDA !E4,x
REP #$20
CLC : ADC $00
SEC : SBC $94
STA $00
SEP #$20

LDA !14D4,x				;y-pos aim
XBA
LDA !D8,x
REP #$20
CLC : ADC $02
SEC : SBC $96
SBC #$0010				;aim at the body!
STA $02
SEP #$20

LDA !XSpd				;extra byte 3
%Aiming()

LDA $02					;output y-speed
STA $03					;input y-speed

LDA $00					;output x-speed
STA $02					;input x-speed

JSR SetExtSprPositionOffset		;restore position offset
BRA .Spawn

.NotAimed
LSR					;player relative x-speed check
BCC .StoreX

%SubHorzPos()				;player's to the right or to the left?
TYA
BEQ .StoreX

LDA !XSpd
EOR #$FF
INC
BRA .ActualStoreX

.StoreX
LDA !XSpd

.ActualStoreX
STA $02

LDA !Props				;player relative y-speed check
AND #$04
BEQ .StoreY

;the routine does not account for the player's height, so we're gonna do that manually (so it doesn't treat player as above if they're physically not above when small)
LDA $19
BNE .Default

LDA $96
PHA
CLC : ADC #$10				;don't check for 16x16 block of air above player
STA $96

LDA $97
PHA
ADC #$00
STA $97

%SubVertPos()				;I could've just copy-pasted SubVertPos and modify it appropriately, but just in case of future proofing (in case it magically changes in 200 years and this sprite becomes incompatible)
PLA
STA $97
PLA
STA $96
BRA .CheckHighOrLow

.Default
%SubVertPos()				;player higher or lower?

.CheckHighOrLow
TYA
BEQ .StoreY

LDA !YSpd
EOR #$FF
INC
BRA .ActualStoreY

.StoreY
LDA !YSpd

.ActualStoreY
STA $03

.Spawn
LDA !ExtSprNum
%SpawnExtended()

LDA #$00
STA $1765|!addr,y			;misc RAM
STA $176F|!addr,y			;timer (maybe use another extra byte for that?)
STA $1779|!addr,y			;behind layers flag
STA $1751|!addr,y			;\fraction bits (just in case+should make movement consistent)
STA $175B|!addr,y			;/
RTS

SetExtSprPositionOffset:
LDA !ExBit				;if extra bit set, offset it like 16x16
BNE .Is16x16

LDA #$04				;center like 8x8
STA $00
STA $01
RTS

.Is16x16
STZ $00
STZ $01
RTS