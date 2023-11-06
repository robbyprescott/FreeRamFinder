;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Line-Guided Grinder (sprite 67), by imamelia
;;
;; This is a disassembly of sprite 67 in SMW, the line-guided Grinder.
;;
;; Uses first extra bit: YES
;; Uses extra property bytes: No
;;
;; If the extra bit is clear, the sprite won't disappear on even
;; X-coordinates like the original does.  Instead, it will simply move right instead
;; of left.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
db $F0,$00,$F0,$00

YDisp:
db $F0,$F0,$00,$00

TileProp:
db $33,$73,$B3,$F3

XOffsetLo:
db $FC,$04,$FC,$04

XOffsetHi:
db $FF,$00,$FF,$00

YOffsetLo:
db $FC,$FC,$04,$04

YOffsetHi:
db $FF,$FF,$00,$00

BitTable:
db $80,$40,$20,$10,$08,$04,$02,$01

Data1:
db $15,$15,$15,$15,$0C,$10,$10,$10
db $10,$0C,$0C,$10,$10,$10,$10,$0C
db $15,$15,$10,$10,$10,$10,$10,$10
db $10,$10,$10,$10,$10,$10,$15,$15

Data2:
db $00,$00,$00,$00,$00,$00,$01,$02
db $00,$00,$00,$00,$02,$01,$00,$00
db $00,$00,$01,$02,$01,$02,$00,$00
db $00,$00,$02,$02,$00,$00,$00,$00

SpeedTableY1:

db $00,$10,$00,$F0,$F4,$FC,$F0,$10
db $04,$0C,$0C,$00,$10,$F0,$FC,$F4
db $F0,$10,$F0,$10,$F0,$10,$F8,$F8
db $08,$08,$10,$10,$00,$00,$F0,$10
db $10,$00,$F0,$F0,$0C,$04,$10,$F0
db $00,$F4,$F4,$FC,$F0,$10,$00,$0C
db $10,$F0,$10,$00,$10,$F0,$08,$08
db $F8,$F8,$F0,$F0,$00,$00,$10,$F0

SpeedTableX1:
db $10,$00,$10,$00,$0C,$10,$04,$00
db $10,$0C,$0C,$10,$04,$00,$10,$0C
db $10,$10,$08,$08,$08,$08,$10,$10
db $10,$10,$00,$00,$10,$10,$10,$10
db $00,$F0,$00,$F0,$F4,$F0,$00,$FC
db $F0,$F4,$F4,$F0,$00,$FC,$F0,$F4
db $F0,$F0,$F8,$F8,$F8,$F8,$F0,$F0
db $F0,$F0,$00,$00,$F0,$F0,$F0,$F0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
JSR LineGrinderInit
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineGrinderInit:

INC !187B,x	;
LDA !7FAB10,x	; if the extra property byte 1 is set...
AND #$02
BEQ LineSpriteFix	; fix the init routine

LDA !E4,x	;
AND #$10	; if the sprite is on an odd X position...
BNE ShiftSmall	; shift it to the right 15 pixels

LDA !E4,x	; if the sprite is on an even X position...
SEC		;
SBC #$40		;
STA !E4,x		; shift it to the left
LDA !14E0,x	;
SBC #$01		; $0140 pixels
STA !14E0,x	;
BRA FinishLineSprInit 

ShiftSmall:

INC !157C,x	; make the sprite go to the left
LDA !E4,x	;
CLC		;
ADC #$0F		; shift the sprite right $0F pixels
STA !E4,x		; (without taking the high byte into account...!)     

FinishLineSprInit:

LDA #$02		;
STA !1540,x	;
RTS		;

LineSpriteFix:

LDA !E4,x		;
AND #$10		; sprite X position / $10
LSR #4			;
STA !157C,x		; into sprite direction
BRA FinishLineSprInit	;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR LineGrinderMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineGrinderMain:

LDA $13		;
AND #$07	; every 8 frames...
ORA !1626,x	; if the sprite is moving...
ORA $9D		; and sprites are not locked...
BNE NoSound	;
LDA #$04		; play the ticking sound effect
STA $1DFA|!Base2	;
NoSound:		;

JSR GrinderGFX	; draw the sprite
JSL $01A7DC	; interact with the player
; progress directly to the line-guided sprite handler routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main line-guided sprite routine ($01D74D)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineGuideHandlerMainRt:

LDA #$01
%SubOffScreen()

LDA !1540,x	; if the move timer is set...
BNE RunStatePtr	; skip the next check
LDA $9D		; if sprites are locked...
ORA !1626,x	; or the stationary flag is set...
BNE Return00	; return

RunStatePtr:	;

LDA !C2,x	; sprite state
JSL $0086DF	; 16-bit pointer routine

dw State00	;
dw State01	;
dw State02	;

Return00:		;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 00
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State00:

LDY #$03		;

TileCheckLoop:	;

STY $1695|!Base2	;

LDA !E4,x	;
CLC		;
ADC XOffsetLo,y	;
STA $02		; set up an X position variable, 4 pixels left or right
LDA !14E0,x	;
ADC XOffsetHi,y	;
STA $03		;

