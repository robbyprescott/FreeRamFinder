; -------------------- ;
; Podoboo Buoyancy Fix ;
;     by JamesD28      ;
; -------------------- ;

!UseMap16 = 1		; 1 = Podoboo will look down for the first Map16 tile that isn't air ($0025) to use as it's spawn position.
					; 0 = Podoboo will use just below the screen as it's spawn position (fixed to the screen position at the point this code runs).

!SplashNoBuoyancy = 1		; If set, the Podoboo will generate a lava splash even if it's not landing in liquid (including if buoyancy is disabled).

; --------------------

if read1($00FFD5) == $23
	sa1rom
	!SA1 = 1
	!addr = $6000
	!bank = $000000
	!AA = $9E
	!C2 = $D8
	!D8 = $3216
	!E4 = $322C
	!14C8 = $3242
	!14D4 = $3258
	!14E0 = $326E
	!1504 = $74F4
	!1510 = $750A
	!151C = $3284
	!1528 = $329A
	!1540 = $32C6
	!164A = $75BA
else
	lorom
	!SA1 = 0
	!addr = $0000
	!bank = $800000
	!AA = $AA
	!C2 = $C2
	!D8 = $D8
	!E4 = $E4
	!14C8 = $14C8
	!14D4 = $14D4
	!14E0 = $14E0
	!1504 = $1504
	!1510 = $1510
	!151C = $151C
	!1528 = $1528
	!1540 = $1540
	!164A = $164A
endif

if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
	!EXLEVEL = 1
else
	!EXLEVEL = 0
endif

; --------------------

ORG $01E05B
autoclean JML PodobooInit		; Fix the actual crash by ensuring the loop is always terminated eventually.
NOP

if !SplashNoBuoyancy
ORG $01E0A1
autoclean JML Splash
NOP
elseif read1($01E0A1) == $5C
autoclean read3($01E0A2)
ORG $01E0A1
LDA #$27
STA $1DFC|!addr
endif

ORG $01E0CB
autoclean JML PodobooMain		; Handle the position for where the Podoboo should "land".
NOP #2

; --------------------

freecode

PodobooInit:

LDA $190E|!addr
AND #$C0
PHA						; Push the buoyancy settings onto the stack to making reading them easier.

if !UseMap16
LDY #$20				;/
.loop					;|
LDA $01,s				;|
BNE +					;|
DEY						;| If using the Map16 option, limit the search to 32 tiles down as a failsafe in case there's no non-air tiles.
BMI .Abort				;|
+						;|
else					;|
.loop					;\
endif

LDA !D8,x				;/
CLC						;|
ADC #$10				;| Move Podoboo a tile down.
STA !D8,x				;|
LDA !14D4,x				;|
ADC #$00				;|
STA !14D4,x				;\
LDA $01,s				;/
BEQ .NoBuoyancy			;\ Check the buoyancy settings.

PHY						;/
JSL $019138|!bank		;|
PLY						;|
LDA !164A,x				;| Use the vanilla method if buoyancy is enabled.
BEQ .loop				;|
BRA .Found				;\

.preloopjump
SEP #$20
BRA .loop

.NoBuoyancy
if !UseMap16			;/ If !UseMap16 = 1
PHY						;|
JSR GetMap16			;|
XBA						;|
TYA						;|
XBA						;| Get the Map16 tile at the sprite's position and check if it's air. If it's not, we've found a spawn position.
PLY						;|
REP #$20				;|
CMP #$0025				;|
SEP #$20				;|
BEQ .loop				;\

else

LDA !14D4,x				;/ If !UseMap16 = 0
XBA						;|
LDA !D8,x				;|
REP #$20				;|
SEC						;|
SBC $1C					;| If the Podoboo's position is just below the screen, use this as the spawn position.
BMI .preloopjump		;|
CMP #$00F0				;|
SEP #$20				;|
BCC .loop				;\

endif

.Found
PLA
LDA #$20
STA !1540,x
LDA !D8,x			;/
STA !1504,x			;|
LDA !14D4,x			;| Use $1504 and $1510 to track where the Podoboo initially spawns from.
STA !1510,x			;\
JML $01E0E2|!bank

if !UseMap16
.Abort
PLA					;/
STZ !14C8,x			;| Kill the Podoboo and return if we didn't find a non-air tile after 32 checks.
JML $01E07A|!bank	;\
endif

