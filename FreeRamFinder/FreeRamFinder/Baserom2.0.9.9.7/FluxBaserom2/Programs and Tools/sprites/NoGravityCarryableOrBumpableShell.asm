;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Based on Flying Disco Shell by RussianMan in place of a disassembly
;This shell acts like normal except for requiring
;a spin jump to bounce off of
;
;
;by dtothefourth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!gravity = 1   ; if 1, shell accumulates gravity while frozen

Tilemap:
db $8E,$8A,$8C,$8A


XFlip:
db $00,$00,$00,$40		;only last byte is flip for one of shell's frames


Print "INIT ",pc
LDA #$09
STA !14C8,x
LDA #$00
STA !1534,x
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Code
PLB
RTL

Code:
JSR GFX				;show graphics

LDA !14C8,x			;if dead
BEQ .Re		;
LDA $9D				;or frozen in time and space
BNE .Re				;return

LDA !14C8,x
CMP #$09
BEQ +
LDA #$01
STA !1534,x
+

LDA !1534,x
BNE +

if !gravity = 1
	LDA !AA,x
	PHA
	EOR #$FF
	INC
	STA !AA,x
else
	LDA #$00
	STA !AA,x
endif

JSL $1801A|!BankB

if !gravity = 1
	PLA
	STA !AA,x
endif
+

%SubOffScreen()			;erase offscreen

%SubHorzPos()			;face player. always.
TYA				;
STA !157C,x			;


LDA !14C8,x	
CMP #$0A
BNE +


JSL $018032|!BankB		;interact with player and sprites

LDA !14C8,x	
CMP #$02
BEQ +


JSL $01A7DC|!BankB		;interact with player and sprites

LDA !14C8,x	
CMP #$02
BNE +

LDA #$09
STA !14C8,x

+

.Re	
LDA #$00            ;looks like after interaction is checked, it messes with offscreen situation in some way
%SubOffScreen()            ;it looks like it marks sprite as "process offscreen" but also as "respawn when nearby", which can lead to duplication. odd.
RTS



GFX:
%GetDrawInfo()

LDA !14C8,x			;
;EOR #$08			;
STA $03				;set scratch ram to contains information on wether sprite's in normal status.

LDA $00				;
STA $0300|!Base2,y		;shell tile X-pos
LDA $01				;
STA $0301|!Base2,y		;shell tile Y-pos

PHY				;
LDA $03				;if dead, don't animate shell
CMP #$0A
BNE .NoAnim			;

LDA $14				;animate with frame counter and all
LSR #2				;
AND #$03			;fetch correct tile and flip info
BRA +
.NoAnim

LDA #$02
+
TAY				;
LDA XFlip,y			;
STA $02				;
LDA Tilemap,y			;
PLY				;
STA $0302|!Base2,y		;

LDA !14C8,x
CMP #$02
BNE +

LDA $02	
ORA #$80
STA $02

+

LDA $02				;flip info

ORA !15F6,x			;+cfg setting which is useless because we set it afterwards
ORA $64				;and priority
STA $0303|!Base2,y		;store as tile property

LDX $15E9|!Base2		;restore sprite slot

LDA #$00			;1 tile
LDY #$02			;16x16
JSL $01B7B3|!BankB		;
RTS				;
