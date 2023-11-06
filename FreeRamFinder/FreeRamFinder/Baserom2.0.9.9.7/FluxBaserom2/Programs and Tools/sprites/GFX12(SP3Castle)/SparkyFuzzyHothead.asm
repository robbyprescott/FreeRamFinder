;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Sparky/Fuzzy and Hothead (sprite A5 & A6), by imamelia
;;
;; This is a disassembly of sprites A5 and A6 in SMW, the wall-following Sparky/Fuzzy
;; and the Hothead.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is clear, the sprite will act like a Sparky/Fuzzy.  If the extra bit
;; is set, the sprite will act like a Hothead.  Also, if the extra bit is clear and the
;; sprite tileset is 02, the sprite will use the Fuzzy graphics.  (If the sprite tileset
;; is anything else, then it will use the Sparky graphics.)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!ExtraBit = $04	; may be changed to 01 if using GEMS
!SparkyTile = $0A
!FuzzyTile = $C8
!HotheadEyeTile1 = $09
!HotheadEyeTile2 = $19


InitXSpeed:
db $08,$00
InitYSpeed:
db $00,$08

XSpeed:
db $01,$FF,$FF,$01,$FF,$01,$01,$FF
YSpeed:
db $01,$01,$FF,$FF,$01,$01,$FF,$FF

XSpeed2:
db $08,$00,$F8,$00,$F8,$00,$08,$00
YSpeed2:
db $00,$08,$00,$F8,$00,$08,$00,$F8

ObjCheckVals:
db $01,$04,$02,$08,$02,$04,$01,$08
FuzzyTileProp:
db $05,$45

HotheadXDisp:
db $F8,$08,$F8,$08
HotheadYDisp:
db $F8,$F8,$08,$08
HotheadTiles:
db $0C,$0E,$0E,$0C,$0E,$0C,$0C,$0E
HotheadTileProp:
db $05,$05,$C5,$C5,$45,$45,$85,$85

EyesXDisp:
db $07,$07,$01,$01,$01,$01,$07,$07
EyesYDisp:
db $00,$08,$08,$00,$00,$08,$08,$00

print "INIT ",pc
	PHB
	PHK
	PLB
	JSR InitSparky
	PLB
	RTL

InitSparky:
	LDA !E4,x	; sprite X position
	LDY #$00		;
	AND #$10	;
	EOR #$10		;
	STA !151C,x	;
	BNE StartOutLeft	; move right if the sprite is on an odd X coordinate
	INY		;
StartOutLeft:	;
	LDA InitXSpeed,y	;
	STA !B6,x		; set the sprite's initial X speed
	LDA InitYSpeed,y	;
	STA !AA,x	; set the sprite's initial Y speed
	INC !164A,x	;
	LDA !151C,x	;
	LSR #2
	STA !C2,x	;

	LDA !7FAB10,x		;
	AND #!ExtraBit		;
	STA !1510,x		; save the extra bit
	BEQ NoChangeClipping	; if the extra bit is set...
	LDA #$27			; set the sprite clipping
	STA !1662,x		; for the Hothead
NoChangeClipping:		;
	RTS


print "MAIN ",pc
	PHB : PHK : PLB : JSR Main : PLB
	RTL

Main:
	JSL $018032|!BankB	; interact with sprites
	JSL $01ACF9|!BankB	; get a random number
	ORA $9D		;
	BNE NoSet1	; if sprites are locked or the number was not 0...
	LDA #$0C		; don't set this timer
	STA !1558,x	;
NoSet1:		;
	JSR SubGFX
     
	LDA !14C8,x	;
	CMP #$08		; if the sprite is still alive...
	BEQ StillAlive	; skip this termination code
	STZ !1528,x	;
	LDA #$FF		;
	STA !1558,x	; reset this timer
Return0:		;
	RTS

StillAlive:		
	LDA $9D		; if sprites are locked...
	BNE Return0	; return
	%SubOffScreen()

	JSL $01A7DC|!BankB	; interact with the player

	LDA !1540,x	;
	BNE Skip1		; branch if the timer is set

	LDY !C2,x	;
	LDA YSpeed,y	; set the sprite's Y speed
	STA !AA,x	;
	LDA XSpeed,y	; set the sprite's X speed
	STA !B6,x		;

	JSL $019138|!BankB	; interact with objects

	LDA !1588,x	; check the sprite's object status
	AND #$0F	; if the sprite is touching an object...
	BNE Skip1		; branch

	LDA #$08		;
	STA !1564,x	; disable contact with other sprites
	LDA #$1A		; timer = 1A
	LDY !1510,x	; if the sprite is a Hothead...
	BNE SetTimer1	;
	LSR		; timer = 0D
SetTimer1:	;
	STA !1540,x	;

Skip1:		;

	LDA #$10		; check value = 10
	LDY !1510,x	; if the extra bit is set...
	BNE CheckTimer1	;
	LSR		; check value = 08
CheckTimer1:	;
	CMP !1540,x	; if the timer has reached the check value...
	BNE NoChangeState	;
	INC !C2,x	; change the sprite state
	LDA !C2,x	;
	CMP #$04		; if the sprite state has reached 04...
	BNE NoResetState	;
	STZ !C2,x	; reset it to 00
NoResetState:	;
	CMP #$08		; if it is 08...
	BNE NoChangeState	;
	LDA #$04		; set it to 04
	STA !C2,x	;

