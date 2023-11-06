; Specific blocks required

!Freeram_NewSpd		= $13F4	;>4 bytes
;^X and Y speed:
;+0 = new X speed
;+1 = fractional bits of x spd
;+2 = new Y speed
;+3 = fractional bits of y spd


!Freeram_NotPushed	= $5C	;>1 byte
!Freeram_BeingPshd	= $58	;>1 byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Paste this in uberasm's gamemode 14.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init:
    STZ $13F4
    STZ $13F5
    STZ $13F6
    STZ $13F7
	RTL
	
main:
	LDA $9D				;\Don't push mario if frozen or he's doing something else
	ORA $13D4+!Base2	;|
	ORA $71				;|
	ORA $1493+!Base2	;|
	ORA $1426+!Base2	;|
	BEQ +
	JML .Return			;/
+	JSR ExtraSpd
.PushMarioSpd
	LDA !Freeram_NotPushed	;\if already not pushed, transfer
	BNE .TransferSpd		;/speed (happens when force stops, like getting off conveyor)

	LDA #$01				;\Indicate that the player is no longer forced
	STA !Freeram_NotPushed	;/

	LDA !Freeram_BeingPshd	;\If already on platform, don't
	BEQ ..NotPushed
	JML .Return				;/constantly subtract.
..NotPushed
	LDA #$01				;\Prevent overaccelerating
	STA !Freeram_BeingPshd	;/when landing back on belt

	LDX #$02

.loop
.16BitRamSpd
	LDA !Freeram_NewSpd,x
	JSR Convert16Bit
	LDA !Freeram_NewSpd,x	;>#$FF80 to #$007F; ex: #$0060
	REP #$20
	STA $00
	SEP #$20

.16BitMarioSpd
	LDA $7B,x
	JSR Convert16Bit
	LDA $7B,x				;>#$FF80 to #$007F; ex: #$FFD0
	REP #$20

.SetSpeed
	SEC
	SBC $00			;>ex: #$FFD0 - #$0060 = #$FF70 (in dec, thats -144)
	STA $02			;$02 = MarioSpeed - ConveyorSpd
	CMP #$FF80
	BMI ..TooLow
	CMP #$0080
	BPL ..TooHigh
	SEP #$20
	BRA ..ConvertTo8Bit
..TooLow
	SEP #$20
	LDA #$80
	BRA ..StoreSpd
..TooHigh
	SEP #$20
	LDA #$7F
	BRA ..StoreSpd

..ConvertTo8Bit
;	LDA $03
;	BEQ ..Positive
;	LDA $02
;	EOR #$FF
;	INC
;	STA $02
;..Positive
;	LDA $02
;^This is to prevent mario running at max speed in the opposite direction
;of the EXTREMELY fast conveyor belt/wind won't cause mario to be at his max
;speed from the conveyor belt/wind.
..StoreSpd
	STA $7B,x				;\Laws of friction
	DEX #2					;|
	BPL .loop				;|
	BRA .Return				;/

.TransferSpd				;>happens when pushing stops forcing you
	LDX #$02
..loop
	REP #$20
	LDA $08,x				;Get momentum from the conveyor belt...
	CMP #$FF80				;\Prevent in case if the player and conveyor belt
	BMI ...TooLow			;|moves in the same direction but ends up going
	CMP #$0080				;|too fast that $7B and/or $7D can't handle
	BPL ...TooHigh			;/
	SEP #$20
	BRA ...SetSpd			;>Valid speed.
...TooLow
	SEP #$20
	LDA #$80
	BRA ...LimitSpd
...TooHigh
	SEP #$20
	LDA #$7F
	BRA ...LimitSpd
...SetSpd
	LDA $08,x
...LimitSpd
	STA $7B,x				;
	LDA #$00				;\...without being conveyored constantly when off
	STA !Freeram_NewSpd,x	;/to store the net velocity (or velocity relative to Layer1) to $7B
	DEX #2
	BPL ..loop

	LDA #$00
	STA !Freeram_BeingPshd		
.Return
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Paste this on the VERY bottom of
;gamemode.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ExtraSpd:
;Blocked status check.
	LDX #$00
	JSR CalculateXNetVelocity
	LDX #$02
	JSR CalculateXNetVelocity

.HorizontalBlock
	REP #$20
	LDA $08					;>The net speed = speed relative to layer 1
	SEP #$20
	BMI ..GoingLeft
..GoingRight
	LDA $77					;prevent being pushed right into wall
	AND.b #%00000001
	BNE .VerticalBlock
	BRA ..AdjustXPos
..GoingLeft
	LDA $77					;prevent being pushed left into wall
	AND.b #%00000010
	BNE .VerticalBlock
..AdjustXPos
	LDX #$00
	JSR AdjustPos			;>Move mario horizontally

.VerticalBlock
	REP #$20
	LDA $0A
	SEP #$20
	BMI ..GoingUp
..GoingDown
	LDA $77
	AND.b #%00000100
	BNE .MoveDone
	BRA ..AdjustYPos
..GoingUp
	LDA $77
	AND.b #%00001000
	BNE .MoveDone
..AdjustYPos
	LDX #$02
	JSR AdjustPos
.MoveDone
	RTS

AdjustPos:
;This entire section is based off of SMW's velocity routine
;Input:
;X = #$00 for x speed
;X = #$02 for y speed
	LDA !Freeram_NewSpd,x	;(Based on $00DC2D)
	ASL #4
	CLC
	ADC !Freeram_NewSpd+1,x	;\Fractional bits
	STA !Freeram_NewSpd+1,x	;/
	REP #$20
	PHP
	LDA !Freeram_NewSpd,x
	LSR #4
	AND #$000F				;>get rid of high byte nibble (only load 1 byte of speed)
	CMP #$0008
	BCC .SkipORARounding
	ORA #$FFF0
.SkipORARounding
	PLP
	ADC $94,x
	STA $94,x
	SEP #$20
.NewXSpdDone
	RTS

CalculateXNetVelocity:	;>This was needed to prevent wall clipping death
;Input:
;X=#$00 = x speed
;X=#$02 = y speed
;output:
;$00 = 16-bit x speed
;$02 = 16-bit y speed
;$04 = 16-bit new x speed
;$06 = 16-bit new y speed
;$08 = 16-bit relative x speed with Layer1
;$0A = 16-bit relative y speed with Layer1

;This was needed so when mario stops being pushed,
;he'll have momentum from it.
.ConvertMarioSpd16Bit
	LDA $7B,x
	JSR Convert16Bit
	LDA $7B,x
	REP #$20
	STA $00,x			;>Player speed $00 and $02
	SEP #$20

.ConvertNewSpd16Bit
	LDA !Freeram_NewSpd,x
	JSR Convert16Bit
	LDA !Freeram_NewSpd,x
	REP #$20
	STA $04,x			;>Push speed $04 and $06

.CalculateNetVel
	CLC
	ADC $00,x
	STA $08,x			;>Speed relative to Layer1 $08 and $0A
	SEP #$20
	RTS

Convert16Bit:
;Input: A (8-bit) = the signed value
;Output: A (Load it as 8-bit before REP #$20) = the equivalent signed
;value (#$00XX or #$FFXX)
;Note: will not work if value is #$00XX where XX is 80 to FF or #$FFXX
;where XX is #$00 to #$7F
	BMI .Negative
.Positive
	LDA #$00
	BRA .SetHighByte
.Negative
	LDA #$FF
.SetHighByte
	XBA
	RTS