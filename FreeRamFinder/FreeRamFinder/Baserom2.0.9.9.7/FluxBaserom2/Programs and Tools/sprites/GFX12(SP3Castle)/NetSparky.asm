;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Net Sparky / Fuzzy
;	by MarioFanGamer
;	based of imamelia's Net Koopa disassembly
;
; That one is a cross between a Sparky (a sprite which scales
; walls or moves on tracks) and a Net Koopa i.e. a Sparky which
; follows nets instead of walls. 
; Furthermore, it can not only be set to move onto nets but much
; like their Koopa counterpart, they can.
;
; Furthermore:
;
; Uses extra bit: YES. If clear, the sprite uses the Sparky
; graphics, otherwise the Fuzzy graphics.
;
; Uses extra bytes: One
;	Bit 0: Side of the net. 0 = foreground, 1 = background
;	Bit 1: Circling (switches side of net). 0 = no, 1 = yes
;	Bit 2: Direction. 0 = horizontal, 1 = vertical
;	Bit 3: Fixed direction. 0 = no (Sparky travels initially to
;		in Mario's direction), 1 = yes (direction depends on
;		bit 4).
;	Bit 4: If bit 3 set: Initial direction. 0 = right/down,
;		1 = left/up
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shared by both, horizontal and vertical movement.
!MovementSpeed = $10

!SparkyGfx = $0A
!FuzzyGfx = $C8

; Technical data, do not change

InitialSpeed:
db !MovementSpeed,-!MovementSpeed

ObjStatBits:
db $03,$0C

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

LDA !extra_byte_1,x	; Extra byte 1... 
AND #$01			; ... get bit 0...
STA !1632,x			; ... and set the side of net.

LDA !extra_byte_1,x	; Extra byte 1... 
AND #$04			; ... get bit 1...
LSR #2				; ... fix bit position...
STA !C2,x			; ... and set the direction.

LDA !extra_byte_1,x	; Extra byte 1 again...
LSR #4				; Bit 3 is in carry...
AND #$01			;
TAY					; ... while bit 4 in Y

LDA !C2,x
BNE InitVertical	; Initialise differently depending on direction.

InitHorizontal:		;

BCS FixedVerticalSpeed
%SubHorzPos()		;

FixedVerticalSpeed:
LDA InitialSpeed,y	; set the sprite's initial X speed
STA !B6,x			;
RTS					;

InitVertical:		;

BCS FixedHorizontalSpeed
%SubVertPos()		;

FixedHorizontalSpeed:
LDA InitialSpeed,y	; set the sprite's initial Y speed
STA !AA,x			;

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR NetSparkyMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NetSparkyMain:

LDA !14C8,x			;
EOR #$08			;
ORA $9D				;
BEQ .normal			; go to GFX routine if sprites are locked or sprite is falling off screen.
JMP NetSparkyGFX	;

.normal
LDA !1540,x			;
BEQ Skip1			; branch here if the timer has dropped to zero,
CMP #$10			;
BNE Skip4			;
LDA !1632,x			;
EOR #$01			; flip the sprite's behind-screen status
STA !1632,x			;

JSR FlipDirection	; flip the sprite's direction
JSR FlipYSpeed		; and its Y speed

JSR NetSparkyGFX	;

JMP UpdatePosition	;

Skip1:

LDA $9D				; if sprites are locked...
BNE Skip6			; skip the next part

JSL $019138|!bank	; interact with objects

LDY !C2,x			; sprite state
LDA !1588,x			;
AND ObjStatBits,y	; check for contact with either the walls or the ceiling
BEQ Continue1		; if there is contact...

Flip1:				;

JSR FlipDirection	; flip the sprite
JSR FlipYSpeed		;
BRA Skip4			; and continue

Continue1:			;

LDA $185F|!addr		; check the low byte of the tile that the sprite is touching vertically
LDY !AA,x			; if the sprite's Y speed is zero...
BNE CheckTileNumber	; check the tiles horizontally

CheckObjContH:		;

LDA $1860|!addr		; check the low byte of the tile that the sprite is touching horizontally

CheckTileNumber:	;
CMP #$07			; if less then 07...
BCC ResetTimer		; reset $1540,x
CMP #$1D			; if 1D or greater...
BCC Skip4			; reset the timer also

ResetTimer:			;

LDA !extra_byte_1,x	; If bit 2 of extra byte is not set
AND #$02			; ... turn around as if touching a wall.
BEQ Flip1			;

LDA #$20			;
STA !1540,x			; turn timer?

Skip4:

LDA $9D				; if sprites are not locked...
BNE Skip6			;
INC !1570,x			;
JSR UpdateDirection	; change the sprite's direction as necessary

UpdatePosition:

LDA !C2,x			; if the sprite is moving vertically...
BNE MoveVertically	; update its Y position; if moving horizontally...

JSL $018022|!bank	; update sprite X position without gravity
BRA Continue2		;

MoveVertically:		;

JSL $01801A|!bank	; update sprite Y position without gravity

Continue2:			;

JSL $01A7DC|!bank	; interact with the player
LDA #$00
%SubOffScreen()

Skip6:				;

LDA $64				;
PHA					; preserve sprite priority setting
LDA !1632,x			;
BEQ NotBehind		; if the "behind scenery" flag isn't set, the sprite is in front of the net
LDA #$10			; if the sprite is behind the net...
STA $64				; change its priority setting
NotBehind:			;

JSR NetSparkyGFX	;

PLA					;
STA $64				; pull back stuff
RTS					;

FlipDirection:		;

LDA !B6,x			;
EOR #$FF			; flip the sprite's Y speed
INC					;
STA !B6,x			;
RTS

FlipYSpeed:			;

LDA !AA,x			;
EOR #$FF			; flip the sprite's Y speed...obviously
INC					;
STA !AA,x			;
RTS

UpdateDirection:	;

LDA #$00			;
LDY !B6,x			;
BEQ Return1			; return if sprite X speed is zero
BPL StoreDir		;
INC					;
StoreDir:			;
STA !157C,x			;
Return1:
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NetSparkyGFX:		; this was actually a shared GFX routine adapted for this disassembly

%GetDrawInfo()

; removed sprite number check

LDA !extra_bits,x
LSR #3
LDA #!SparkyGfx
BCC StoreTile
LDA #!FuzzyGfx
StoreTile:
STA $0302|!addr,y	; set the tile number of the first tile

LDA !186C,x
LSR
BCS OffscreenVertically

LDA $01				;
STA $0301|!addr,y	; no Y displacement for the first tile

LDA $00				;
STA $0300|!addr,y	; no X displacement

LDA !extra_bits,x
AND #$04
BEQ SparkyProperties

LDA $14
LSR #3				; Flip direction every 
LDA !15F6,x			; sprite palette and GFX page
BCC NoFlipTiles		; if the sprite is facing right...
EOR #$40			; X-flip the tiles
NoFlipTiles:		;

GfxShared:
ORA $64				; add in sprite priority setting
STA $0303|!addr,y	; tile properties of the first tile

TYA					;
LSR					;
LSR					; tile OAM index / 4 = tile size index
TAY					;
LDA #$02			; 16x16 tiles
ORA !15A0,x			; set the offscreen flag if necessary
STA $0460|!addr,y	;
RTS

SparkyProperties:
LDA $14				; Get frame
AND #$0C			;
ASL #4				; rotate direction every 4th frame
EOR !15F6,x			; 

BRA GfxShared

OffscreenVertically:
LDA #$F0
STA $0301|!addr,y
RTS