LDA !D8,x	;
CLC		;
ADC YOffsetLo,y	;
STA $00		; set up a Y position variable, 4 pixels up or down
LDA !14D4,x	;
ADC YOffsetHi,y	;
STA $01		;

LDA !1540,x	; if the move timer is set...
BNE GoToPosSet	; skip the next part

LDA $00		;
AND #$F0	; sprite X position with the individual pixel nybble clear
STA $04		;
LDA !D8,x	;
AND #$F0	;
CMP $04		; if the sprite Y position is not the same as the X position...
BNE GoToPosSet	; go directly to the position setup routine

LDA $02		;
AND #$F0	; sprite Y position with the individual pixel nybble clear
STA $05		;
LDA !E4,x	;
AND #$F0	;
CMP $05		; if the sprite X position is not the same as the Y position...
BEQ DecAndLoop	; skip the position setup routine entirely and go to the end of the loop

GoToPosSet:

JSR PositionSetup	;
BNE AltIndex	;

LDA $1693|!Base2	; check the low byte of the "acts like" setting of the Map16 tile that the sprite is touching
CMP #$94		;
BEQ OnOffCheck2	; if it is 94 or 95...
CMP #$95		; then it is an on/off line guide slope
BNE Continue1	;

LDA $14AF|!Base2	;
BEQ DecAndLoop	;
BNE Continue1	;

OnOffCheck2:	;

LDA $14AF|!Base2	;
BNE DecAndLoop	;    

Continue1:	;

LDA $1693|!Base2	;
CMP #$76		; if the tile number is less than 76...
BCC DecAndLoop	;
CMP #$9A	; or greater than 99...
BCC LineGuideTiles	; then it is not a line guide tile

DecAndLoop:

LDY $1695|!Base2	;
DEY		;
BPL TileCheckLoop	; loop 4 times

LDA !C2,x	; if we're running this code in sprite state 02...
CMP #$02		;
BEQ Return01	; terminate the code
LDA #$02		; if not,
STA !C2,x	; set the sprite state to 02

LDY !160E,x	; speed index
LDA !157C,x	; depending on sprite direction
BEQ NoAddToIndex	; if the sprite is moving left...
TYA		;
CLC		;
ADC #$20	; add $20 to the speed index
TAY		;
NoAddToIndex:	;
LDA SpeedTableY1,y;
BPL $01		; if the value is negative...
ASL		; left-shift it
PHY		;
ASL		; left-shift it once more...
STA !AA,x	; and store it to the sprite Y speed
PLY		;
LDA SpeedTableX1,y;
ASL		;
STA !B6,x		; set the sprite X speed
LDA #$10		;
STA !1540,x	; set the time to pause

Return01:		;
RTS		;

LineGuideTiles:

PHA		;
SEC		;
SBC #$76		; subtract 76 from the tile number so that the index begins at 00
TAY		;
PLA		; but we still want the actual tile number in A
CMP #$96		; if the tile is a line-guide end...
BCC NoAltIndex	; 

AltIndex:

LDY !160E,x	; then do this
BRA SkipChangePos	;

NoAltIndex:	;

LDA !D8,x	;
STA $08		; back up sprite position
LDA !14D4,x	;
STA $09		;
LDA !E4,x	;
STA $0A		;
LDA !14E0,x	;
STA $0B		;

LDA $00		; and then set the sprite position
STA !D8,x	;
LDA $01		; to the offset values from before
STA !14D4,x	;
LDA $02		;
STA !E4,x		;
LDA $03		;
STA !14E0,x	;

SkipChangePos:

PHB		; preserve the data bank
LDA #$07		; set the data bank to 07 (or 87)
PHA		;
PLB		;
LDA $FBF3,y	; $07FBF3-$07FC12: low byte of 16-bit pointer to line guide behaviors
STA !151C,x	;
LDA $FC13,y	; $07FC13-$07FC32: high byte of 16-bit pointer to line guide behaviors
STA !1528,x	;
PLB		;

LDA Data1,y	;
STA !1570,x	; not sure what this does

STZ !1534,x	;
TYA		; save the tile index
STA !160E,x	;

LDA !1540,x	; if the wait timer is set...
BNE SetState01	; change the sprite state to 01

STZ !157C,x	; set the sprite direction to right
LDA Data2,y	;
BEQ MoreSetups	;
TAY		;
LDA !D8,x	;
CPY #$01		;
BNE NoEORPixels	;
EOR #$0F		;
NoEORPixels:	;

BRA SkipLoadX	;

MoreSetups:	;

LDA !E4,x	;

SkipLoadX:

AND #$0F	;
CMP #$0A	;
BCC NoLeftDir	;
LDA !C2,x	;
CMP #$02		;
BEQ NoLeftDir	;
INC !157C,x	;
NoLeftDir:	;

LDA !D8,x	;
STA $0C		;
LDA !E4,x	;
STA $0D		;

JSR State01	;

LDA $0C		;
SEC		;
SBC !D8,x	;
CLC		;
ADC #$08	;
CMP #$10		;
BCS RestorePos2	;