NoChangeState:	;
	LDY !C2,x		;
	LDA !1588,x		; check the object contact status
	AND ObjCheckVals,y	; depending on the sprite state
	BEQ Skip2			; if the sprite isn't touching the specified surface, skip the next part
	LDA #$08			;
	STA !1564,x		; disable contact with other sprites for a few frames
	DEC !C2,x		; decrement the sprite state
	LDA !C2,x		;
	BPL CompareState1		; if the result was positive, branch
	LDA #$03			;
	BRA StoreState1		; set the sprite state to 03

CompareState1:		;
	CMP #$03			;
	BNE Skip2			;
	LDA #$07			;
StoreState1:		;
	STA !C2,x		;

Skip2:			;
	LDY !C2,x		;
	LDA YSpeed2,y		; set the sprite's Y speed
	STA !AA,x		;
	LDA XSpeed2,y		;
	STA !B6,x			;

	LDY !1510,x		; if the extra bit is set...
	BNE SlowerSpeed		;
	ASL !B6,x			; double both speed values
	ASL !AA,x		;
SlowerSpeed:		;
	JSL $018022|!BankB		; update sprite X position without gravity
	JSL $01801A|!BankB		; update sprite Y position without gravity
	RTS

SubGFX:
	%GetDrawInfo()

	LDA !1510,x	; if the extra bit is set...
	BNE DrawHothead	; draw the Hothead
	PHY
	JSR SparkyGFX	; if not, draw the Sparky...
	PLY

	LDA $192B|!Base2	; unless the sprite tileset
	CMP #$02		; is 02, in which case...
	BNE FinishSparky	; we should draw the Fuzzy

FuzzyGFX:
	PHX			;
	LDA $14			;
	LSR #2			;
	AND #$01		; make the Fuzzy animate...
	TAX			; by X-flipping every 4 frames
	LDA #!FuzzyTile		;
	STA $0302|!Base2,y		; set the tile number
	LDA FuzzyTileProp,x	;
	ORA $64			; set the tile properties
	STA $0303|!Base2,y		;
	PLX			;
	RTS			;

FinishSparky:		;

	LDA $14		;
	AND #$0C	;
	ASL #4		; determine the flip of the tile
	EOR $0303|!Base2,y	;
	STA $0303|!Base2,y	;

	RTS

DrawHothead:	;
	JMP HotheadGFX	;

SparkyGFX:		
	LDA #!SparkyTile		;
	STA $0302|!Base2,y		; set the tile number

	LDA $00			;
	STA $0300|!Base2,y		; no X displacement
	LDA $01			;
	STA $0301|!Base2,y		; or Y displacement

	LDA !157C,x		;
	LSR			; sprite direction into carry flag
	LDA !15F6,x		;
	BCS NoFlipTile		; if the sprite was facing to the right...
	EOR #$40			; flip the tile
NoFlipTile:		;
	ORA $64			;
	STA $0303|!Base2,y		;

	TYA		;
	LSR #2
	TAY		;
	LDA #$02		; 16x16 tiles
	ORA !15A0,x	; set the offscreen flag if necessary
	STA $0460|!Base2,y	; set the tile size

	PHK		;
	PER $0006
	PEA $8020
	JML $01A3DF|!BankB	; once again, why couldn't they just have used $01B7B3?
	RTS

HotheadGFX:	;
	TYA		;
	CLC		;
	ADC #$04	; offset the sprite OAM index by 4
	STA !15EA,x	; for some reason
	TAY		;

	LDA $14		;
	AND #$04	;
	STA $03		;
	PHX		;
	LDX #$03		; 4 tiles to draw

HotheadLoop:
	LDA $00			;
	CLC			;
	ADC HotheadXDisp,x	; set the tile X displacement
	STA $0300|!Base2,y		;

	LDA $01			;
	CLC			;
	ADC HotheadYDisp,x	; set the tile Y displacement
	STA $0301|!Base2,y		;

	PHX			;
	TXA			;
	ORA $03			;
	TAX			;

	LDA HotheadTiles,x		;
	STA $0302|!Base2,y		; set the tilemap

	LDA HotheadTileProp,x	;
	ORA $64			; set the tile properties
	STA $0303|!Base2,y		;

	PLX			;
	INY #4			;
	DEX			;
	BPL HotheadLoop		; loop if there are more tiles to draw

	PLX			;
	PEI ($00)			; preserve the X and Y position,
	LDY #$02			;
	LDA #$03			;
	JSL $01B7B3|!BankB		; because we'll need them for the eye tiles
	PLA			;
	STA $00			; retain the values of the
	PLA			; sprite X and Y position relative to screen border
	STA $01			;

	LDA #!HotheadEyeTile1	;
	LDY !1558,x		; determine which eye tile to use
	BEQ SetEyeTile		;
	LDA #!HotheadEyeTile2	;
SetEyeTile:		;
	STA $02			;

	LDA !15EA,x		;
	SEC			;
	SBC #$04			; counteract the addition of 4 to the OAM index
	STA !15EA,x		;

	TAY			;
	PHX			;
	LDA !C2,x		; use the sprite state as an index
	TAX			;

	LDA $00			;
	CLC			;
	ADC EyesXDisp,x		; set the tile X displacement
	STA $0300|!Base2,y		;

	LDA $01			;
	CLC			;
	ADC EyesYDisp,x		; set the tile Y displacement
	STA $0301|!Base2,y		;

	LDA $02			; set the tile number for the eyes
	STA $0302|!Base2,y		;

	LDA #$05			;
	ORA $64			;
	STA $0303|!Base2,y		; set the tile properties

	PLX			;
	LDY #$00			; 8x8 tile
	LDA #$00			; 1 tile
	JSL $01B7B3|!BankB		;
	RTS			;