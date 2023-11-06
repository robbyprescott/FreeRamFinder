;custom status bar functionality
ReserveItemHandle:
LDA $9D			;check 9D
ORA $13D4|!addr		;and pause flag
ORA $1426|!addr		;and message box
ORA $1493|!addr		;goal
BNE .Re			;yes

LDA $0DC2|!addr		;if we have normal item box item, no custom stuff
BEQ .Run		;
JMP .ReSet		;clear item box custom item (to prevent custom item from appearing after releasing normal item due to uncleared RAM)

.Re
RTS			;

.Run
LDY !FreeRam+2		;check if we have a item in the item box
BEQ .Re			;return if not
DEY
;DEC			;
;STA $08		;PHY : PLY would probably work better, but IDK
;TAY			;

if !DropOnHurt
  LDA $71		;drop item when hurt
  DEC			;
  BEQ .Drop		;
endif

LDA $16			;check for select button
AND #!DropItemButton	;
BEQ .Re			;return if not pressed

.Drop
LDA #$0C		;release item box
STA $1DFC|!addr		;sound effect

LDX #!sprite_slots-1	;loop through all sprite slots

.Loop
LDA !14C8,x		;find an empty slot
BEQ .SpawnSuccess	;
DEX			;
BPL .Loop		;

DEC $1861|!addr
BPL .SpawnAlmostSuccess	;it'll replace whatever sprite just to get item from item box...

LDA #$01		;
STA $1861|!addr		;

.SpawnAlmostSuccess
LDA $1861		;
CLC : ADC #$0A		;
TAX			;
LDA !9E,x		;check for p-baloon
CMP #$7D		;replace whatever if not
BNE .SpawnSuccess	;

LDA !14C8,x		;otherwise, there's a little prep to do
CMP #$0B		;yes, p-baloon is actually a sprite we carry when we're inflated.
BNE .SpawnSuccess	;which is why we, besides erasing it, also reset p-baloon timer.

STZ $13F3|!addr		;this is p-baloon timer

.SpawnSuccess
PHY			;
LDA ItemToDrop,y
STA !9E,x
JSL $07F7D2|!bank	;reset sprite tables

LDA !9E,x		;not sure if it's necessary to do it like this, but %SpawnSprite from pixi did this, so...
;LDY $08		;
;LDA ItemToDrop,y	;
STA !7FAB9E,x		;
JSL $0187A7|!bank	;spawn custom sprite

LDA #$08		;set as custom sprite
STA !7FAB10,x		;
STA !14C8,x		;normal status
PLY			;

if !InstaDrop
  LDA $94		;
  STA !E4,x		;

  LDA $95		;
  STA !14E0,x		;

  LDA $96		;
  CLC : ADC #$10	;appear exactly at the body
  STA !D8,x		;

  LDA $97		;
  ADC #$00		;
  STA !14D4,x		;
else
  LDA #!ItemDropXPos	;appear from where item box is at
  CLC			;
  ADC $1A		;
  STA !E4,x		;

  LDA $1B		;
  ADC #$00		;
  STA !14E0,x		;

  LDA #!ItemDropYPos	;but a little lower
  CLC			;
  ADC $1C		;
  STA !D8,x		;

  LDA $1D		;
  ADC #$00		;
  STA !14D4,x		;
endif

INC !1534,x		;blink fall flag

;power they give
;LDA $08
TYA			;
STA !C2,x		;

.ReSet
STZ !FreeRam+2		;	
RTS			;