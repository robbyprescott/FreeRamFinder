;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This is a custom version of lightning bolt.
;;
;; Features:
;; -Freeze Flag and Offscreen Fix (e.g. screen scrolling via L/R won't stop bolt from moving, making it move through objects, and it doesn't despawn offscreen, which means you can fill sprite slots that way)
;; -Optimized graphics routine (original uses 4 sprite tiles, even though it looks like 2)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!LightningTile = $F3

!YSpeed = $30			;how fast is it moving downwards

FlameXOffsetLo:
db $FC,$0C,$EC,$1C,$DC

FlameXOffsetHi:
db $FF,$00,$FF,$00,$FF

!FlameSound = $17
!FlameSoundBank = $1DFC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR SumoLightningMain
PLB
print "INIT ",pc
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SumoLightningMain:
LDA !1540,x		; if the timer for showing flames is set...
BNE NoGraphics		; don't show graphics

JSR SumoLightningGFX	; draw the sprite

NoGraphics:
LDA !14C8,x		;the og sprite doesn't have these checks & no offscreen check
EOR #$08		;
ORA $9D			;
BNE Return00		;
%SubOffScreen()		;

LDA !1540,x		; if the timer for showing flames is set...
BNE ShowFlames		; show the flames

LDA #!YSpeed		;
STA !AA,x		; set the sprite Y speed

JSL $01801A|!bank	; update sprite Y position without gravity

LDA !1FE2,x		; if the object contact disable timer is set...
BNE NoObjCont		; don't check contact with objects

JSL $019138|!bank	; object interaction routine

LDA !1588,x		;
AND #$04		; if the sprite has hit the ground...
BEQ NoObjCont		;

LDA #!FlameSound		; play the fire sound effect
STA !FlameSoundBank|!addr	;

LDA #$22		; set the time to show flames before the sprite disappears
STA !1540,x		;

LDA !15A0,x		;
ORA !186C,x		; unless the sprite is offscreen..
BNE NoObjCont		;

LDA !E4,x		;
STA $9A			; set the sprite position to the block base position
LDA !D8,x		;
STA $98			;

JSL $028A44|!bank	; generate a puff of smoke

NoObjCont:
Return00:
RTS			;


ShowFlames:
STA $02			;
CMP #$01		; if the timer is about to run out...
BNE NoEraseSpr		;
STZ !14C8,x		; erase the sprite

NoEraseSpr:		;
AND #$0F		;
CMP #$01		;
BNE Return00		;
STA $18B8|!addr		; activate cluster sprites

JSR GenerateFlames	; generate the group of 10 cluster sprites that form the flames

INC !1570,x		;
LDA !1570,x		;
CMP #$01		;
BEQ NoSecondGen		;

JSR GenerateFlames	;

INC !1570,x		;

NoSecondGen:		;
RTS			;

GenerateFlames:
LDA !E4,x		;
STA $00			;

LDA !14E0,x		; backup the sprite X position
STA $01			;

LDY #$09		; 10, or 0x0A, cluster sprite slots to loop through

FindFreeClusterSlot:
LDA $1892|!addr,y	; if this cluster sprite slot is empty...
BEQ SpawnFlame		; spawn a flame here
DEY			; if not...
BPL FindFreeClusterSlot	; check the next index

DEC $191D|!addr		; $191D: Cluster Sprite slot to replace
BPL NoResetIndex	; if it has dropped below 0...
LDA #$09		; reset it to 9
STA $191D|!addr		;

NoResetIndex:		;
LDY $191D|!addr		;replace cluster sprite in this slot

SpawnFlame:		;
PHX			;
LDA !1570,x		;
TAX			;

LDA $00			;
CLC			;
ADC FlameXOffsetLo,x	; set the X position of the flame relative to the lightning
STA $1E16|!addr,y	;
LDA $01			;
ADC FlameXOffsetHi,x	;
STA $1E3E|!addr,y	;
PLX			;

LDA !D8,x		;
SEC			;
SBC #$10		; the Y offset is always -$10
STA $1E02|!addr,y	;
LDA !14D4,x		; set the Y position of the flame
SBC #$00		;
STA $1E2A|!addr,y	;

LDA #$7F		; time to show the flame?
STA $0F4A|!addr,y	;

LDA $1E16|!addr,y	;
CMP $1A			;
LDA $1E3E|!addr,y	;
SBC $1B			; if the cluster sprite is offscreen...
BNE NoGenFlame		; don't generate it

LDA #$06		; set the cluster sprite number
STA $1892|!addr,y	; 06 = Sumo Bro flame

NoGenFlame:		;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SumoLightningGFX:
%GetDrawInfo()			;get necessary info

LDA !15F6,x			;props from cfg.
ORA $64				;priority
STA $0303|!addr,y		;
ORA #$C0			;second tile is flipped vertically and horizontally
STA $0307|!addr,y		;

LDA $00				;
STA $0300|!addr,y		;
STA $0304|!addr,y		;

LDA $01				;
STA $0301|!addr,y		;
CLC				;
ADC #$08			;second tile's vertical offset
STA $0305|!addr,y		;

LDA #!LightningTile		;
STA $0302|!addr,y		;
STA $0306|!addr,y		;

LDA #$01			;even though it appears as 2 8x8 tiles, it actually uses FOUR sprite tiles in vanilla!
LDY #$00			;size = 8x8
%FinishOAMWrite()		;
RTS				;