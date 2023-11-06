;materialize dolphins

!DolphinMaxSlots = 4			;how many dolhpins can be spawned at most (zero counts, so at 4 it's actually 5 dolphins)

!Direction = 2				;0 - dolphins will spawn moving right, 1 - dolphins will spawn moving left, 2 - dolphins will spawn with a random direction

!SpriteNum = $41
!IsCustom = 0				;want to generate a custom dolphin or something completely unrelated?

!SpawnedState = $08			;in which state the dolphin (or whatever sprite) spawns. by default 08 is normal state, and 01 is init (can use 01 if 08 doesn't quite work)

!Flag = 0				;if 0, it won't depend on a flag, otherwise set it to any ram address to make generator work if the flag is enabled (yes, that makes it impossible to use $00 address, but c'mon, who would use that???)
					;example: $14AF|!addr for dependency on on/off switch
!FlagTrueOrFalse = 1			;checks if the flag is 0 or 1 to make the generator work. 1 - if the flag is enabled (non-zero value), 0 - if it's disabled (zero)

!Frequency = $1F			;allowed values: $01,$03,$07,$0F,$1F,$3F,$7F and $FF (unless !UseTimerRAM != 0)

!UseTimerRAM = 0			;if set to 1, will use 1 byte of freeRAM as a timer and allow to set !Frequency to any value instead of limited range
!TimerRAM = $0E51|!addr			;freeRAM used as a timer if above is set to 1

!TriggerAfterScreen = 1			;-1 - disable, any other value will enable. trigger dolphin spawn when player is at this screen of further. this works the best in horizontally oriented levels (horizontal level mode = 0-C) due to how the screens are laid out
!WorkFurtherRightOrLeft = 0		;persist further which direction? 0 - to the right, 1 - to the left (for example if 0, the generator will work starting from screen 4+, with 1 it'll work if on screen 4 and lower (to the left))

DolhpinSpawnXPosLo:
db $10,$E0

DolhpinSpawnXPosHi:
db $01,$FF

DolphinSpawnXSpeed:
db -$18,$18

DolphinSpawnYSpeed:
db -$10,-$20,$00,$10

;no touchy-feely
if !FlagTrueOrFalse
  !Branch = BEQ				;the branch is for failure btw
else
  !Branch = BNE
endif

if !UseTimerRAM
init:
  LDA #!Frequency			;init timer upon level init
  STA !TimerRAM				;
  RTL
endif

main:
LDA $9D					;freeze flag (hurt, pickup power-up, growing yoshi, etc.)
LDA $13D4|!addr				;no pause
ORA $1426|!addr				;no message box (which stops action)
BNE .Re					;

if !TriggerAfterScreen != -1
   if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
      JSL $03BCDC|!bank			;lunar magic's ex level screen calculation something
      TXA				;
   else
      LDA $5B				;vertical or horizontal level mode
      AND #$01				;
      ASL				;
      TAX				;
      LDA $95,x				;check player's x or y high byte as a screen value
   endif
   CMP #!TriggerAfterScreen		;check screen number
   if not(!WorkFurtherRightOrLeft)
     BCC .Re				;!TriggerAfterScreen and above will work
   else
     BEQ .Works				;!TriggerAfterScreen and below will work
     BCS .Re				;
   endif
endif

.Works
if !Flag
  LDA !Flag				;check for user-defined flag
  !Branch .Re				;tru or fals, that's for the user to decide
endif

if !UseTimerRAM
  LDA !TimerRAM				;timer ran out?
  BEQ .Run				;spawn a dolphin

  DEC !TimerRAM				;count down
  RTL					;

.Run
  LDA #!Frequency			;restore timer
  STA !TimerRAM				;
else
  LDA $14				;frame counter check that limits frequency range, but is accurate to the original generator
  AND #!Frequency			;
  BNE .Re				;
endif

;LDY $18B9|!addr			;generator number, not needed in this case
LDX #!DolphinMaxSlots			;spawn in these slots
;LDY #!DolhpinMinSlots			;if this was a generator that could change, then sure, but this is a uberasm for the whole level.

.Loop
LDA !14C8,x				;slot free?
BEQ .SpawnDolph				;lets go
DEX					;
BPL .Loop				;not lets go

.Re
RTL					;

.SpawnDolph
LDA #!SpriteNum				;
STA !9E,x				;
JSL $07F7D2|!bank			;init sprite tables and configuration and stuff

if !IsCustom
  LDA !9E,x				;custom sprite spawn
  STA !7FAB9E,x				;

  JSL $0187A7|!bank			;

  LDA #$08				;
  STA !7FAB10,x				;is custom
endif

LDA #!SpawnedState			;
STA !14C8,x				;normal state

JSL $01ACF9|!bank			;random number generator
AND #$7F				;
ADC #$40				;
ADC $1C					;
STA !D8,x				;starting y-pos

LDA $1D					;
ADC #$00				;
STA !14D4,x				;y-pos high

JSL $01ACF9|!bank			;"random" number generator
AND #$03				;
TAY					;
LDA DolphinSpawnYSpeed,y		;
STA !AA,x				;starting y-speed

if !Direction != 2
  LDY #!Direction			;starting direction
else
  JSL $01ACF9|!bank			;random number "generator"
  AND #$01				;
  TAY					;still starting direction
endif

LDA $1A					;
CLC : ADC DolhpinSpawnXPosLo,y		;
STA !E4,x				;starting x-pos

LDA $1B					;
ADC DolhpinSpawnXPosHi,y		;
STA !14E0,x				;x-pos high

LDA DolphinSpawnXSpeed,y		;
STA !B6,x				;starting x-speed

INC !151C,x				;won't turn around
RTL					;