LDA $0D		;
SEC		;
SBC !E4,x		;
CLC		;
ADC #$08	;
CMP #$10		;
BCS RestorePos2	;

SetState01:	;

LDA #$01		;
STA !C2,x	;
RTS		;

RestorePos2:

LDA $08		;
STA !D8,x	; set the sprite position
LDA $09		; to the values we stored before
STA !14D4,x	;
LDA $0A		;
STA !E4,x		;
LDA $0B		;
STA !14E0,x	;  

JMP DecAndLoop

PositionSetup:	; Some Map16-checking stuff.  I'm not even going to bother trying to comment this.

LDA $00		;
AND #$F0	;
STA $06		;
LDA $02		;
LSR #4		;
PHA		;
ORA $06		;
PHA		;
LDA $5B		;
AND #$01	;
BEQ Map16HLevel	;

Map16VLevel:	;

PLA		;
LDX $01		;
CLC		;
ADC $00BA80,x	;
STA $05		;
LDA $00BABC,x	;
ADC $03		;
STA $06		;
BRA Map16Continue	;

Map16HLevel:

PLA		;
LDX $03		;
CLC		;
ADC $00BA60,x	;
STA $05		;
LDA $00BA9C,x	;
ADC $01		;
STA $06		;

Map16Continue:

if !SA1
LDA #$40		; bank byte of pointer to tile low byte = $7E
else
LDA #$7E		; bank byte of pointer to tile low byte = $7E
endif
STA $07		;
LDX $15E9|!Base2	;
LDA [$05]		;
STA $1693|!Base2	;
INC $07		; bank byte of pointer to tile low byte = $7F
LDA [$05]		;
PLY		;
STY $05		;
PHA		;
LDA $05		;
AND #$07	;
TAY		;
PLA		;
AND BitTable,y	; $018000
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 01
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State01:

LDA $9D		;
BNE Return02	; return if sprites are locked
LDA !157C,x	;
BNE State01Left	; run a slightly different routine if the sprite is facing left

State01Right:

LDY !1534,x	;

JSR MoveSprPos	;

INC !1534,x	;
LDA !187B,x	; if this sprite table is set...
BEQ SkipFrameChk1	;
LDA $13		;
LSR		;
BCC SkipFrameChk1	; then the frame counter increments again every other frame
INC !1534,x	;
SkipFrameChk1:	;

LDA !1534,x	;
CMP !1570,x	; if the first counter equals the second...
BCC Return02	;
STZ !C2,x	; reset the sprite state

Return02:		;
RTS

State01Left:	;

LDY !1570,x	;
DEY		;

JSR MoveSprPos	;

DEC !1570,x	; if this counter has reached 0...
BEQ SetState00	; set the sprite state to 00
LDA !187B,x	;
BEQ Return02	; if this sprite table is set...
LDA $13		;
LSR		;
BCC Return02	; then the counter decrements again every other frame
DEC !1570,x	;
BNE Return02	;

SetState00:	;

STZ !C2,x	;
RTS		;

MoveSprPos:	;

PHB		;
LDA #$07		; once again, the data bank should be 07/87
PHA		;
PLB		;
LDA !151C,x	; low byte of pointer
STA $04		;
LDA !1528,x	; high byte of pointer
STA $05		;

LDA ($04),y	;
AND #$0F	; low byte of the pointed-to address: amount to move the sprite on the X-axis
STA $06		;
LDA ($04),y	;
PLB		;
LSR #4		;
STA $07		;

LDA !D8,x	;
AND #$F0	;
CLC		;
ADC $07		; change the sprite's Y position
STA !D8,x	;

LDA !E4,x	;
AND #$F0	;
CLC		;
ADC $06		; change the sprite's X position
STA !E4,x		;

RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 02
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State02:

LDA $9D		; if spites are locked...
BNE Return03	; return

JSL $01802A	; update sprite position

LDA !1540,x	; if the wait timer is set...
BNE Return03	;
LDA !AA,x	;
CMP #$20		; or the sprite speed is less than 20 (actually, between A0 and 1F)...
BMI Return03	;

JSR State00	; return

Return03:		;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GrinderGFX:

%GetDrawInfo()

PHX		; preserve the sprite index
LDX #$03		; 4 tiles to draw

GFXLoop:		;

LDA $00		;
CLC		;
ADC XDisp,x	; set the X displacement of the tile
STA $0300|!Base2,y	;

LDA $01		;
CLC		;
ADC YDisp,x	; set the Y displacement of the tile
STA $0301|!Base2,y	;

LDA $14		;
AND #$02	; add 00 or 02 to the tile
ORA #$6C	; the first tile used (the second one is 6E)
STA $0302|!Base2,y	; silly Nintendo, hardcoding tilemaps is stupid

LDA TileProp,x	;
STA $0303|!Base2,y	; set the tile properties

INY #4		; increment the OAM index
DEX		; decrement the tilemap index
BPL GFXLoop	;

PLX		; sprite index -> X
LDY #$02		; all tiles were 16x16
LDA #$03		; and 4 tiles were drawn
JSL $01B7B3	;
RTS
