; Allows bob-omb (sprite 0D), goomba (0F), buzzy beetle (11), and mechakoopa (A2)
; to be spawned already in a stunned state if their extra bit is set.
; Remember that the extra bit is set as 1 here, not 3.

; by JamesD28


!SetStunTimer = 1		; If set, the carryable sprites' stun timers will be set. Set to 0 if you want the spawned carryable sprites to remain so permanently.

; --------------------

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
	!9E = $3200
	!14C8 = $3242
	!1540 = $32C6
	!1602 = $33CE
	!7FAB10 = $400040
else
	lorom
	!addr = $0000
	!bank = $800000
	!9E = $9E
	!14C8 = $14C8
	!1540 = $1540
	!1602 = $1602
	!7FAB10 = $7FAB10
endif

; --------------------

ORG $01817D+($A2*2)
dw BombMech					; Repoint the Mechakoopa's Init to the Bob-omb's (Mecha's vanilla Init just returns).

ORG $01855D
BombMech:
autoclean JML InitBombMech
NOP

ORG $018576
autoclean dl InitSpr0to13

freecode

InitBombMech:

LDA !7FAB10,x		;/
AND #$04			;|
BEQ .NotCarryable	;| Set carryable if extra bit set.
LDA #$09			;|
STA !14C8,x			;\
if !SetStunTimer
LDA #$FF
STA !1540,x			; Set stun timer for both Bob-omb and Mechakoopa if carryable.
endif
.NotCarryable
LDA !9E,x			;/
CMP #$A2			;|
BEQ .Mecha			;| Only set stun timer for Bob-omb if not carryable (main state).
LDA !14C8,x			;|
CMP #$09			;|
BEQ +				;|
LDA #$FF			;|
STA !1540,x			;\
+
JML $01857C|!bank	; Jump to face Mario code if Bob-omb.
.Mecha
LDA !14C8,x			;/
CMP #$09			;|
BNE +				;| Set Mechakoopa's animation frame to stunned if applicable.
LDA #$05			;|
STA !1602,x			;\
+
JML $0185C2|!bank	; Jump to RTS if Mechakoopa.

InitSpr0to13:

LDA !9E,x
CMP #$0F			; Goomba
BEQ .CheckExBit
CMP #$11			; Buzzy Beetle
BNE .NotCarryable
.CheckExBit
LDA !7FAB10,x
AND #$04
BEQ .NotCarryable
LDA #$09
STA !14C8,x
if !SetStunTimer
LDA #$FF
STA !1540,x
endif
.NotCarryable
JML $01ACF9|!bank	; Jump to RNG routine to get value for animation timer (will return to vanilla Spr0to13 Init).