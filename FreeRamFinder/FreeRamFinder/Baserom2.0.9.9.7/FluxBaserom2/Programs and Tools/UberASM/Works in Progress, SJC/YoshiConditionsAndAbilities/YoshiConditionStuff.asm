; ---------- DEFINES ----------

!freeram = $1487		; Freeram address to hold the timer. Decrements once per real life second (NTSC) when the condition of !default is met.
!tick = $1488		; Freeram address to hold the tick timer. Set to $3C and decrements once per frame when the condition of !default is met.

!timer = 120		; Default time you can spend on Yoshi, in seconds. Max value = 255.
!reset = 1		; 1 = Timer is reset when bringing Yoshi into a sublevel.
!enterlevel = 0		; 1 = Yoshi is killed/babyfied upon entering a level.
!drawtimer = 1		; 1 = Timer is drawn to the status bar. Disable if using a non-vanilla status bar. Value is displayed in hex.

!default = 1		; 1 = Base decrement for timer while Mario is riding Yoshi. If disabled, only the effects enabled below will decrement the timer.
!double = 0		; 1 = Halves the rate at which the default timer is decremented, effectively doubling the timer. Does not apply to other effects.
!coin = 0		; 1 = Timer regenerates by 1 for each coin collected while riding Yoshi. Also includes coins gained by eating sprites, so somewhat negates
		; the effect of the mouth define for certain sprites.
!regenerate = 1		; 1 = Timer regenerates if Yoshi is resting (not ridden or hurt).
!replenish = 10 	; >=1 = Reset the timer at the cost of a life. Hold L then R to activate. Can only be activated if there are less than N seconds remaining
		; on the Yoshi timer. N is the value set for this define.

!run = 1		; 1 = Timer decreases faster if Yoshi is running at max speed. This is affected by the speed cap set in the slow define.
!slow = $0		; Cap on maximum speed while on Yoshi. Should always be lower than $2F. Set to $0 to disable.
!loseyoshi = 1		; 3 = Effects of 2, and Mario is hurt/killed. 2 = Yoshi is killed/babyfied instantly if he takes damage. 1 = Timer decreases faster if
		; Yoshi is running away due to taking damage.
!air = 1		; 1 = Timer decreases faster if Yoshi is in the air.
!mouth = 1		; 1 = Timer decreases faster if Yoshi is pulling an item into his mouth.
!water = 1		; 2 = Yoshi will be killed/babyfied instantly if in water. 1 = Timer decreases faster if Yoshi is in water. Swimming is also treated as "in 		; the air" unless walking on ground, so this is also affected by the air define.
!star = 1		; 2 = Attempting to mount Yoshi with star power will kill/babyficate Yoshi. 1 = Timer decreases faster if Mario has star power while riding
		; Yoshi.
!nodoor = 1		; 1 = Mario cannot enter a door while riding Yoshi.
!babyfication = 0 	; 1 = Once the timer hits 0, Yoshi will turn into a baby instead of dying.
!weak = 1		; 2 = Attempting to mount Yoshi while big/cape/fire will kill/babyficate Yoshi. 1 = Timer decreases faster if big/fire/cape while riding Yoshi.

!SFX = $08		; Sound effect to play when Yoshi is killed. Default is "Killed by spin jump".
!BabySFX = $20		; Sound effect to play when Yoshi turns into a baby. Default is "Yoshi spit".
!SFXBank = $1DF9		; SFX bank.

; -----------------------------

init:
if !enterlevel
LDX.b #!sprite_slots-1		; Load highest sprite slot into x.
.loop
LDA !9E,x		; If the sprite number
CMP #$35		; isn't Yoshi,
BNE +		; go to the next sprite slot.
LDA !14C8,x		; If the Yoshi slot is dead,
BEQ +		; go to the next sprite slot.
JMP Zerotimer		; Jump to 0 timer routine.
+
DEX		; Decrement sprite slot by 1.
BPL .loop		; Continue loop until lowest sprite slot is checked.
endif

if !reset == 0
LDA !freeram|!addr 	; If timer is set,
BNE +		; skip.
endif
LDA #!timer 	; Load timer value.
STA !freeram|!addr 	; Store timer to freeram.
LDA #$3C		; Load tick timer value (1 second).
STA !tick|!addr 	; Store tick timer to freeram.
+
RTL

