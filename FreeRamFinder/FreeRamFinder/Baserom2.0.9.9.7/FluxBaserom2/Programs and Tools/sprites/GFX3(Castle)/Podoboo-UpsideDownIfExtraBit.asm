; GFX also work in these: SP4=04/0E/22

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Vertical Fireball (sprite 33), by imamelia
;;
;; This is a modified disassembly of sprite 33 in SMW, the vertical fireball (or Podoboo, if you prefer).
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is set, this will be an upside-down Podoboo.  If the first extra
;; bit is clear, this will just be a normal Podoboo.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ExtraBit = $04

!UseDynamicGFX = 0	; Set this to zero to make the vertical fireball use non-dynamic graphics. You might want to change the tilemap, though.

YSpeeds:
db $F0,$DC,$D0,$C8,$C0,$B8,$B2,$AC
db $A6,$A0,$9A,$96,$92,$8C,$88,$84
db $80,$04,$08,$0C,$10,$14

YSpeeds2:
db $10,$24,$30,$38,$40,$48,$4E,$54
db $5A,$60,$66,$6A,$6E,$74,$78,$7C
db $7F,$FC,$F8,$F4,$F0,$EC

!Timer2Check = $70

Tilemap:
db $06,$06,$16,$16,$07,$07,$17,$17,$16,$16,$06,$06,$17,$17,$07,$07

XDisp:
db $00,$08,$00,$08

YDisp:
db $00,$00,$08,$08

XFlip:
db $00,$40,$00,$40

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

PHB
PHK
PLB
JSR PodobooInit
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PodobooInit:

LDA !D8,x	; sprite Y position low byte
STA !1528,x	; save in multi-purpose table
LDA !14D4,x	; sprite Y position high byte
STA !151C,x	; same

LDA !7FAB10,x		;
AND #!ExtraBit		;
STA !1504,x		;
BNE LiquidContactLoop2	;

LiquidContactLoop:	;

LDA !D8,x	;
CLC		;
ADC #$10	;
STA !D8,x	; shift the sprite's Y position down 1 tile
LDA !14D4,x	;
ADC #$00	;
STA !14D4,x	;

JSL $019138|!BankB	; make the sprite interact with objects

LDA !164A,x		; if the sprite is not in contact with water or lava...
BEQ LiquidContactLoop	; shift it down again until it is

JSR SetYSpeed		;

LDA #$20			; set the timer until it jumps
STA !1540,x		;

RTS			;

LiquidContactLoop2:	;

LDA !D8,x	;
SEC		;
SBC #$10		;
STA !D8,x	; shift the sprite's Y position up 1 tile
LDA !14D4,x	;
SBC #$00		;
STA !14D4,x	;

JSL $019138|!BankB	; make the sprite interact with objects

LDA !164A,x		; if the sprite is not in contact with water or lava...
BEQ LiquidContactLoop2	; shift it down again until it is

JSR SetYSpeed		;

LDA #$20			; set the timer until it jumps
STA !1540,x		;

RTS			;

; Note: This explains why the Podoboo freezes the game when sprite buoyancy is not enabled.
; The init routine checks to see if the sprite is in contact with water or lava using $164A,x,
; and if it is not, the code jumps back to the beginning of the loop, shifts the sprite down a tile,
; and checks again.  BUT...if sprite buoyancy is not enabled, $164A,x will never get set.  This
; sends the init routine into an infinite loop.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR PodobooMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PodobooMain:

STZ !15D0,x	; clear the...being eaten flag??
LDA !1540,x	; check the timer
BEQ StartMoving	; if it is zero, then make the fireball start going up
DEC		; if it is down to 01...
BNE Return0	; this is the last frame before the fireball will start moving,
LDA #$27		; so play a fiery sound effect
STA $1DFC|!Base2	;
Return0:		;
RTS		;

StartMoving:	;

LDA $9D		; if sprites are locked...
BEQ NotLocked	;
JMP PodobooGFX	; skip the speed setting, lava trail, etc.

NotLocked:	;

JSL $01A7DC|!BankB		; interact with the player
JSR SetAnimationFrame	;
;JSR SetAnimationFrame	; instead of calling this twice, I just modified the subroutine itself

LDA !15F6,x		;
AND #$7F		; clear the Y-flip bit of the sprite palette and GFX page...
LDY !AA,x		; if the sprite's Y speed is negative...
BMI NoFlip		; don't Y-flip the sprite's graphics
INC !1602,x		;
INC !1602,x		; increment the animation frame
ORA #$80			; and Y-flip the sprite's graphics
NoFlip:			;
STA !15F6,x		;

