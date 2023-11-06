;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Bullet Bill (sprite 1C), by imamelia. (Modifications by SpacePig)
;;
;; This is a disassembly of sprite 1C in SMW, the Bullet Bill.
;;
;; Uses first extra bit: NO
;;
;; Extra byte 1: X Speed	;  0-7F = right momentum ; FF-80 = left momentum 
;; Extra byte 2: facing direction ; 0=left. 1=right 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




Tilemap:
db $A6,$A4,$A6,$A8

TileProperties:
db $42,$02,$03,$83,$03,$43,$03,$43

Frames:
db $00,$00,$01,$01,$02,$03,$03,$02

XSpeed:
db $0A,$F6,$00,$00,$18,$18,$E8,$E8

YSpeed:
db $00,$00,$E0,$20,$E8,$18,$18,$E8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

;JSR SubHorzPos	;
;TYA		;
LDA #$10		;
STA $1540,x	; set the "behind screen" timer
LDA !extra_byte_2,x	; load byte 2
CMP #$01
BEQ Direction
LDA #$01
STA $C2,x	; make bill face left or right
Direction:
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
JSR BulletBillMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BulletBillMain:

LDA #$01		; set
STA $157C,x	;

LDA $9D		; if sprites are locked...
BNE Skip1		; skip this next part of code

LDY $C2,x	;
LDA TileProperties,y	; set the tile properties for the GFX routine
STA $15F6,x	; depending on the sprite state
LDA Frames,y	; set the frame
STA $1602,x	; depending on the sprite state
LDA !extra_byte_1,x	;
STA $B6,x		; set the X speed
LDA YSpeed,y	;
STA $AA,x	; set the Y speed

JSL $018022	; update sprite X position without gravity
JSL $01801A	; update sprite Y position without gravity
JSL $019138	; interact with objects
JSL $01803A	; interact with the player and with other sprites

Skip1:		;

JSR SubOffscreenX0	; offscreen processing code

LDA $D8,x	; sprite Y position
SEC		;
SBC $1C		; minus vertical screen boundary
CMP #$F0		; if the sprite has gone too far offscreen...
BCC NoErase	;
STZ $14C8,x	; erase it
NoErase:		;

LDA $1540,x	; if the behind-screen timer is set...
BEQ BulletBillGFX	; put the sprite behind the foreground

LDA $64		;
PHA		; preserve the current priority settings
LDA #$10		;
STA $64		; and set the priority lower

JSR BulletBillGFX	; draw the sprite

PLA		;
STA $64		; restore the old priority settings

RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BulletBillGFX:	; almost directly ripped from $0190B2

JSR GetDrawInfo	;

LDA $157C,x	;
STA $02		;

LDA $1602,x	;
TAX		;
LDA Tilemap,x	; set the sprite tilemap
STA $0302,y	;

LDX $15E9	;
LDA $00		;
STA $0300,y	; no X displacement
LDA $01		;
STA $0301,y	; no Y displacement

LDA $157C,x	;
LSR		; if the sprite is facing right...
LDA $15F6,x	;
BCS NoXFlip	; X-flip it
EOR #$40		;
NoXFlip:		;
ORA $64		;
STA $0303,y	;

TYA		;
LSR #2		;
TAY		;

LDA #$02		;
ORA $15A0,x	;
STA $0460,y	; set the tile size

PHK		;
PER $0006	;
PEA $8020	;
JML $81A3DF	; set up some stuff in OAM

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; subroutines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Table1:              db $0C,$1C
Table2:              db $01,$02
Table3:              db $40,$B0
Table6:              db $01,$FF
Table4:              db $30,$C0,$A0,$C0,$A0,$F0,$60,$90,$30,$C0,$A0,$80,$A0,$40,$60,$B0
Table5:              db $01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$FF,$01,$00,$01,$FF

SubOffscreenX0:
LDA #$00
;BRA SubOffscreenMain
;SubOffscreenX1:
;LDA #$02
;BRA SubOffscreenMain
;SubOffscreenX2:
;LDA #$04
;BRA SubOffscreenMain
;SubOffscreenX3:
;LDA #$06
;BRA SubOffscreenMain
;SubOffscreenX4:
;LDA #$08
;BRA SubOffscreenMain
;SubOffscreenX5:
;LDA #$0A
;BRA SubOffscreenMain
;SubOffscreenX6:
;LDA #$0C
;BRA SubOffscreenMain
;SubOffscreenX7:
;LDA #$0E

SubOffscreenMain:

STA $03

JSR SubIsOffscreen
BEQ Return2

LDA $5B
LSR
BCS VerticalLevel
LDA $D8,x
CLC
ADC #$50
LDA $14D4,x
ADC #$00
CMP #$02
BPL EraseSprite
LDA $167A,x
AND #$04
BNE Return2
LDA $13
AND #$01
ORA $03
STA $01
TAY
LDA $1A
CLC
ADC Table4,y
ROL $00
CMP $E4,x
PHP
LDA $1B
LSR $00
ADC Table5,y
PLP
SBC $14E0,x
STA $00
LSR $01
BCC Label20
EOR #$80
STA $00
Label20:
LDA $00
BPL Return2

EraseSprite:
LDA $14C8,x
CMP #$08
BCC KillSprite
LDY $161A,x
CPY #$FF
BEQ KillSprite
LDA #$00
STA $1938,y
KillSprite:
STZ $14C8,x
Return2:
RTS

VerticalLevel:

LDA $167A,x
AND #$04
BNE Return2
LDA $13
LSR
BCS Return2
AND #$01
STA $01
TAY
LDA $1C
CLC
ADC Table3,y
ROL $00
CMP $D8,x
PHP
LDA $1D
LSR $00
ADC Table6,y
PLP
SBC $14D4,x
STA $00
LDY $02
BEQ Label22
EOR #$80
STA $00
Label22:
LDA $00
BPL Return2
BMI EraseSprite

SubIsOffscreen:
LDA $15A0,x
ORA $186C,x
RTS

GetDrawInfo:

STZ $186C,x
STZ $15A0,x
LDA $E4,x
CMP $1A
LDA $14E0,x
SBC $1B
BEQ OnscreenX
INC $15A0,x
OnscreenX:
LDA $14E0,x
XBA
LDA $E4,x
REP #$20
SEC
SBC $1A
CLC
ADC.w #$0040
CMP #$0180
SEP #$20
ROL A
AND #$01
STA $15C4,x
BNE Invalid

LDY #$00
LDA $1662,x
AND #$20
BEQ OnscreenLoop
INY
OnscreenLoop:
LDA $D8,x
CLC
ADC Table1,y
PHP
CMP $1C
ROL $00
PLP
LDA $14D4,x
ADC #$00
LSR $00
SBC $1D
BEQ OnscreenY
LDA $186C,x
ORA Table2,y
STA $186C,x
OnscreenY:
DEY
BPL OnscreenLoop
LDY $15EA,x
LDA $E4,x
SEC
SBC $1A
STA $00
LDA $D8,x
SEC
SBC $1C
STA $01
RTS

Invalid:
PLA
PLA
RTS

SubHorzPos:

LDY #$00
LDA $94
SEC
SBC $E4,x
STA $0F
LDA $95
SBC $14E0,x
BPL $01
INY
RTS











