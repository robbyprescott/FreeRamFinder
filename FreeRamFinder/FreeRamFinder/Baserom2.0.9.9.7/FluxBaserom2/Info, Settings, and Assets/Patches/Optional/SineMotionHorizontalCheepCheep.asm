;Sine wave motion for horizontal Cheep-Cheep, by Blind Devil
;This patch makes it so fishes that move horizontally will slightly move
;up and down, kinda like they did in SMB3.

;Configurable defines:

;ACCELERATION
;Amount of speed to add.
	!AccelDn = $01		;accel up
	!AccelUp = $FF		;accel down

;MAX SPEEDS
;Maximum speeds for sine wave acceleration.
	!MaxSpdDn = $04		;moving down max speed
	!MaxSpdUp = $FC		;moving up max speed

;Below defines are default ones. Don't modify them.

if read1($00FFD5) == $23
	sa1rom
	!BankB = $000000

	!AA = $309E
	!151C = $3284
	!1534 = $32B0
else
	lorom
	!BankB = $800000

	!AA = $AA
	!151C = $151C
	!1534 = $1534
endif

;Code starts below.

org $01B0D2				;hijack location
autoclean JML SineFish			;jump to sine wave handling code

org $01B0DB				;another hijack location
NOP #5					;we just clear the Y speed storing code in there (as it'd mess up the sine wave)

org $01B0E3				;yet another hijack location
autoclean JML ConditionalVCheep		;because a compare for vertical fish is necessary (yet again to prevent the sine wave from being affected)

freecode

ConditionalVCheep:
XBA				;flip high/low bytes of A (it's a form of quick value preservation)

LDA !151C,x			;load fish behavior flag
BNE +				;if it's a vertical moving fish, then branch.

-
JML $01B0E7|!BankB		;jump back to regular code, and update sprite Y position.

+
XBA				;flip high/low bytes of A back
AND #$0C			;preserve these bits from whatever is in A
BEQ -				;if whatever that is in A is equal zero, branch back.
JML $01B0EA|!BankB		;jump back to regular code without updating sprite Y position.

SineFish:
BEQ +				;restored code. from original, A contains $151C,x, so branch if it's zero (determines fish behavior, is vertical if non-zero)
INY #2				;still restored code, increment Y twice

LDA.w $B01F,y			;load Y speed from table (at bank 1) according to index
STA !AA,x			;store to sprite's Y speed (done because we've NOP'd the original code, but the vertical fish needs it).

BRA ++				;skip wavy motion code

+
PHB				;preserve data bank in stack
PHK				;now push program bank to stack
PLB				;pull program bank from stack as new data bank (done to read tables from the intended bank)
JSR ApplySine			;call sine wave subroutine
PLB				;restore previous data bank

++
JML $01B0D6|!BankB		;jump back to regular code.

ApplySine:
PHY				;preserve Y (the value set from original code is used for some tables later)
LDA $14				;load effective frame counter
AND #$03			;preserve bits 0 and 1
BNE +				;if any are set, skip ahead (run below code every fourth frame).

LDA !1534,x			;load sprite RAM (Cheep-Cheep doesn't use it by default) - used as sine wave direction index here
AND #$01			;preserve bit 0
TAY				;transfer value to Y

LDA !AA,x			;load sprite's Y speed
CLC				;clear carry
ADC CheepAccelY,y		;add accel value from table according to index
STA !AA,x			;store result back.
CMP CheepMaxSpeedY,y		;compare current speed with max speed value from table according to index
BNE +				;if not equal, simply update sprite's Y position.

INC !1534,x			;else increment sprite RAM.

+
CMP #!MaxSpdDn+1		;compare speed with max positive value
BCC ++				;if lower, skip ahead.
CMP #!MaxSpdUp-1		;compare speed with max negative value
BCS ++				;if higher, skip ahead.

.zero
STZ !AA,x			;reset sprite's X speed.

++
PLY				;restore Y
RTS				;return.

;Some tables below.

CheepMaxSpeedY:
db !MaxSpdDn,!MaxSpdUp

CheepAccelY:
db !AccelDn,!AccelUp