JSL $019138|!BankB		; check for contact with objects

LDA !164A,x		; if the sprite is in lava or water...
BEQ NoResetYSpeed		;

LDA !1504,x		;
BNE NoResetCheck2		;

LDA !AA,x		; and the sprite's Y speed is positive...
BMI NoResetYSpeed		;
BRA SkipCheck2		;

NoResetCheck2:		;

LDA !AA,x		; and the sprite's Y speed is positive...
BPL NoResetYSpeed		;

SkipCheck2:		;

JSL $01ACF9|!BankB		;
AND #$3F		;
ADC #$60		; then set the jump timer to a random number
STA !1540,x		; between 60 and 9F

SetYSpeed:

LDA !1504,x	;
BNE InvertYSpeed	;

LDA !D8,x	;
SEC		;
SBC !1528,x	;
STA $00		;
LDA !14D4,x	;
SBC !151C,x	;
LSR		;
ROR $00		; uh...
LDA $00		;
LSR #3		;
TAY		;

LDA YSpeeds,y	;
BMI StoreYSpeed	;
STA !1564,x	; ...
LDA #$80		;
StoreYSpeed:	;
STA !AA,x	;
RTS		;

InvertYSpeed:	;

LDA !1528,x	;
SEC		;
SBC !D8,x	;
STA $00		;
LDA !151C,x	;
SBC !14D4,x	;
LSR		;
ROR $00		; uh...
LDA $00		;
LSR #3		;
TAY		;

LDA YSpeeds,y	;
EOR #$FF		;
INC		;
BPL StoreYSpeed2	;
STA !1564,x	;
LDA #$7F		;
StoreYSpeed2:	;
STA !AA,x	;
RTS		;

NoResetYSpeed:

JSL $01801A|!BankB	;

LDA $14		;
AND #$07	;
;ORA $C2,x	;
BNE NoLavaTrail	;

JSL $0285DF|!BankB	; show lava trail subroutine

NoLavaTrail:	;

LDA !1564,x		;
BNE NoAccelerate		;

LDA !1504,x		;
BNE InvertYSpeed2		;

LDA !AA,x		;
BMI StartAccelerating	;
;LDY $C2,x		;
;CMP Timer2Checks,y	;
CMP #!Timer2Check		;
BCS NoAccelerate		;
StartAccelerating:		;
CLC			;
ADC #$02		;
STA !AA,x		;
BRA NoAccelerate		;

InvertYSpeed2:		;

LDA !AA,x		;
BPL StartAccelerating2	;
;LDY $C2,x		;
;CMP Timer2Checks2,y	;
CMP #!Timer2Check		;
BCC NoAccelerate		;
StartAccelerating2:		;
SEC			;
SBC #$02			;
STA !AA,x		;

NoAccelerate:

LDA #$00
%SubOffScreen()

PodobooGFX:		; Most of this routine is just for setting up pointers to the Podoboo's tiles.

JSR PodobooGFXMainRt	;
if !UseDynamicGFX
REP #$20			;
;LDA.w #$0008		;
;ASL #5			; Okay, what is the point of this?
;CLC			;
;ADC #$8500		; Why not just...
LDA #$8600		; do this instead?
STA $0D8B|!Base2		;
CLC			; set up some pointers
ADC #$0200		;
STA $0D95|!Base2		;
SEP #$20			;
endif
RTS			;

SetAnimationFrame:

INC !1570,x	;
LDA !1570,x	;
LSR		;
LSR		;
;LSR		;
AND #$01	;
STA !1602,x	;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PodobooGFXMainRt:	; most of this was ripped from the shared GFX routine at $019CF3

%GetDrawInfo()

LDA !15F6,x	;
ORA $64		;
STA $03		;

LDA #$03		;
STA $04		;

LDA !1602,x	; these three lines weren't in the original;
ASL #2		; I just added them for the sake of simplicity
STA $05		; (besides, as I said, this was originally a shared GFX routine, so it won't be verbatim anyway)

PHX		;

GFXLoop:		;

LDX $04		;

LDA $00		;
CLC		;
ADC XDisp,x	;
STA $0300|!Base2,y	;

LDA $01		;
CLC		;
ADC YDisp,x	;
STA $0301|!Base2,y	;

TXA		;
ORA $05		;
TAX		;

LDA Tilemap,x	;
STA $0302|!Base2,y	;

LDX $04		;

LDA XFlip,x	;
ORA $03		;
STA $0303|!Base2,y	;

INY #4		;
DEC $04		;
BPL GFXLoop	;

PLX		;
LDA #$03		;
LDY #$00		;
JSL $01B7B3|!BankB	;
RTS		;