main:
LDA $1493|!addr 	; If the goal timer,
ORA $1434|!addr 	; keyhole timer,
ORA $9D		;  lock sprite timer,
ORA $13D4|!addr 	; or pause flag is active,
BEQ +		; cancel the whole routine.
RTL
+

if !drawtimer
LDA !freeram|!addr 	; Load timer value.
AND #$F0 	; Ignore lower bits.
LSR #4		; Shift high bits to low bits.
STA $0F0E|!addr 	; Draw first digit to status bar.
LDA !freeram|!addr 	; Load timer value.
AND #$0F 	; Ignore higher bits.
STA $0F0F|!addr 	; Draw second digit to status bar.
endif

LDX.b #!sprite_slots-1		; Load highest sprite slot into x.
.loop
LDA !9E,x		; If the sprite number
CMP #$35		; isn't Yoshi,
BNE +		; go to the next sprite slot.
LDA !14C8,x		; If the Yoshi slot is alive,
BNE YoshiStuff		; Run the main Yoshi code.
+
DEX		; Decrement sprite slot by 1.
BPL .loop		; Continue loop until lowest sprite slot is checked.
LDA #!timer 	; Load timer value.
STA !freeram|!addr 	; Store timer to freeram.
LDA #$3C		; Load tick timer value (1 second).
STA !tick|!addr 	; Store tick timer to freeram.
RTL

YoshiStuff:

LDA $187A|!addr 	; If Mario is riding Yoshi,
BEQ +
BRA ++++		; ignore non-riding effects.
+

if !regenerate
LDA !freeram|!addr 	; If the current timer value
CMP #!timer 	; is already at its maximum,
BEQ +		; skip.
LDA !C2,x		; If Mario got off of Yoshi
CMP #$02		; by taking damage,
BEQ +		; skip.
LDA $14		; Load frame counter.
AND #$3F		;
CMP #$3F		; Only regenerate every $3F frames (just over 1 second).
BNE +		;
INC !freeram|!addr 	; Increment the timer.
+
endif

if !loseyoshi
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+
LDA !C2,x		; If Yoshi
CMP #$02		; isn't running from taking damage,
BNE +		; skip.
if !loseyoshi >= 2
if !loseyoshi == 3
STZ $1497|!addr
JSL $00F5B7		; Hurt/Kill Mario if !loseyoshi is 3, then/otherwise,
endif
JMP Zerotimer 	; Jump to 0 timer routine if !loseyoshi is 2 or 3, otherwise,
endif
DEC !tick|!addr 	;
JSR TickCheck 	;
DEC !tick|!addr 	; Decrements tick timer twice per frame and checks if the main timer should be decremented.
JSR TickCheck 	;
+
endif

JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
LDA !freeram|!addr 	; Load timer value.
BNE +
JMP Zerotimer		; Jump to 0 timer routine if 0.
+
RTL

++++

if !coin
LDA !freeram|!addr 	; If the current timer value
CMP #!timer 	; is already at its maximum,
BEQ +		; skip.
LDA $13CC|!addr 	; If a coin hasn't been collected,
BEQ +		; skip.
INC !freeram|!addr 	; Increment the timer.
+
endif

if !nodoor
LDA #$08		;
TSB $0DAA|!addr 	; Disable Up for P1 for 1 frame.
TSB $0DAB|!addr 	; Disable Up for P2 for 1 frame.
endif

if !replenish
LDA !freeram|!addr 	; If the timer value
CMP #!replenish		; is greater than or equal to the replenish limit,
BCS +		; skip.
LDA $17		; If L isn't being held,
AND #$20		;
BEQ +		; skip.
LSR		; If R
AND $18		; hasn't just been pressed,
BEQ +		; skip.
LDA $0DBE|!addr 	; If Mario only has 1 life,
CMP #$01		; skip
BCC ++		; to failed SFX.
DEC $0DBE|!addr 	; Decrement Mario's lives by one.
LDA #$29		; "Correct" SFX.
STA $1DFC|!addr 	; Store SFX to bank.
LDA #!timer 	; Load timer value.
STA !freeram|!addr 	; Store timer to freeram.
LDA #$3C		; Load tick timer value (1 second).
STA !tick|!addr 	; Store tick timer to freeram.
BRA +
++
LDA #$2A		; "Wrong" SFX.
STA $1DFC|!addr 	; Store SFX to bank.
+
endif

