;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Based on Flying Disco Shell by RussianMan in place of a disassembly
;This shell acts like normal except for requiring
;a spin jump to bounce off of
;
;Uses the spiny graphics for the top half of the shell by default
;(SP4 02)
;
;by dtothefourth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!MaxRightSpeed = $20
!MaxLeftSpeed = $E0

WallBumpSpeed:
db !MaxLeftSpeed,!MaxRightSpeed

TilemapUL:
db $80,$82,$80,$82

TilemapDL:
db $9E,$9A,$9C,$9A

Print "INIT ",pc
LDA #$09
STA !14C8,x
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
%SubOffScreen()			;erase offscreen

%SubHorzPos()			;face player. always.
TYA				;
STA !157C,x			;


LDA !14C8,x	
CMP #$0A
BNE +
JSL $01803A|!BankB		;interact with player and sprites
+

.Re	
LDA #$00            ;looks like after interaction is checked, it messes with offscreen situation in some way
%SubOffScreen()            ;it looks like it marks sprite as "process offscreen" but also as "respawn when nearby", which can lead to duplication. odd.
RTS

;not so interesting tables stored away

XDisp:
db $04,$00,$FC,$00

YDisp:
db $F1,$00,$F0,$00

XFlip:
db $00,$00,$00,$40		;only last byte is flip for one of shell's frames

GFX:
%GetDrawInfo()

LDA !14C8,x			;
;EOR #$08			;
STA $03				;set scratch ram to contains information on wether sprite's in normal status.

LDA $00				;
STA $0300|!Base2,y		;shell tile X-pos
STA $0308|!Base2,y		;shell tile X-pos
CLC
ADC #$08
STA $0304|!Base2,y		;shell tile X-pos
STA $030C|!Base2,y		;shell tile X-pos

LDA $01				;
STA $0301|!Base2,y		;shell tile Y-pos
STA $0305|!Base2,y		;shell tile Y-pos
CLC
ADC #$08
STA $0309|!Base2,y		;shell tile Y-pos
STA $030D|!Base2,y		;shell tile Y-pos

PHY				;
LDA $03				;if dead, don't animate shell
CMP #$0A
BNE .NoAnim			;

LDA $14				;animate with frame counter and all
.NoAnim
LSR #2				;
AND #$03			;fetch correct tile and flip info
TAY				;
LDA XFlip,y			;
STA $02				;
LDA TilemapUL,y			;
PLY				;
STA $0302|!Base2,y		;
INC
STA $0306|!Base2,y		;

PHY
LDA $03				;if dead, don't animate shell
CMP #$0A
BNE .NoAnim2			;

LDA $14				;animate with frame counter and all
.NoAnim2
LSR #2				;
AND #$03			;fetch correct tile and flip info
TAY				;
LDA TilemapDL,y			;
PLY				;
STA $030A|!Base2,y		;
INC
STA $030E|!Base2,y		;


LDA $02				;flip info
BEQ +
LDA $0302|!Base2,y		;
PHA
LDA $0306|!Base2,y		;
STA $0302|!Base2,y		;
PLA
STA $0306|!Base2,y		;

LDA $030A|!Base2,y		;
PHA
LDA $030E|!Base2,y		;
STA $030A|!Base2,y		;
PLA
STA $030E|!Base2,y		;
LDA $02	
+

ORA !15F6,x			;+cfg setting which is useless because we set it afterwards
ORA $64				;and priority
STA $0303|!Base2,y		;store as tile property
STA $0307|!Base2,y		;store as tile property
AND #$FE
STA $030B|!Base2,y		;store as tile property
STA $030F|!Base2,y		;store as tile property

LDX $15E9|!Base2		;restore sprite slot

LDA #$03			;4 tiles
LDY #$00			;8x8
JSL $01B7B3|!BankB		;
RTS				;

WallHit:
LDA #$01			;hit sound effect
STA $1DF9|!Base2		;

LDA !15A0,x			;if offscreen, don't trigger bounce sprite
BNE .NoBlockHit			;

LDA !E4,x			;
SEC : SBC $1A			;
CLC : ADC #$14			;
CMP #$1C			;
BCC .NoBlockHit			;

LDA !1588,x			;
AND #$40			;
ASL #2				;
ROL				;
AND #$01			;
STA $1933|!Base2		;

LDY #$00			;
LDA $18A7|!Base2		;
JSL $00F160|!BankB		;

LDA #$05			;
STA !1FE2,x			;

.NoBlockHit
RTS				;