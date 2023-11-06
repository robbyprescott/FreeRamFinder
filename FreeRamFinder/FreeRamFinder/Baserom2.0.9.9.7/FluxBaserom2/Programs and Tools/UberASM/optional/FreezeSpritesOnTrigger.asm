; Modifications by SJC. I had to disable the !PlatformsFix (hijacks at $01B498 and $01CA56)  
; because it was causing a crash when Mario was on top of some sprites, like message box.	
; Some notes re: sprite states: if a kicked shell is frozen and you 
; bounce on it to make it carryable, you can't actually carry it.

; Also, you may need to set the SFX to $00 if you're having SFX glitches
; with some trigger types.

; ------------------------- ;
;  Freeze Sprites with L/R  ;
;        by JamesD28        ;
; ------------------------- ;

; SJC: I've given you the option of two different trigger/timer types. 

!TimerType = 0              ; 0 is first type, 1 is second
                            ; In the first type, sprites will remain frozen as long as the trigger or its timer is still active. (So for an on/off switch, on = frozen, off = not.)  
                            ; In the second type, sprites will automatically unfreeze a set amount of time after the trigger is hit.

                            
; If you're using TimerType = 0, choose your trigger state.

!TriggerState = 2           ; 1 = On/off switch 
                            ; 2 = Hold L or R. 
				            ; 3 = P-switch

; If you're using TimerType = 1, choose your trigger and its duration.

!TriggerState2 = 1          ; 1 = Press L or R
                            ; 2 = 
!FreezeTimer = $60	        ; Time the sprites should be frozen before automatically reverting.

!SFX = $06					; Default 06. SFX to play when the sprites are frozen. Set to 0 to disable.
!SFXBank = $1DFC|!addr		; SFX bank.
!HalfSFX = $23				; Default 23. Sound effect that will play when half the time has expired. Helps the player gauge when the sprites will unfreeze. Set to 0 to disable.
!HalfSFXBank = $1DFC|!addr	; Half time SFX bank.

!FreeRAMTimer = $0EDC|!addr		; 1 byte of freeRAM to use for the sprite freeze timer.
!StartRAM = $7FB900				; FreeRAM start address to backup the sprites.

!FreezeMiscTables = 1		; If set, the miscellaneous sprite tables which control various sprite behaviours will also be frozen.
							; This can prevent jank with certain sprites and enables freezing for sprites not controlled by their X/Y speeds and positions.
							; However, it uses a lot more freeRAM than if disabled (see below). It also isn't guaranteed to behave nicely with custom sprites.