if !weak
LDA $19		; If Mario is small,
BEQ +		; skip.
if !weak == 2
JMP Zerotimer 	; Jump to 0 timer routine if !weak is 2, otherwise,
endif
DEC !tick|!addr 	; Decrements tick timer every frame that Mario is Big/Cape/Fire.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
endif

if !star
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+
LDA $1490|!addr 	; If Mario doesn't have star power,
BEQ +		; skip.
if !star == 2
JMP Zerotimer 	; Jump to 0 timer routine if !star is 2, otherwise,
endif
DEC !tick|!addr 	; Decrements tick timer every frame that Mario has star power.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
endif

if !water
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+
LDA $75		; If Mario isn't in water,
BEQ +		; skip.
if !water == 2
JMP Zerotimer 	; Jump to 0 timer routine if !water is 2, otherwise,
endif
DEC !tick|!addr 	; Decrements tick timer every frame that Mario is in water.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
endif

if !mouth
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +++		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+++
PHX		; Push Yoshi's sprite slot to stack to retrieve later.
LDX.b #!sprite_slots-1		; Load highest sprite slot into x.
.loop
LDA !15D0,x		; If the sprite is on Yoshi's tongue,
BNE +		; jump to next check for this sprite.
-
DEX		; Decrement sprite slot by 1.
BPL .loop		; Continue loop until lowest sprite slot is checked.
BRA ++		; Skip if no sprites are on Yoshi's tongue.
+
LDA !14C8,x		; If the sprite is alive,
BNE +		; Jump to final check.
STZ !15D0,x		; Remove dead sprite from Yoshi's tongue.
BRA -		; Return to main loop.

+
PLX		; Retrieve Yoshi's sprite slot.
LDA !1594,x		; Only decrement timer if Yoshi's tongue is out of his mouth. Prevents timer decrementing while sprite is in Yoshi's mouth.
BEQ +
DEC !tick|!addr 	; Decrements tick timer 5 times every frame and checks if the main timer should be decremented.
JSR TickCheck 	;
DEC !tick|!addr 	; Some kind of conditional SBC would have probably been better.
JSR TickCheck 	;
DEC !tick|!addr 	; I promise I tried but I couldn't get it to work
JSR TickCheck 	;
DEC !tick|!addr 	; 
JSR TickCheck 	;
DEC !tick|!addr 	;
JSR TickCheck 	;
BRA +		; Jump to end of this routine.
++
PLX		; Retrive Yoshi's sprite slot.
+
endif

if !air
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+
LDA $72		; If Mario isn't in the air,
BEQ +		; skip.
DEC !tick|!addr 	; Decrements tick timer every frame that Mario is in the air.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
endif

if !slow
LDA $7B		; Load Mario's speed.
BMI ++		; Jump to negative speed checks if negative.
CMP #!slow 	; If speed is slower than the speed cap,
BCC +		; skip.
LDA #!slow 	; Load speed cap.
STA $7B		; Store to Mario's speed.
BRA +
++
CMP #-!slow 	; If speed is slower than the speed cap,
BCS +		; skip.
LDA #-!slow 	; Load speed cap.
STA $7B		; Store to Mario's speed.
+
endif

if !run
LDA !freeram|!addr 	; If timer hasn't reached 0,
BNE +		; skip.
JMP Zerotimer		; Jump to 0 timer routine.
+
LDA $7B		; Load Mario's X speed.
if !slow
CMP.b #!slow 	;
BCC +		;
CMP.b #-!slow 	;
BCS +		;
else
CMP #$2F		;
BCC +		;
CMP #$D1		; Skip if no P-speed.
BCS +		;
endif
DEC !tick|!addr 	; Decrements tick timer every frame that Mario is at maximum speed on Yoshi.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
endif

