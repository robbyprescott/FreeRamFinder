; See sprite !PipeTile on line 26x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Growing Pipe (sprite 49), by imamelia
;; Modified by Abdu to make it a small vertical/horizontal growing pipe
;; This is a disassembly of sprite 49 in SMW, the growing pipe.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is clear, the pipe will start out going up and the extrabyte is 00. 
;; If the first extra bit is set and the extra byte is set to 00, the pipe will start out going down.
;;
;; If the first extra bit is clear and the extra byte is 01, the pipe will start out going left. 
;; If the first extra bit is set and the extrabyte is set to 01, the pipe will start out going right.
;; Note:
;; By default the horizontal growing pipes generate tile 154 and 157 which is the yellow colored pipe so make sure you change that if thats not what you want.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!VerticalTile   = $0271 ; 0154
!HorizontalTile = $0274 ; 0157
Speed:
db $00,$F0,$00,$10

FrameCount:
db $20,$40,$20,$40

; 0 means dont delete that tile
TilesToGen1:
dw $0000,!VerticalTile,$0000,$0025

TilesToGen2:
dw $0000,!HorizontalTile,$0000,$0025



!Type = !extra_byte_1 ; if 1 then horz if 0 then vertical
!ExtraBit = $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

LDA #$40
STZ !1534,x

LDA !7FAB10,x		;
AND #!ExtraBit		; if the extra bit is set...
BEQ NotUpsideDown	;

INC !C2,x		; make the sprite start out in state 02
INC !C2,x		; so that it goes down instead

NotUpsideDown:		;

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
JSR GrowingPipeMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GrowingPipeMain:

LDA !1534,x	;
BMI Continue	; if the timer is positive...

LDA !Type
BNE +
LDA !D8,x	;
PHA		;
SEC		;
SBC !1534,x	;
STA !D8,x	; offset the sprite's Y position
LDA !14D4,x	;
PHA		;
SBC #$00		;
STA !14D4,x	;

LDY #$03		;
JSR GenerateTiles	;
PLA		;
STA !14D4,x	;
PLA		;
STA !D8,x	;

LDA !1534,x	;
SEC		;
SBC #$10		;
STA !1534,x	;
BRA .ret

+
LDA !E4,x	;
PHA		;
SEC		;
SBC !1534,x	;
STA !E4,x	; offset the sprite's X position
LDA !14E0,x	;
PHA		;
SBC #$00		;
STA !14E0,x	;

LDY #$03		;
JSR GenerateTiles	;
PLA		;
STA !14E0,x	;
PLA		;
STA !E4,x	;

LDA !1534,x	;
SEC		;
SBC #$10		;
STA !1534,x	;

.ret
RTS

Continue:		;

JSR GrowingPipeGFX

LDA #$00
%SubOffScreen()

LDA $9D			; if sprites or locked...
ORA !15A0,x		; or the sprite is offscreen horizontally...
BNE SkipPositionUpdate	; don't update its position

%SubHorzPos()		;

LDA $0F			;
CLC			;
ADC #$50		; if the sprite is more than 5 tiles away from the player...
CMP #$A0		;
BCS SkipPositionUpdate	; don't update the sprite's position

LDA !C2,x		;
AND #$03		;
TAY			;
INC !1570,x		;
LDA !1570,x		; after a certain number of frames...
CMP FrameCount,y		;
BNE NoChangeState		;
STZ !1570,x		;
INC !C2,x		; change the sprite state
BRA SkipPositionUpdate	;

NoChangeState:		;
LDA !Type,x
BNE .horz

LDA Speed,y		;
STA !AA,x		; if the sprite Y speed is nonzero...
BEQ SkipTileGen		;

LDA !D8,x		;
AND #$0F		; and the sprite is centered over a tile...
BNE SkipTileGen		;
BRA +

.horz   
LDA Speed,y		;
STA !B6,x		; if the sprite x speed is nonzero...
BEQ HSkipTileGen		;

LDA !E4,x		;
AND #$0F		; and the sprite is centered over a tile...
BNE HSkipTileGen		;

+ JSR GenerateTiles		; generate pipe tiles
LDA !Type,x
BNE HSkipTileGen
SkipTileGen:		;

JSL $01801A		; update sprite Y position
BRA SkipPositionUpdate

HSkipTileGen:
JSL $018022		; update sprite X position

SkipPositionUpdate:		;

JSL $01B44F		; make the sprite solid

RTS			;

GenerateTiles:		;

LDA !7FAB10,x		;
AND #!ExtraBit		;
BEQ NotUpsideDown2	;

TYA			;
INC			;
INC			;
AND #$03		;
TAY			;

NotUpsideDown2:		;

LDA !E4,x		;
STA $9A			; set the position
LDA !14E0,x		;
STA $9B			; of the tile
LDA !D8,x		;
STA $98			; that will be generated
LDA !14D4,x		;
STA $99			;

TYA     ;\
ASL     ;| multiply Y by two since each index is two bytes each.
TAY	    ;/

LDA !Type,x
BNE ++
REP #$20
LDA  TilesToGen1,y
BEQ +
%ChangeMap16()
+ SEP #$20
RTS
++
REP #$20
LDA  TilesToGen2,y
BEQ +
%ChangeMap16()
+ SEP #$20
RTS			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!PipeTile = $86
!PipeTileHorz = $8A

Tile: db !PipeTile, !PipeTileHorz
Properties: db $00, $80, $00, $40
; YXPP CCCT
; 1000 0000
; 0100 000
;  $7FAB40,x
GrowingPipeGFX:
%GetDrawInfo()
STZ $03
STZ $04
LDA !Type,x
BEQ +
INC $03
INC $03
INC $04
+

LDA !7FAB10,x    ;\
AND #!ExtraBit   ;| could just do it where I check if zero branch else set Y property bit to 1
BEQ +
INC $03
+ LDX $03
LDA Properties,x
STA $05
LDX $15E9

LDA $00		
STA $0300|!Base2,y	



LDA $01		
DEC		
STA $0301|!Base2,y	


LDX $04
LDA Tile,x
STA $0302|!Base2,y	
LDX $15E9

LDA !15F6,x	
ORA $05
ORA $64		
STA $0303|!Base2,y	;


LDA #$00		;
LDY #$02		;
JSL $01B7B3	;
RTS
