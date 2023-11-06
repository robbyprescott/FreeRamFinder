; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;    Carryable Sprite Killer by JamesD28   ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

; Extra Byte 1: Number of sprites the Sprite Killer can destroy before it self-destructs. If 0, there will be no limit.
; Extra Byte 2: How long after killing the first sprite before the Sprite Killer self-destructs.
; Extra Byte 3: Palette (0-7).

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;        Defines       ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

!TileNumber = $84

!KillFlag = !1594		; Flag for the Killer having killed at least 1 sprite. Used if extra byte 2 is set.
!KillTimer = !1510		; Timer before the Sprite Killer self-destructs, if using extra byte 2. Decrements once every 8 frames ($FF = 34 seconds).

!KillSFX = $10		; Sound effect to play when the Sprite Killer destroys a sprite. Default is "Bullet Bill shoot".
!KillSFXBank = $1DFC		; SFX bank.

!SelfDestructSFX = $08		; Sound effect to play when the Sprite Killer self-destructs. Default is "Killed by spinjump".
!SelfDestructSFXBank = $1DF9		; SFX bank.

ExclusionTable:		; Add byte entries on the empty line underneath to exclude vanilla sprite numbers. E.g. "db $1C,$AB" to exclude the Bullet Bill & Rex.

TableEnd:
; ‐‐‐‐‐‐‐‐‐‐
CustomExclusionTable:		; Add byte entries on the empty line underneath to exclude custom sprite numbers. E.g. "db $00,$04"

CustomTableEnd:

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;         Init         ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

print "INIT ",pc
PHB
PHK
PLB
LDA #$09		; Sprite state: Carryable
STA !14C8,x		;
STZ !1528,x		; Zero out HP counter.
LDA !extra_byte_2,x
STA !KillTimer,x
PLB
RTL

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;     Main Wrapper     ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

print "MAIN ",pc
PHB
PHK
PLB
JSR Main
JSR Graphics
PLB
RTL

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;         Main         ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

Destroy:
LDA !1686,x		; Make Killer inedible.
ORA #$01		;
STA !1686,x		;
LDA !1564,x		; If destruct timer isn't set already,
BNE +		; set it.
LDA #$11		; Set destruct timer to #$10 (Killer self-destructs at #$01).
STA !1564,x		;
+
CMP #$01		; If timer isn't at #$01,
BNE +		; skip.
KillKiller:
LDA #$04		; Sprite status = killed by spinjump.
STA !14C8,x		;
JSL $07FC3B|!BankB		; Spinjump stars SFX.
STZ $00		;
STZ $01		;
LDA #$1B		;
STA $02		;
LDA #$01		;
%SpawnSmoke()		; Spawn "Puff of smoke".
LDA #!SelfDestructSFX		; SFX.
STA !SelfDestructSFXBank|!addr		; SFX bank.
+
RTS

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐

Main:		; Main routine.

LDA #$00		;
%SubOffScreen()		; Suboffscreen.
LDA !extra_byte_1,x		; If extra byte 1 (destroying limit) isn't set,
BEQ +		; don't check HP.
CMP !1528,x		; If HP counter is equal to extra byte 1,
BEQ Destroy		; destroy the sprite.
+
LDA !14C8,x		; If the sprite...
CMP #$0B		; is carried,
BEQ Carried		; jump to the carried code.
LDA !154C,x		; If the "disable player contact timer" is set,
BNE Normal		; don't interact with Mario.
JSL $01A7DC|!BankB		; Interact with Mario.
BCC Normal		; Skip to normal routine if no contact.

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐

LDA $148F|!addr		; If the "carrying something" flag,
ORA $1470|!addr		; (double check)
ORA $187A|!addr		; or riding Yoshi flag is set,
BNE Normal		; don't pick up the Sprite Killer.

LDA $15		; If the player isn't holding...
AND #$40		; X or Y,
BEQ Normal		; don't pick up the Sprite Killer.

LDA #$01		;
STA $148F|!addr		;
STA $1470|!addr		; Carrying something.

LDA #$0B		; Set the sprite state to "carried".
STA !14C8,x		;

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐

Carried:		; Routine for the "carried" state.

LDA #$01		;
STA $148F|!addr		;
STA $1470|!addr		; Ensure the "carrying something" flags stay set.
LDA #$10
STA !154C,x		; Set "disable player contact" timer for when the player stops carrying the sprite.

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐

Normal:
LDY #!SprSize-1		; Sprite slots.
Loop:
CPY $15E9|!addr		; If Y is equal to X (meaning we're checking the sprite killer itself),
BNE +			; go to the next sprite slot.
JMP Next
+
LDA !14C8,y		; If the sprite being checked...
CMP #$08		; isn't alive,
BCS +			; go to the next sprite slot.
JMP Next
+
LDA !9E,y		; If sprite...
CMP #$35		; is Yoshi,
BNE +			; go to the next sprite slot. His sprite hitbox is ugly.
JMP Next
+
CMP #$7D		; If sprite is P-Balloon,
BNE +		; check its state. An invisible P-Balloon follows Mario when he's inflated, and killing it in this state breaks the balloon Mario mechanic.
LDA !14C8,y
CMP #$0B		; Go to the next sprite slot if it's a carried "invisible" P-Balloon.
BNE +
JMP Next
+

TYX				;
LDA !7FAB10,x	;
STA $00			; This makes the exclusion loops easier to deal with, since we can't do long indexed by Y.
LDA !7FAB9E,x	;
STA $01			;

LDA.b #TableEnd-ExclusionTable		;/
BEQ .NoExclusions					;|
DEC									;|
TAX									;|
LDA $00								;|
BIT #$08							;|
BNE .NoExclusions					;| If this is a vanilla sprite that's set to be excluded in the exclusion table, don't kill it.
LDA $01								;|
.ExclusionLoop						;|
CMP ExclusionTable,x				;|
BEQ Next							;|
DEX									;|
BPL .ExclusionLoop					;\

.NoExclusions

LDA.b #CustomTableEnd-CustomExclusionTable		;/
BEQ .NoCustomExclusions							;|
DEC												;|
TAX												;|
LDA $00											;|
BIT #$08										;|
BEQ .NoCustomExclusions							;| If this is a custom sprite that's set to be excluded in the custom exclusion table, don't kill it.
LDA $01											;|
.CustomExclusionLoop							;|
CMP CustomExclusionTable,x						;|
BEQ Next										;|
DEX												;|
BPL .CustomExclusionLoop						;\

.NoCustomExclusions

LDX $15E9|!addr			;/
JSL $03B69F|!BankB		;|
TYX						;|
JSL $03B6E5|!BankB		;| Hitbox-based interaction.
LDX $15E9|!addr			;|
JSL $03B72B|!BankB		;\
BCC Next				; Skip if no contact.

LDA !9E,y		; If sprite...
CMP #$45		; is directional coins,
BNE +		; handle timers and music.
STZ $1432|!addr		;
STZ $190C|!addr		; Zero out directional coin timers.
LDA $0DDA|!addr		;
STA $1DFB|!addr		; Restore original music.
+
LDA #$00		; Sprite status = dead (empty)
STA !14C8,y		;
TYX		; Move Y to X.
PHY		; Preserve sprite slot being checked.
STZ $00		;
STZ $01		;
LDA #$1B		;
STA $02		;
LDA #$01		;
%SpawnSmoke()		; Spawn "Puff of smoke".
PLY		; Retrieve sprite slot being checked.
LDX $15E9|!addr		; Restore Sprite Killer sprite slot.
LDA #!KillSFX		; SFX.
STA !KillSFXBank|!addr		; SFX bank.
LDA #$01
STA !KillFlag,x
LDA !extra_byte_1,x		; If extra byte 1 (destroying limit) isn't set,
BEQ Next		; don't increment HP.
INC !1528,x		; Increment hitpoint counter.
CMP !1528,x		; If HP counter is now at the limit,
BEQ ++		; jump out of sprite-checking loop. This prevents the Killer from going over its kill limit by touching multiple sprites on the same frame.
Next:
LDX $15E9|!addr		; This is needed if the "Next:" label is reached from the exclusion loop.
DEY		; Decrement checked sprite slot.
BMI ++		; Loop until all sprite slots are checked.
JMP Loop
++

LDA !extra_byte_2,x		;/
BEQ Return				;|
LDA !KillFlag,x			;|
BEQ Return				;|
LDA $14					;| If the timer setting is enabled, decrement it once every 8 frames after the first sprite has been killed.
AND #$07				;|
BNE Return				;|
DEC !KillTimer,x		;|
BNE Return				;| Once the timer reaches 0, kill the Sprite Killer.
JMP KillKiller			;\

Return:
RTS		; Return.

; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;
;       Graphics       ;
; ‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐‐ ;

Graphics:
%GetDrawInfo()		; Does what it says on the tin.
LDA $00		; Tile X position.
STA $0300|!addr,y		;
LDA $01		; Tile Y position.
STA $0301|!addr,y		;
LDA #!TileNumber ; 48 normally
STA $0302|!addr,y
LDA !extra_byte_3,x		; Load YXPPCCCT properties.
AND #$07
ASL A
INC A
ORA $64
STA $0303|!addr,y

LDA #$00
LDY #$02		; All 16x16 tiles.
JSL $01B7B3|!BankB		; OAM finisher routine.
End:
RTS		; Return.