!PlatformsFix = 0			; If set, the code will install a small hijack that prevents Mario from sliding on platforms while they're frozen.
							; Due to code timing, Mario will be shifted by 1 or 2 pixels each time a platform is frozen while stood on it (if it's moving horizontally).
							; If removing this UberASM from your ROM, insert it once with this define set to 0 first to remove the hijacks.
							; Will only apply if !FreezeMiscTables is set, otherwise it will cause the opposite problem (platform still moves but doesn't move Mario).

; freeRAM usage (excluding the 1-byte timer):
; LoROM, misc tables disabled: 85 bytes
; LoROM, misc tables enabled: 349 bytes
; SA-1, misc tables disabled: 155 bytes
; SA-1, misc tables enabled: 639 bytes
; Must be consecutive.

; --------------------

macro SprToRAM(addr, offset)
LDA <addr>,x
STA !StartRAM+(!sprite_slots*<offset>),x
endmacro

macro RAMToSpr(addr, offset)
LDA !StartRAM+(!sprite_slots*<offset>),x
STA <addr>,x
endmacro

; --------------------

main:
LDA $71				;/ Return if in a special animation trigger,
ORA $9D				;| the lock animation/sprites flag is set,
ORA $13D4|!addr		;| paused,
ORA $1426|!addr		;| a message box is active,
ORA $1493|!addr		;| the goal sequence is active,
ORA $13FC|!addr		;\ or a mode 7 boss sequence is active.
BEQ +
LDA $71
CMP #$09
BNE .end
STZ !FreeRAMTimer
.end
RTL
+
if !TimerType = 0  
   if !TriggerState = 1
   LDA $14AF
   BEQ .NotPressed
   endif
endif

if !TimerType = 0
   if !TriggerState = 2
   LDA $17 : AND #$30
   BEQ .NotPressed
   endif
endif

if !TimerType = 0
   if !TriggerState = 3
   LDA $14AD
   BEQ .NotPressed
   endif
endif

if !TimerType = 1
   if !TriggerState2 = 1
   LDA $18 : AND #$30
   BEQ .NotPressed
   endif
endif

if !TimerType = 1
LDA #!FreezeTimer	;/
STA !FreeRAMTimer	;\ Duration to set the freeze for.
else
LDA #$01	        ;/ Will remain until trigger ends
STA !FreeRAMTimer	;\ 
endif

if !TimerType = 1   ; If set, the timer can be reset any time L/R is pressed, even when nonzero.
LDA !FreeRAMTimer	;/
BNE .NotPressed		;\ If retriggering is disabled, don't trigger the freeze if it's already active.
endif

if !SFX  ; is non-zero presumably
LDA #!SFX			;/
STA !SFXBank		;\ Play SFX if enabled.
endif

.NotPressed
LDA !FreeRAMTimer	;/
BNE +				;|
JMP SprtoRAM		;| If the freeze timer is set, copy the RAM backups to the sprite tables, otherwise, backup the sprite tables.
+					;\
if !TimerType = 1  
LDA #!FreezeTimer	;/
LSR					;|
CMP !FreeRAMTimer	;|
BNE .NoSFXTime		;| If enabled, play a SFX when half the freeze time has passed.
LDA #!HalfSFX		;|
STA !HalfSFXBank	;|
.NoSFXTime			;|
endif				;\
DEC !FreeRAMTimer	; Decrement the freeze timer.

; --------------------

RAMtoSpr:
LDX #!sprite_slots-1
.loop
LDA !9E,x								;/
CMP #$7B								;|
BNE +									;| Don't freeze the goal tape.
JMP .next								;\
+
if !FreezeMiscTables
CMP !StartRAM+(!sprite_slots*28),x		; If the sprite number changed last frame (e.g. Parakoopa to Koopa when jumped on), backup the sprite tables instead.
BNE +

CMP #$98					;/
BNE .NotPitchChuck			;|
LDA !1540,x					;|
AND #$1F					;|
CMP #$06					;|
BEQ +						;|
BRA .DontCheckChange		;|
.NotPitchChuck				;|
CMP #$9B					;|
BNE .NotHammerBro			;| Pitchin' Chuck, Flyin' Hammer Bro and Dry Bones need a check for their timer that controls when they throw.
LDA !1540,x					;| Otherwise, freezing them on the same frame they throw will cause them to keep throwing every frame until the extended sprite slots are full.
BNE +						;|
BRA .DontCheckChange		;|
.NotHammerBro				;|
CMP #$30					;|
BNE .NotDryBones			;|
LDA !1540,x					;|
CMP #$01					;|
BEQ +						;|
BRA .DontCheckChange		;|
.NotDryBones				;\

CMP #$3E								;/
BEQ .CheckPChange						;|
CMP #$9C								;|
BEQ .CheckC2Change						;|
CMP #$AB								;|
BEQ .CheckC2Change						;|
CMP #$C8								;|
BEQ .CheckC2Change						;| Various sprites which require a check for a state change.
CMP #$83								;|
BEQ .CheckC2Change						;|
CMP #$84								;|
BEQ .CheckC2Change						;|
CMP #$B9								;|
BNE .DontCheckChange					;\
.CheckC2Change
LDA !C2,x								;/
CMP !StartRAM+(!sprite_slots*7),x		;| If C2 changed last frame for the Flying Grey Platform, Rex, the Light Switch Block, the Message Box or the Flying ?-blocks,
BEQ .DontCheckChange					;\ backup the sprite tables.
+
-
JSR SprRAMTransfer
JMP .next

.CheckPChange
LDA !163E,x				;/
BNE -					;\ Backup the sprite tables if it's a pressed P-switch.
.DontCheckChange
endif

LDA !14C8,x				;/
CMP #$0B				;| Backup the tables if the sprite is carried or a goal coin (but actually only carried since the code immediately returns if $1493 is set).
BCC +					;\
-
JSR SprRAMTransfer
JMP .next
+
CMP #$08								; If the sprite isn't alive (or empty/init), backup the tables.
BCC -
CMP !StartRAM+(!sprite_slots*6),x		; If the sprite status changed last frame, backup the tables. Ensures the sprite's tables are initialized properly before freezing. 
BNE -

TXA									;/
INC									;|
CMP $18E2|!addr						;|
BNE +								;|
LDA $187A|!addr						;|
BNE -								;| If Mario is riding Yoshi or the ride flag changed last frame, backup Yoshi's tables. Prevents jank with mounting/dismounting.
if !FreezeMiscTables				;|
CMP !StartRAM+(!sprite_slots*29)	;|
else								;|
CMP !StartRAM+(!sprite_slots*7)		;|
endif								;|
BNE -								;\
+

%RAMToSpr(!E4, 0)					; Moves all the RAM backups to the sprite tables every frame, freezing them.
%RAMToSpr(!14E0, 1)					; If !FreezeMiscTables is disabled then only the sprite position, speed, and fraction bits are backed up.
%RAMToSpr(!D8, 2)
%RAMToSpr(!14D4, 3)
%RAMToSpr(!AA, 4)
%RAMToSpr(!B6, 5)
if !FreezeMiscTables
LDA !9E,x							;/
CMP #$35							;|
BEQ +								;| Don't ever change C2 for Yoshi.
%RAMToSpr(!C2, 7)					;|
+									;\
%RAMToSpr(!1504, 8)
%RAMToSpr(!1510, 9)
%RAMToSpr(!151C, 10)
%RAMToSpr(!1528, 11)
%RAMToSpr(!1534, 12)
LDA !9E,x							;/
CMP #$2F                            ; added by SJC
BEQ +
CMP #$04							;|
BCC .NotKoopa						;|
CMP #$08							;|
BCC +								;| Don't ever change 1540 for the normal Koopas (prevents spawn jank with the sliding koopa when a normal Koopa is bounced on).
.NotKoopa							;|
%RAMToSpr(!1540, 13)				;|
+									;\
%RAMToSpr(!154C, 14)
%RAMToSpr(!1558, 15)
%RAMToSpr(!1564, 16)
%RAMToSpr(!1570, 17)
%RAMToSpr(!157C, 18)
%RAMToSpr(!1594, 19)
%RAMToSpr(!15AC, 20)
%RAMToSpr(!15D0, 21)
%RAMToSpr(!15F6, 22)
%RAMToSpr(!1602, 23)
%RAMToSpr(!160E, 24)
%RAMToSpr(!1626, 25)
%RAMToSpr(!163E, 26)
%RAMToSpr(!187B, 27)
endif
STZ !14EC,x							;/
STZ !14F8,x							;\ Zero the fraction bits to prevent jittering.

.next
DEX
BMI +
JMP .loop
+
LDA $187A|!addr						;/
if !FreezeMiscTables				;|
STA !StartRAM+(!sprite_slots*29)	;| Backup the riding Yoshi flag.
else								;|
STA !StartRAM+(!sprite_slots*7)		;\
endif
RTL

; --------------------

SprtoRAM:					; Pretty much the same stuff but for backing up the sprite tables in freeRAM when not frozen.
LDX #!sprite_slots-1
.loop
LDA !9E,x
CMP #$7B
BEQ .next
LDA !14C8,x
BEQ .next
CMP #$01
BEQ +
CMP #$0B
BCS .next
+

JSR SprRAMTransfer

.next
DEX
BPL .loop
LDA $187A|!addr
if !FreezeMiscTables
STA !StartRAM+(!sprite_slots*29)
else
STA !StartRAM+(!sprite_slots*7)
endif
RTL

SprRAMTransfer:		; This is in a subroutine since it also needs to be accessed by some sprites in the loop when the freeze is active.

%SprToRAM(!E4, 0)
%SprToRAM(!14E0, 1)
%SprToRAM(!D8, 2)
%SprToRAM(!14D4, 3)
%SprToRAM(!AA, 4)
%SprToRAM(!B6, 5)
%SprToRAM(!14C8, 6)
if !FreezeMiscTables
%SprToRAM(!C2, 7)
%SprToRAM(!1504, 8)
%SprToRAM(!1510, 9)
%SprToRAM(!151C, 10)
%SprToRAM(!1528, 11)
%SprToRAM(!1534, 12)
LDA !9E,x
CMP #$2F   ; added by 
BEQ +      ; SJC
CMP #$04
BCC .NotKoopa
CMP #$08
BCC +
.NotKoopa
%SprToRAM(!1540, 13)
+
%SprToRAM(!154C, 14)
%SprToRAM(!1558, 15)
%SprToRAM(!1564, 16)
%SprToRAM(!1570, 17)
%SprToRAM(!157C, 18)
%SprToRAM(!1594, 19)
%SprToRAM(!15AC, 20)
%SprToRAM(!15D0, 21)
%SprToRAM(!15F6, 22)
%SprToRAM(!1602, 23)
%SprToRAM(!160E, 24)
%SprToRAM(!1626, 25)
%SprToRAM(!163E, 26)
%SprToRAM(!187B, 27)
%SprToRAM(!9E, 28)
endif

RTS

if !PlatformsFix && !FreezeMiscTables
pushpc					;/
ORG $01B498				;|
JSL Fix					;|
ORG $01CA56				;|
JSL Fix					;|
pullpc					;|
						;| Fixes Mario sliding on platforms while frozen if he's stood on one.
Fix:					;|
LDA !FreeRAMTimer		;|
BNE .NoMove				;|
LDA $77					;|
AND #$03				;|
.NoMove					;|
RTL						;\

else
pushpc					;/
ORG $01B498				;|
LDA $77					;|
AND #$03				;|
ORG $01CA56				;| Restore hijacked code if the platform fix is disabled.
LDA $77					;|
AND #$03				;|
pullpc					;\
endif