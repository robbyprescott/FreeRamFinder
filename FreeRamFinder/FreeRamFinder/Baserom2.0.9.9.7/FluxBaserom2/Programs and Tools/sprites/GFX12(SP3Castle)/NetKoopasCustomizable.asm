;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Net Koopas (sprites 22-25), by imamelia
;;
;; This is a disassembly of sprites 22-25 in SMW, the climbing net Koopas.
;;
;; Uses first extra bit: YES
;; Uses extra property bytes: YES
;;
;; The sprite uses its initial X position (00 or 01) plus the extra bit (00 or 02) plus
;; the first extra property byte (00 or 04) to determine its behavior.
;;
;; Behavior table:
;;
;; Bit 0: 0 = in front of the net, 1 = behind the net.
;; Bit 1: 0 = green and slow, 1 = red and fast.
;; Bit 2: 0 = horizontal, 1 = vertical.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ExtraBit = $04

HorizNetKoopaSpeed:
db $08,$F8

!VertNetKoopaSpeed = $F8

Behavior:
db $01,$00,$03,$02,$05,$04,$07,$06

Palettes:
db $0A,$08

Frame:
db $02,$02,$03,$04,$03,$02,$02,$02,$01,$02

GFXPage:
db $01,$01,$00,$00,$00,$01,$01,$01,$01,$01

ObjStatBits:
db $03,$0C

Tilemap:
db $07,$27,$4C,$29,$4E,$2B,$82,$A0,$82,$A0 ; last vanilla values are 84,$A4: SJC mod

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
PHB
PHK
PLB
JSR InitNetKoopa
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InitNetKoopa:

LDA !E4,x	; initial X position
AND #$10	;
LSR #4		; into bit 0
STA !1510,x	;
LDA !7FAB10,x	; extra bit table
AND #!ExtraBit	;
LSR		; change this to ASL if you're using GEMS and bit 0 for the extra bit
ORA !7FAB28,x	; add in the first extra property byte
TAY		; index into Y
LDA Behavior,y	;
ORA !1510,x	;
STA !1510,x	; sprite behavior bits 

AND #$04	; if bit 2 is set...
BNE InitVertical	; then the sprite is a vertical one

InitHorizontal:	;

%SubHorzPos()		;
LDA HorizNetKoopaSpeed,y	; set the sprite's initial X speed
STA !B6,x			;
BRA ContinueInit		;

InitVertical:		;

INC !C2,x		;
INC !B6,x			; sprite X speed of 01...?
LDA #$F8			; the vertical one always starts out going up
STA !AA,x		;

ContinueInit:		;

LDA !1510,x		; sprite behavior table
AND #$01		; determine whether it should go behind the net or not
STA !1632,x		;

LDA !1510,x		;
AND #$02		; if the sprite is the faster red one...
LSR			;
TAY			;
BEQ EndInit		;

ASL !B6,x			; make its speed
ASL !AA,x		; twice as fast

EndInit:			;

LDA !15F6,x		;
AND #$F1		;
ORA Palettes,y		; set the sprite palette
STA !15F6,x		;

RTS			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR NetKoopaMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NetKoopaMain:

LDA !1540,x	;
BEQ Skip1		; branch here if the timer has dropped to zero,
CMP #$30		;
BCC Skip2	; here if it is 01-2F
CMP #$40		;
BCC Skip3	; here if it is 30-3F
BNE Skip2		;
LDY $9D		; if the code reaches here, the timer is set to 40 exactly
BNE Skip2		; branch if sprites are locked
LDA !1632,x	;
EOR #$01		; flip the sprite's behind-screen status
STA !1632,x	;

JSR FlipDirection	; flip the sprite's direction
JSR FlipYSpeed	; and its Y speed
Skip2:		;
JMP Skip4		;

Skip3:		;

LDY !D8,x	;
PHY		;
LDY !14D4,x	; preserve the sprite's Y position
PHY		;
LDY #$00		; start Y at 00
CMP #$38		; if the timer was 38 or greater...
BCC NoIncY1	;
INY		; Y = 01
NoIncY1:		;

LDA !C2,x	; if the sprite state was 00...
BEQ Skip5		; skip the next part
INY		;
INY		; Y = 02 or 03
LDA !D8,x	;
SEC		;
SBC #$0C		; shift the sprite up 12 pixels
STA !D8,x	;
LDA !14D4,x	;
SBC #$00		;
STA !14D4,x	;

LDA !1632,x	; if the sprite is behind the net...
BEQ Skip5		;
INY		; increment Y once more

Skip5:		;

;LDA $1EEB	; a check for whether or not the Special World has been passed
;BPL NoIncY2	;
;INY #5		; uncomment and change $1EEB if necessary
;NoIncY2:		;

LDA Frame,y	;
STA !1602,x	; set the frame number
LDA GFXPage,y	;
STA $00		; and GFX page
LDA !15F6,x	;
PHA		; preserve the current GFX page
AND #$FE		;
ORA $00		; so that we can set it here
STA !15F6,x	;

JSR NetKoopaGFX	;

PLA		;
STA !15F6,x	;
PLA		; pull everything back
STA !14D4,x	;
PLA		;
STA !D8,x	;

