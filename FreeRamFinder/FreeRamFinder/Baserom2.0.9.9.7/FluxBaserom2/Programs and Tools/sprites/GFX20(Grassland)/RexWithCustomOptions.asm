; SJC: added extra bit squished option, c/o bucketofwetsocks	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Rex (sprite AB), by imamelia
;;
;; This is a disassembly of sprite AB in SMW, the Rex.
;;
;; Uses first extra bit: YES
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(Small GFX by Rykon-V73):Edit the GFX, palette and horizontal speed below:

!RSR		= $08       ;(Rex's speed when it heads right)
!RSL		= $F8	;(Rex's speed when it heads left)
!RSRS		= $10 	;(Small Rex's speed when it heads right)
!RSLS		 = $F0	;(Small Rex's speed when it heads right)

!RexHeadTile	= $8A
!RexWalkTile1	= $AA
!RexWalkTile2	= $AC
!RexSmallWlkTile1 = $8C
!RexSmallWlkTile2 = $A8
!RexSquishTile1 	= $A2	;(8x8 tile)
!RexSquishTile2	= $B2	;(8x8 tile)
!RPal1 		= $47 	;(this also controls GFX page)
!RPal2		= $07	;(this also controls GFX page)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSpeed:
db !RSR,!RSL,!RSRS,!RSLS

DeathSpeed:
db $F0,$10

XDisp:
db $FC,$00,$FC,$00,$FE,$00,$00,$00,$00,$00,$00,$08
db $04,$00,$04,$00,$02,$00,$00,$00,$00,$00,$08,$00

YDisp:
db $F1,$00,$F0,$00,$F8,$00,$00,$00,$00,$00,$08,$08

Tilemap:
db !RexHeadTile,!RexWalkTile1,!RexHeadTile,!RexWalkTile2,!RexHeadTile,!RexWalkTile1,!RexSmallWlkTile1,!RexSmallWlkTile1,!RexSmallWlkTile2,!RexSmallWlkTile2,!RexSquishTile1,!RexSquishTile2

TileProp:
db !RPal1,!RPal2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	%SubHorzPos()
	TYA		; face the player initially
	STA !157C,x	;

	; load in the extra bit here
	LDA !7FAB10,x
	AND #$04
	BEQ .return

	; extra bit is set, so we set our state of squished here.
	LDA #$01
	STA !C2,x

.return
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR RexMain	; $039517
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RexMain:

JSR RexGFX	; draw the Rex

LDA !14C8,x	; check the sprite status
CMP #$08		; if the Rex is not in normal status...
BNE Return00	;
LDA $9D		; or sprites are locked...
BNE Return00	; return

LDA !1558,x	; if the Rex has been fully squished and its remains are still showing...
BEQ Alive		;
STA !15D0,x	; set the "eaten" flag
DEC		; if this is the last frame to show the squished remains...
BNE Return00	;
STZ !14C8,x	; erase the sprite

Return00:		;
RTS		;

Alive:		;
%SubOffScreen()

INC !1570,x	; increment this sprite's frame counter (number of frames on the screen)
LDA !1570,x	;
LSR #2		; frame counter / 4
LDY !C2,x	; if the sprite is half-squished...
BEQ NoHSquish	;
AND #$01	; then it changes animation frame every 4 frames
CLC		;
ADC #$03	; and uses frame indexes 3 and 4
BRA SetFrame	;

NoHSquish:	;

LSR		; if the sprite is not half-squished,
AND #$01	; it changes animation frame every 8 frames

SetFrame:		;

STA !1602,x	; set the frame number

LDA !1588,x	;
AND #$04	; if the Rex is on the ground...
BEQ InAir		;

LDA #$10		; give it some Y speed
STA !AA,x	;

LDY !157C,x	; sprite direction
LDA !C2,x	;
BEQ NoFastSpeed	; if the Rex is half-squished...
INY #2		; increment the speed index so it uses faster speeds
NoFastSpeed:	;
LDA XSpeed,y	; set the sprite X speed
STA !B6,x		;

InAir:		;

LDA !1FE2,x	; if the timer to show the half-smushed Rex is set...
BNE NoUpdate	; don't update sprite position
JSL $01802A|!BankB	;
NoUpdate:	;

LDA !1588,x	;
AND #$03	; if the sprite is touching the side of an object...
BEQ NoFlipDir	;
LDA !157C,x	;
EOR #$01		; flip its direction
STA !157C,x	;

NoFlipDir:	;

JSL $018032|!BankB	; interact with other sprites
JSL $01A7DC|!BankB	; interact with the player
BCC NoContact	; carry clear -> no contact

LDA $1490|!Base2	; if the player has a star...
BNE StarKill	; run the star-killing routine	        
LDA !154C,x	; if the interaction-disable timer is set...
BNE NoContact	; act as if there were no contact at all

LDA #$08		;
STA !154C,x	; set the interaction-disable timer

LDA $7D		;
CMP #$10		; if the player's Y speed is not between 10 and 8F...
BMI SpriteWins	; then the sprite hurts the player

JSR RexPoints	; give the player some points
JSL $01AA33|!BankB	; boost the player's speed
JSL $01AB99|!BankB	; display contact graphics

LDA $140D|!Base2	; if the player is spin-jumping...
ORA $187A|!Base2	; or on Yoshi...
BNE SpinKill	; then kill the sprite directly
INC !C2,x	; otherwise, increment the sprite state
LDA !C2,x	;
CMP #$02		; if the sprite state is now 02...
BNE HalfSmushed	;
LDA #$20		; set the time to show the fully-squished remains
STA !1558,x	;
RTS

HalfSmushed:	;

LDA #$0C		; set the time to show the partly-smushed frame
STA !1FE2,x	; (since when is $1FE2,x a misc. sprite table?)
STZ !1662,x	; change the sprite clipping to 0 for the half-smushed Rex
RTS  

SpriteWins:	;

LDA $1497|!Base2	; if the player is flashing invincible...
ORA $187A|!Base2	; or is on Yoshi...
BNE NoContact	; just return
%SubHorzPos()	;
TYA		; make the Rex turn toward the player
JSL $00F5B7|!BankB	; and hurt the player

NoContact:	;
RTS		;

SpinKill:		;

LDA #$04		; sprite state = 04
STA !14C8,x	; spin-jump killed
LDA #$1F		; set spin jump animation timer
STA !1540,x	;

JSL $07FC3B|!BankB	; show star animation

LDA #$08		;
STA $1DF9|!Base2	; play spin-jump sound effect
RTS		;

StarKill:		;

LDA #$02		; sprite state = 02
STA !14C8,x	; killed (by star) and falling offscreen

LDA #$D0	;
STA !AA,x	; set killed Y speed
%SubHorzPos()	;
LDA DeathSpeed,y	; set killed X speed
STA !B6,x		;

INC $18D2|!Base2	; increment number of consecutive enemies killed
LDA $18D2|!Base2	;
CMP #$08		; if the number is 8 or greater...
BCC Not8Yet	;
LDA #$08		; keep it at 8
STA $18D2|!Base2	;
Not8Yet:		;

JSL $02ACE5	; give points

LDY $18D2|!Base2	;
CPY #$08		; if the number is less than 8...
BCS Return01	;
TYX		;
LDA $037FFF,x	; play a sound effect depending on that number
STA $1DF9|!Base2	;
LDX $15E9|!Base2	;

Return01:		;
RTS		;
					   
RexPoints:	;

PHY		;
LDA $1697|!Base2	; consecutive enemies stomped
CLC		;
ADC !1626,x	; plus number of enemies this sprite has killed (...huh?)
INC $1697|!Base2	; increment the counter
TAY		; -> Y
INY		; increment
CPY #$08		; if the result is 8+...
BCS NoSound	; don't play a sound effect
TYX		;
LDA $037FFF,x	; star sounds (X is never 0 here; they start at $038000)
STA $1DF9|!Base2	;
LDX $15E9|!Base2	;
NoSound:		;
TYA		;
CMP #$08		; if the number is 8+...
BCC GivePoints	;
LDA #$08		; just use 8 when giving points
GivePoints:	;
JSL $02ACE5|!BankB	;
PLY		;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RexGFX:

LDA !1558,x	; if the Rex is not squished...
BEQ NoFullSquish	; don't set the squished frame

LDA #$05		;
STA !1602,x	; set the frame (fully squished)

NoFullSquish:	;

LDA !1FE2,x	; if the time to show the half-squished Rex is nonzero...
BEQ NoHalfSquish	;

LDA #$02		;
STA !1602,x	; set the frame (half-squished)

NoHalfSquish:	;

%GetDrawInfo()
  
LDA !1602,x	;
ASL		; frame x 2
STA $03		; tilemap index

LDA !157C,x	;
STA $02		;

PHX		;
LDX #$01		; tiles to draw: 2

GFXLoop:		;

PHX		;
TXA		;
ORA $03		; add in the frame
PHA		; and save the result
LDX $02		; if the sprite direction is 00...
BNE FaceLeft	; then the sprite is facing right...
CLC		;
ADC #$0C	; and we need to add 0C to the X displacement index
FaceLeft:		;
TAX		;
LDA $00		;
CLC		;
ADC XDisp,x	; set the tile X displacement
STA $0300|!Base2,y	;

PLX		; previous index back
LDA $01		;
CLC		;
ADC YDisp,x	; set the tile Y displacement
STA $0301|!Base2,y	;

LDA Tilemap,x	;
STA $0302|!Base2,y	; set the tile number

LDX $02		;
LDA TileProp,x	; set the tile properties depending on direction
ORA $64		;
STA $0303|!Base2,y	;

TYA		;
LSR #2		; OAM index / 4
LDX $03		;
CPX #$0A		; if the frame is 5 (squished)...
TAX		;
LDA #$00		; set the tile size as 8x8
BCS SetTileSize	;
LDA #$02		; if the frame is less than 5, set the tile size to 16x16
SetTileSize:	;
STA $0460|!Base2,x	;
	PLX		; pull back the tile counter index
INY #4		; increment the OAM index
DEX		; if the tile counter is positive...
BPL GFXLoop	; there are more tiles to draw
				   
PLX		; pull back the sprite index
LDY #$FF		; Y = FF, because we already set the tile size
LDA #$01		; A = 01, because 2 tiles were drawn
JSL $01B7B3|!BankB	; finish the write to OAM
RTS		;