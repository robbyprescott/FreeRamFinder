;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Programmable Block by dtothefourth
;;
;; Based on the disassembly of the Gray Moving Castle Block by imamelia
;;
;; Adds the ability to control both X and Y movement in an arbitrary number of phases (well, up to 255 phases)
;; Adds the ability to activate/deactivate the block based on standing on it, ON/OFF or PSwitches
;; Adds a 1 tile version, use the Small cfg file
;; Adds despawning options, vanilla version never despawns
;; Fixes an issue where hitting the block with your head could change its phase
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TouchEnable   = 0 ; 0 = active normally, 1 = stand on to activate, stays activated, 2 = must be standing on
!OnOffEnable   = 0 ; 0 = active normally, 1 = active while ON, 2 = active while OFF
!PSwitchEnable = 0 ; 0 = active normally, 1 = active while switch hit, 2 = active while switch not hit

!Despawn	   = 0    ; 0 = never despawn (vanilla behavior), 1+ = despawn
!DespawnRange = #$04  ; 0-7 Argument to SubOffScreen.  4 is recommended if despawning, it has the furthest range

;How many frames for each phase of movement, use $00 to end and loop back to the beginning
;The sample entries here move in a triangle in three phases
TimeInState:
db $40,$40,$40,$00

;X and Y speeds for each phase, you need one of these for each time entry except the final $00
XSpeed:
db $10,$00,$F0
YSpeed:
db $F0,$10,$00

;Here's another sample that moves in a square with pauses between each directions
;TimeInState:
;db $40,$20,$40,$20,$40,$20,$40,$20,$00
;XSpeed:
;db $10,$00,$00,$00,$F0,$00,$00,$00
;YSpeed:
;db $00,$00,$F0,$00,$00,$00,$10,$00


TileDispX:
db $00,$10,$00,$10
TileDispY:
db $00,$00,$10,$10
Tilemap:
db $CC,$CE,$EC,$EE
TileSmall:
db $8A

print "INIT ",pc
STZ !1510,x
if !TouchEnable = 1
STZ !151C,x
STZ !1534,x
endif
LDA.L TimeInState	;
STA !1540,x
RTL

print "MAIN ",pc
PHB : PHK : PLB
JSR GrayBlockMain
PLB
RTL

GrayBlockMain:
JSR GrayBlockGFX	; draw the sprite
LDA $9D		; if sprites are locked...
BEQ +
RTS
+



if !PSwitchEnable

if !PSwitchEnable = 1
	LDA $14AD|!Base2
	BNE +
endif
if !PSwitchEnable = 2
	LDA $14AD|!Base2
	BEQ +
endif

INC !1540,x

STZ !B6,x
JSL $018022	; and update sprite X position without gravity
STA !1528,x	; prevent the player from sliding

STZ !AA,x
JSL $01801A	; and update sprite Y position without gravity


BRA SolidBlock

+
endif

if !OnOffEnable

if !OnOffEnable = 1
	LDA $14AF|!Base2
	BEQ +
endif
if !OnOffEnable = 2
	LDA $14AF|!Base2
	BNE +
endif

INC !1540,x

STZ !B6,x
JSL $018022	; and update sprite X position without gravity
STA !1528,x	; prevent the player from sliding

STZ !AA,x
JSL $01801A	; and update sprite Y position without gravity


BRA SolidBlock

+
endif

if !TouchEnable

if !TouchEnable = 2
	STZ !151C,x
else
	LDA !151C,x
	BNE +
endif


LDA !1534,x
BEQ ++

JSL $01A7DC
BCC ++

LDA !D8,x
STA $00
LDA !14D4,x
STA $01

REP #$20
LDA $96
CLC
ADC #$000F
CMP $00
SEP #$20
BPL ++

LDA #$01
STA !151C,x
BRA +

++

INC !1540,x

STZ !B6,x
JSL $018022	; and update sprite X position without gravity
STA !1528,x	; prevent the player from sliding

STZ !AA,x
JSL $01801A	; and update sprite Y position without gravity


BRA SolidBlock
+
endif


LDA !1540,x
BNE NoStateChange	;


INC !1510,x	; increment the sprite state
-
LDA !1510,x	;
TAY		;
LDA TimeInState,y	;
BNE +
STZ !1510,x
BRA -
+
STA !1540,x


NoStateChange:	;
LDA !1510,x	;
TAY		;

LDA XSpeed,y	;

STA !B6,x		; if we're moving horizontally, store the speed value to the X speed table
JSL $018022	; and update sprite X position without gravity
STA !1528,x	; prevent the player from sliding

LDA !1510,x	;
TAY		;
LDA YSpeed,y	;
STA !AA,x	; if we're moving vertically, store the speed value to the Y speed table
JSL $01801A	; and update sprite Y position without gravity

SolidBlock:	;

LDA !9E,x	; this code wasn't in the original sprite; I had to add it
PHA		; preserve the current sprite number
LDA #$BB		; temporarily set the sprite number to the same as the original
STA !9E,x		; (this is necessary to prevent the player glitching through the sides)
JSL $01B44F	; invisible solid block routine
PLA		;
STA !9E,x		; restore the sprite number

if !TouchEnable
LDA $1471|!Base2
STA !1534,x
endif

Return0:

if !Despawn
	LDA !DespawnRange
	%SubOffScreen()
endif
RTS

GrayBlockGFX:
%GetDrawInfo()

LDA !extra_prop_1,x
BEQ +

LDA $00
STA $0300|!Base2,y
LDA $01
STA $0301|!Base2,y
LDA TileSmall
STA $0302|!Base2,y

LDA #$03		; second GFX page, palette 9
ORA $64		; add in level priority bits
STA $0303|!Base2,y

LDY #$02		; the tiles are 16x16
LDA #$00		; 1 tile were drawn
JSL $01B7B3|!BankB	;
RTS
+


LDX #$03		; 4 tiles to draw

GFXLoop:		;
LDA $00		;
CLC		;
ADC TileDispX,x	; set the tile X displacement
STA $0300|!Base2,y	;

LDA $01		;
CLC		;
ADC TileDispY,x	; set the tile Y displacement
STA $0301|!Base2,y	;

LDA Tilemap,x	; set the tile number
STA $0302|!Base2,y	;

LDA #$03		; second GFX page, palette 9
ORA $64		; add in level priority bits
STA $0303|!Base2,y	; set the tile properties

INY #4		;
DEX		; decrement the tile index
BPL GFXLoop	; if positive, draw more tiles

LDX $15E9|!Base2
LDY #$02		; the tiles are 16x16
LDA #$03		; 4 tiles were drawn
JSL $01B7B3|!BankB	;
RTS