RTS		;

Skip1:

LDA $9D		; if sprites are locked...
BNE Skip6		; skip the next part

JSL $019138	; interact with objects

LDY !C2,x	; sprite state
LDA !1588,x	;
AND ObjStatBits,y	; check for contact with either the walls or the ceiling
BEQ Continue1	; if there is contact...

Flip1:		;

JSR FlipDirection	; flip the sprite
JSR FlipYSpeed	;
BRA Skip4		; and continue

Continue1:	;

LDA $185F|!Base2		; check the low byte of the tile that the sprite is touching vertically
LDY !AA,x		; if the sprite's Y speed is zero...
BEQ CheckObjContH	; check the tiles horizontally
BMI CheckTileNumber2	;
CMP #$07			; if the tile number is less than 07...
BCC Flip1			; flip the sprite's direction
CMP #$1D		; if the tile number is 1D or greater...
BCS Flip1			; flip the sprite's direction

CheckObjContH:		;

LDA $1860|!Base2		; check the low byte of the tile that the sprite is touching horizontally
CheckTileNumber2:		;
CMP #$07			; if less then 07...
BCC ResetTimer		; reset $1540,x
CMP #$1D		; if 1D or greater...
BCC Skip4		; reset the timer also

ResetTimer:		;

LDA #$50			;
STA !1540,x		; turn timer?

Skip4:

LDA $9D		; if sprites are not locked...
BNE Skip6		;
INC !1570,x	;
JSR UpdateDirection	; change the sprite's direction as necessary
LDA !C2,x	; if the sprite is moving vertically...
BNE MoveVertically	; update its Y position; if moving horizontally...

JSL $018022	; update sprite X position without gravity
BRA Continue2	;

MoveVertically:	;

JSL $01801A	; update sprite Y position without gravity

Continue2:	;

JSL $01A7DC	; interact with the player
LDA #$00
%SubOffScreen()

Skip6:		;

LDA !157C,x	;
PHA		; preserve sprite direction
LDA !1570,x	;
AND #$08	;
LSR #3		;
STA !157C,x	; flip direction every few frames

LDA $64		;
PHA		; preserve sprite priority setting
LDA !1632,x	;
STA !1602,x	; back up the sprite status with respect to the net
BEQ NotBehind	; if the "behind scenery" flag isn't set, the sprite is in front of the net
LDA #$10		; if the sprite is behind the net...
STA $64		; change its priority setting
NotBehind:	;

JSR NetKoopaGFX	;

PLA		;
STA $64		; pull back stuff
PLA		;
STA !157C,x	;
RTS		;

FlipDirection:	;

LDA !15AC,x	; if the turn timer is set...
BNE Return1	; return
LDA #$08		;
STA !15AC,x	; set the turn timer
LDA !B6,x	;
EOR #$FF		; flip the sprite's Y speed
INC		;
STA !B6,x		;
LDA !157C,x	;
EOR #$01		; flip the sprite's horizontal direction
STA !157C,x	;
Return1:		;
RTS

FlipYSpeed:	;

LDA !AA,x	;
EOR #$FF		; flip the sprite's Y speed...obviously
INC		;
STA !AA,x	;
RTS

UpdateDirection:	;

LDA #$00		;
LDY !B6,x	;
BEQ Return1	; return if sprite X speed is zero
BPL StoreDir	;
INC		;
StoreDir:		;
STA !157C,x	;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NetKoopaGFX:	; this was actually a shared GFX routine adapted for this disassembly

%GetDrawInfo()

LDA !157C,x	;
STA $02		; back up the sprite direction

; removed sprite number check

LDA !1602,x	; frame number
ASL		; x2
TAX		; into X - use this to index the tilemap
LDA Tilemap,x	;
STA $0302|!Base2,y	; set the tile number of the first tile
LDA Tilemap+1,x	;
STA $0306|!Base2,y	; set the tile number of the second tile

LDX $15E9|!Base2	; sprite index back into X

LDA $01		;
STA $0301|!Base2,y	; no Y displacement for the first tile
CLC		;
ADC #$10	; Y displacement for the second tile - 16 pixels
STA $0305|!Base2,y	;

LDA $00		;
STA $0300|!Base2,y	; no X displacement
STA $0304|!Base2,y	; for the first tile or the second

LDA !157C,x	;
LSR		; sprite direction into carry flag
LDA !15F6,x	; sprite palette and GFX page
BCS NoFlipTiles	; if the sprite is facing right...
ORA #$40		; X-flip the tiles
NoFlipTiles:	;
ORA $64		; add in sprite priority setting
STA $0303|!Base2,y	; tile properties of the first tile
STA $0307|!Base2,y	; tile properties of the second tile

TYA		;
LSR		;
LSR		; tile OAM index / 4 = tile size index
TAY		;
LDA #$02		; 16x16 tiles
ORA !15A0,x	; set the offscreen flag if necessary
STA $0460|!Base2,y	; set the tile size of the first tile
STA $0461|!Base2,y	; set the tile size of the second tile

PHK		;
PER $0006	;
PEA $8020	;
JML $01A3DF	; set up some stuff in OAM...I don't know why they didn't just use $01B7B3

RTS