LDA !freeram|!addr 	; Load timer value.
BEQ Zerotimer		; Jump to 0 timer routine if 0.
if !default
if !double
LDA $14
AND #$01
BEQ +
endif
DEC !tick|!addr 	; Decrement tick timer every frame that Mario is riding Yoshi.
JSR TickCheck		; Jump to subroutine to check if timer should be decremented.
+
LDA !freeram|!addr 	; Load timer value.
BEQ Zerotimer		; Jump to 0 timer routine if 0.
endif
RTL

Zerotimer:
PHX		; Preserve Yoshi's sprite slot.
LDA !160E,x		; Load slot number of sprite in Yoshi's mouth.
BMI +		; Skip if null (#$FF).
TAX		; Move slot number into X.
STZ !14C8,x		; Kill the sprite in Yoshi's mouth.
+
PLX		; Retrieve Yoshi's sprite slot.
STZ $18AC|!addr 	; Zero the swallow timer.
LDA !15C4,x		; If Yoshi is offscreen,
ORA !186C,x		;
BNE +		; don't spawn smoke.
JSR Smoke		; Spawn a puff of smoke.
+
STZ $187A|!addr 	; Unset the "riding Yoshi" flag.
STZ $0DC1|!addr 	; Unset the "carry Yoshi over levels" flag.
STZ $18DF|!addr 	; Set the "Yoshi slot" to 0.
STZ $18E2|!addr 	; Unset the "Loose Yoshi" flag.
if !babyfication
LDA #$2D 	; Baby Yoshi sprite number.
CLC
JSR SpawnBaby 	; Jump to spawn routine.
BCS + 	; Branch if sprite spawn failed.
LDA !15F6,x		;
STA.w !15F6,y 	; Preserve sprite palette (for Yoshi colour type).
LDA !AA,x		;
STA.w !AA,y 	; Preserve sprite Y speed.
LDA !B6,x		;
STA.w !B6,y 	; Preserve sprite X speed. Doesn't work on sa-1? Baby Yoshi drops in place.
LDA !E4,x		;
STA.w !E4,y 	; Preserve sprite X position, low byte.
LDA !D8,x		;
STA.w !D8,y 	; Preserve sprite Y position, low byte.
LDA !14E0,x		;
STA.w !14E0,y 	; Preserve sprite X position, high byte.
LDA !14D4,x		;
STA.w !14D4,y 	; Preserve sprite Y position, high byte.
LDA !157C,x		;
STA.w !157C,y 	; Preserve sprite horizontal direction.
LDA #$04 	;
STA !14C8,x 	; Set Yoshi's sprite status to "killed by spinjump".
LDA #!BabySFX		; Load Baby Yoshi SFX.
STA !SFXBank|!addr 	; Store SFX to bank.
RTL
+
endif
LDA #$04 	;
STA !14C8,x 	; Set Yoshi's sprite status to "killed by spinjump".
LDA #!SFX		; Load SFX.
STA !SFXBank|!addr 	; Store SFX to bank.
RTL

TickCheck:
LDA !tick|!addr 	; Load tick timer value.
BNE +		; skip if tick timer isn't 0.
DEC !freeram|!addr 	; Decrement the timer.
LDA #$3C		; Reset tick timer value.
STA !tick|!addr 	; Store value to tick timer.
+
RTS

Smoke:		; Slight modification of PIXI's "Spawn Smoke" routine. Credit goes to JackTheSpades and Tattletale.
LDA #$01
LDY #$03
XBA
-
LDA $17C0|!addr,y
BEQ +
DEY
BPL -
SEC
RTS
+		
XBA
STA $17C0|!addr,y
LDA #$1B
STA $17CC|!addr,y
LDA !D8,x
CLC
ADC #$10
STA $17C4|!addr,y
LDA !E4,x
STA $17C8|!addr,y
CLC
RTS

SpawnBaby:		; Modification of PIXI's "Spawn Sprite" routine. Ditto.
PHX
XBA
LDX #!sprite_slots-1
-
LDA !14C8,x
BEQ +
DEX
BPL -
SEC
BRA .no_slot
+
XBA
STA !9E,x
JSL $07F7D2|!bank
LDA #$01
STA !14C8,x
TXY
PLX
CLC
RTS		
.no_slot:
TXY
PLX
RTS

; --------------------

if !timer > 255
error "The timer define cannot be greater than 255."
endif

if !replenish > !timer
error "The replenish threshold cannot be greater than the value set in the timer."
endif