; --------------------

if !SplashNoBuoyancy
Splash:
LDA #$27
STA $1DFC|!addr
LDA $190E|!addr
AND #$C0
BNE .NoSplash
LDA #$02
STA $00
JSL $028528|!bank
.NoSplash
JML $01E0A6|!bank
endif

; --------------------

PodobooMain:

LDA !C2,x				;/
BNE .Buoyancy			;\ Use vanilla method if this is actually a Bowser fireball (they break otherwise).

LDA $190E|!addr			;/
AND #$C0				;| If buoyancy is enabled, use the original method of checking if the Podoboo is in liquid.
BNE .Buoyancy			;\

LDA !1504,x				;/
STA $00					;|
LDA !1510,x				;|
STA $01					;|
LDA !14D4,x				;|
XBA						;|
LDA !D8,x				;|
REP #$20				;| Return if the Podoboo isn't vertically within 4 pixels either way of it's spawn position.
SEC						;| In theory, this range should always catch the Podoboo every frame even if it's moving at it's max vertical speed of #$70.
SBC $00					;|
CLC						;|
ADC #$0004				;|
CMP #$0008				;|
SEP #$20				;|
BCS .NotYet				;\
LDA !AA,x				; Return if the Podoboo is moving upwards.
BMI .NotYet
if !SplashNoBuoyancy
LDA #$02
STA $00
JSL $028528|!bank
endif
JML $01E0D7|!bank

.Buoyancy
JSL $019138|!bank
LDA !164A,x
BEQ .NotYet
LDA !AA,x				; Return if the Podoboo is moving upwards.
BMI .NotYet
JML $01E0D7|!bank

.NotYet
JML $01E106|!bank

; --------------------

if !UseMap16
GetMap16:		; PIXI's GetMap16 routine.
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B
	STZ $1933|!addr
	PHX
	PHP
	REP #$10
	PHB
	LDY $98
	STY $0E
	LDY $9A
	STY $0C
	SEP #$30
	LDA $5B
	LDX $1933|!addr
	BEQ .layer1
	LSR A
.layer1
	STA $0A
	LSR A
	BCC .horz
	LDA $9B
	LDY $99
	STY $9B
	STA $99
.horz
if !EXLEVEL
	BCS .verticalCheck
	REP #$20
	LDA $98
	CMP $13D7|!addr
	SEP #$20
	BRA .check
endif
.verticalCheck
	LDA $99
	CMP #$02
.check
	BCC .noEnd
	REP #$20		; \ load return value for call in 16bit mode
	LDA #$FFFF		; /
	PLB
	PLP
	PLX
	TAY			; load high byte of return value for 8bit mode and fix N and Z flags
	RTS
	
.noEnd
	LDA $9B
	STA $0B
	ASL A
	ADC $0B
	TAY
	REP #$20
	LDA $98
	AND.w #$FFF0
	STA $08
	AND.w #$00F0
	ASL #2			; 0000 00YY YY00 0000
	XBA			; YY00 0000 0000 00YY
	STA $06
	TXA
	SEP #$20
	ASL A
	TAX
	
	LDA $0D
	LSR A
	LDA $0F
	AND #$01		; 0000 000y
	ROL A			; 0000 00yx
	ASL #2			; 0000 yx00
	ORA #$20		; 0010 yx00
	CPX #$00
	BEQ .noAdd
	ORA #$10		; 001l yx00
.noAdd
	TSB $06			; $06 : 001l yxYY
	LDA $9A			; X LowByte
	AND #$F0		; XXXX 0000
	LSR #3			; 000X XXX0
	TSB $07			; $07 : YY0X XXX0
	LSR A
	TSB $08

	LDA $1925|!addr
	ASL A
	REP #$31
	ADC $00BEA8|!bank,x
	TAX
	TYA
if !SA1
    ADC.l $00,x
    TAX
    LDA $08
    ADC.l $00,x
else
    ADC $00,x
    TAX
    LDA $08
    ADC $00,x
endif
	TAX
	SEP #$20
if !SA1
	LDA $410000,x
	XBA
	LDA $400000,x
else
	LDA $7F0000,x
	XBA
	LDA $7E0000,x
endif
	SEP #$30
	XBA
	TAY
	XBA

	PLB
	PLP
	PLX
	RTS
endif