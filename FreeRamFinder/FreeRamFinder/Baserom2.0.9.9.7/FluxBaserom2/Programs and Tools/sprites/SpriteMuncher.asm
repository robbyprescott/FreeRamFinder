;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite 12F,
;reconfigured from the electric block by RussianMan

;This currently is incompatible with timed on/off switch for some reason
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


!AnimationTime = $07		;how many frames it takes to change animation frame. Can be only $01,$03,$07,$0F,$1F,$3F,$7F and $FF

Tiles:
db $40,$A8,$AA			;Only uses 2 last bytes for animation? Needs GFX104 in SP4

!AnimationFramesNum = $01	;$01 = 2. two last table values are used for animation.

;RAM Variables you probably shouldn't change;

!AnimationCounter = !C2,x


;;;;;;;;;;;;;
;Actual code;
;;;;;;;;;;;;;

Print "MAIN ",pc		;push bank stuff and etc.
PHB				;
PHK				;
PLB				;
JSR Code			;
PLB				;
Print "INIT ",pc		;No INIT code
RTL				;

Code:
JSR GFX				;>draw sprite onscreen

LDA !14C8,x			;\if it's dead or not in normal state for whatever reason...
EOR #$08			;|
ORA $9D				;|...OR if game is locked...
BNE .Return			;/...return.
%SubOffScreen()

JSL $019138|!BankB		;interact with objects


LDA $14
AND #!AnimationTime
BNE .Interact

INC !AnimationCounter		;increase animation counter

.Interact

;jsl $018032|!BankB    ; general sprite interact, thrown sprites at?

JSL $01A7DC|!BankB		;\if not interacting with player....
BCC .Return			;/...return

JSL $01B44F|!BankB		;act like a solid block for Mario

JSL $00F5B7|!BankB		;hurt player on contact

.Return
RTS

GFX:
%GetDrawInfo()		;|

LDA $00				;\Set sprite tile's X-position
STA $0300|!Base2,y		;/

LDA $01				;\Set sprite tile's Y-position
STA $0301|!Base2,y		;/

PHX				; must keep, push X register


LDA !AnimationCounter		;\otherwise use animation
AND #!AnimationFramesNum	;|use animation counter
INC				;|+1
				;|
;.NotIn				;|
TAX				;/must keep, turn A into X and use that as index for table

LDA Tiles,x			;\load tile from table
STA $0302|!Base2,y		;/store tile for display
PLX				;pull x register

LDA !15F6,x			;\set stuff in config file
ORA $64				;|and priority
STA $0303|!Base2,y		;/store properties

LDY #$02			;\use 16x16 tile size (LDY #$00 for 8x8)
LDA #$00			;|one tile
JSL $01B7B3|!BankB		;/preparations done, draw sprite tile
RTS				;return