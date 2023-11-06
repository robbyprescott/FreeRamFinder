;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Extendable Wall Springboards by dtothefourth
;; Adapted from the vanilla disassembly by imamelia
;;
;; These springboards can have a length from 0 to 8
;; The length can change dynamically based on switches
;; And they can also have their bounce disabled the same way
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;The initial length is set using the extra byte, set in the Extension box in LM when adding the sprite
!Length = !extra_byte_1,x	;how many segments in springboard (0-8)

!Uses			= 0	;0 is normal infinite uses, otherwise 1-FF for limited use
!ExplodeOnDone  = 0	;0 = disappear in smoke, 1 = explode like bobomb
!DisappearSound = $08		;used for when springboard disappears
!DisappearBank  = $1DF9		;
!ExplodeSound   = $09		;used for when springboard explodes
!ExplodeBank    = $1DFC		;

!BlueSwitchGrow = 0		 ;1 to cause it to change length when blue p-switch is active
!BlueSwitchLen  = #$03   ;target length (0-8)

!SilverSwitchGrow = 0    ;1 to cause it to change length when silver p-switch is active
!SilverSwitchLen  = #$04 ;target length (0-8)

!OffGrow = 0	;1 to cause it to change length when on/off is toggled
!OffLen  = #$08	;target length (0-8)

!BluePDis    = 0   ;1 and the springboard will be fixed while blue p-switch is active
!BluePDisRev = 0   ;1 and the springboard will be fixed while blue p-switch is inactive

!SilverPDis    = 0   ;1 and the springboard will be fixed while silver p-switch is active
!SilverPDisRev = 0   ;1 and the springboard will be fixed while silver p-switch is inactive

!OffDis    = 0   ;1 and the springboard will be fixed while on/off is off
!OffDisRev = 0   ;1 and the springboard will be fixed while on/off is on

!GrowRate = #$07 ;How often to adjust length for growing/shrinking ANDed with frame counter so use 1,3,7,F,1F,etc for smooth animation

!Sounds     = 1			   ; 0 = no sound, 1 = play bounce sound
!BounceSFX  = #$08		   ; Sound effect number
!BounceBank = $1DFC|!Base2 ; Sound effect bank

BounceSpeed:
db $B6,$B4,$B0,$A8,$A0,$98,$90,$88,$80,$80,$80

BouncePhysics:
db $01,$01,$03,$05,$07,$09,$09,$09

YSpeedSet:
db $00,$00,$E8,$E0,$D0,$C8,$C0,$B8,$B0,$A8,$A0

XDisp:
db $00,$08,$10,$18,$20,$28,$30,$38
db $00,$08,$10,$18,$20,$28,$2F,$36
db $00,$08,$10,$18,$20,$27,$2E,$35
db $00,$08,$10,$18,$1F,$26,$2D,$34
db $00,$08,$10,$17,$1E,$25,$2C,$33
db $00,$08,$0F,$16,$1D,$24,$2B,$31
db $00,$07,$0F,$16,$1C,$23,$2A,$30
db $00,$07,$0E,$15,$1B,$22,$29,$2F
db $00,$07,$0E,$15,$1B,$22,$29,$2E
db $00,$07,$0E,$15,$1B,$22,$28,$2E
db $00,$07,$0E,$15,$1B,$22,$28,$2E
db $00,$07,$0E,$15,$1B,$22,$28,$2D
db $00,$07,$0E,$15,$1B,$21,$27,$2D
db $00,$07,$0E,$15,$1B,$21,$27,$2D


YDisp:
db $00,$00,$00,$00,$00,$00,$00,$00
db $00,$01,$01,$02,$02,$03,$03,$04
db $00,$01,$01,$03,$04,$06,$08,$0A
db $00,$01,$02,$04,$06,$09,$0C,$0E
db $00,$01,$03,$05,$08,$0C,$10,$12
db $00,$02,$04,$06,$0A,$0F,$13,$16
db $00,$02,$05,$08,$0C,$11,$16,$1A
db $00,$02,$06,$09,$0E,$13,$18,$1D
db $00,$02,$07,$0B,$10,$15,$1A,$20
db $00,$03,$08,$0D,$12,$17,$1C,$23
db $00,$04,$09,$0E,$13,$18,$1E,$25
db $00,$05,$0A,$0F,$14,$19,$1F,$26
db $01,$06,$0B,$10,$15,$1A,$20,$27
db $01,$06,$0B,$11,$16,$1B,$21,$28


!Tilemap = $3D	; the tile used by the wall springboards

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

if !Uses != 0
LDA #$!Uses
STA !1594,x
endif

LDA !Length
STA !160E,x
STA !1602,x

LDA !7FAB10,x	;
AND #$04	;
LSR		;
LSR		;
STA !1510,x	;
BEQ EndInit	;

LDA !E4,x	;
SEC		;
SBC #$08		;
STA !E4,x		;
LDA !14E0,x	;
SBC #$00		;
STA !14E0,x	;

EndInit:		;
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
JSR WallSpringboardMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WallSpringboardMain:

LDA #$00
%SubOffScreen()		;

JSR Disable

JSR WallSpringboardGFX	;


LDA $9D			;
BEQ +
RTS
+

JSR Length

LDA !1534,x		; $1534,x = timer to set the player's Y speed?
BEQ NoSetYSpeed		;
DEC !1534,x		;
BIT $15			; if the player isn't jumping...
BPL NoSetYSpeed		; don't set his/her Y speed
STZ !1534,x		;
LDY !151C,x		;
LDA BounceSpeed,y	; set the player's Y speed
STA $7D			;
LDA !BounceSFX	;
STA !BounceBank	; play a "boing" sound effect

if !Uses != 0

LDA !1594,x
DEC
STA !1594,x
BNE +

if !ExplodeOnDone
	LDA #$15
	STA $1887|!Base2 	; shake the ground
	LDA #$0D		;/
	STA !9E,x	;\ Sprite = Bob-omb.
	LDA #$08		;/
	STA !14C8,x	;\ Set status for new sprite.
	JSL $07F7D2	;/ Reset sprite tables (sprite becomes bob-omb)..
	LDA #$01		;\ .. and flag explosion status.
	STA !1534,x	;/
	LDA #$40		;\ Time for explosion.
	STA !1540,x
	LDA #$09		;\
	STA $1DFC|!Base2 	;/ Sound effect.
	LDA #$1B
	STA !167A,x
else
STZ !14C8,x		

LDA #$1B			
STA $02				
STZ $00				
STZ $01				
LDA #$01			
%SpawnSmoke()		

LDA #!DisappearSound		
STA !DisappearBank|!Base2
endif

+
endif


NoSetYSpeed:		;

LDA !1528,x		;
JSL $0086DF|!BankB	;

dw Return00		;
dw State01		;
dw State02		;

Return00:		;
RTS			;

State01:

LDA !1540,x		;
BEQ Continue00		;
DEC			;
BNE Return00		;
INC !1528,x		;
LDA #$01			;
STA !157C,x		;
RTS			;

Continue00:		;

LDA !C2,x		;
BMI Label00		;
CMP !151C,x		;
BCS Continue01		;
Label00:			;
CLC			;
ADC #$01		;
STA !C2,x		;
RTS			;

Continue01:		;

LDA !151C,x		;
STA !C2,x		;
LDA #$08			;
STA !1540,x		;
RTS			;

State02:

INC !1570,x	;
LDA !1570,x	;
AND #$03	;
BNE Label01	;
DEC !151C,x	;
BEQ ZeroSpriteState	;
Label01:		;
LDA !151C,x	;
EOR #$FF		;
INC		;
STA $00		;
LDA !157C,x	;
AND #$01	;
BNE DecState4	;

LDA !C2,x	;
CLC		;
ADC #$04	;
STA !C2,x	;
BMI Return01	;
CMP !151C,x	;
BCS Continue02	;
RTS		;

Continue02:	;

LDA !151C,x	;
STA !C2,x	;
INC !157C,x	;
Return01:		;
RTS		;

DecState4:

LDA !C2,x	;
SEC		;
SBC #$04		;
STA !C2,x	;
BPL Return01	;
CMP $00		;
BCC Continue03	;
RTS

Continue03:

LDA $00		;
STA !C2,x	;
INC !157C,x	;
RTS		;

ZeroSpriteState:

STZ !C2,x	;
STZ !1528,x	;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine, plus some other stuff
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WallSpringboardGFX:

%GetDrawInfo()		;

LDA !160E,x
BNE +
RTS
+
DEC				;
STA $02			;

LDA !1510,x		;
STA $05			;

LDA !C2,x		;
STA $03			;
BPL NoInvertState	;
EOR #$FF		;
INC			;
NoInvertState:		;
STA $04			;
LDY !15EA,x		;

GFXLoop:		;

LDA $04			;
ASL #3			;
ADC $02			;
TAX			;

LDA $05			;
LSR			;
LDA XDisp,x		;
BCC NoInvert00		;
EOR #$FF		;
INC			;
NoInvert00:		;
STA $08			;
CLC			;
ADC $00			;
STA $0300|!Base2,y		;

LDA $03			;
ASL			;
LDA YDisp,x	;
BCC NoInvert01	;
EOR #$FF		;
INC		;
NoInvert01:	;
STA $09		;
CLC		;
ADC $01		;
STA $0301|!Base2,y	;

LDA #!Tilemap	;
STA $0302|!Base2,y	;

LDA $64		;
ORA #$0A	;
STA $0303|!Base2,y	;

LDX $15E9|!Base2	;
PHY		;
JSR Interaction	;
PLY		;
INY #4		;
DEC $02		;
BMI EndGFX	;
JMP GFXLoop	;

EndGFX:		;

LDY #$00		;
LDA !160E,x
DEC		;
JSL $01B7B3|!BankB	;
Return02:		;
RTS

Interaction:

LDA $71			;
CMP #$01		;
BCS Return02		;
LDA $81			;
ORA $7F			;
ORA !15A0,x		;
ORA !186C,x		;
BNE Return02		;

LDA $7E			;
CLC			;
ADC #$02		;
STA $0A			;

LDA $187A|!Base2	;
CMP #$01		;
LDA #$10		;
BCC Label02		;
LDA #$20		;
Label02:		;
CLC			;
ADC $80			;
STA $0B			;

LDA $0300|!Base2,y		;
SEC			;
SBC $0A			;
CLC			;
ADC #$08		;
CMP #$14		;
BCS Return03		;

LDA $19			;
CMP #$01		;
LDA #$1A		;
BCS Label03		;
LDA #$1C		;
Label03:		;
STA $0F			;

LDA $0301|!Base2,y	;
SEC			;
SBC $0B			;
CLC			;
ADC #$08		;
CMP $0F			;
BCS Return03		;
LDA $7D			;
BMI Return03		;

LDA #$1F		;
PHX			;
LDX $187A|!Base2	;
BEQ Label04		;
LDA #$2F		;
Label04:		;
STA $0F			;
PLX			;

LDA $0301|!Base2,y	;
SEC			;
SBC $0F			;
PHP			;
CLC			;
ADC $1C			;
STA $96			;
LDA $1D			;
ADC #$00		;
PLP			;
SBC #$00		;
STA $97			;

STZ $72			;
LDA #$02		;
STA $1471|!Base2	;
LDA !1528,x		;
BEQ SetPhysics		;
CMP #$02		;
BEQ SetPhysics	;

LDA !1540,x	;
CMP #$01		;
BNE Return03	;
LDA #$08		;
STA !1534,x	;
LDY !C2,x	;
LDA YSpeedSet,y	;
STA $7D		;

Return03:
RTS

SetPhysics:

STZ $7B			;
LDY $02			;
LDA BouncePhysics,y	;
STA !151C,x		;
LDA #$01			;
STA !1528,x		;
STZ !1570,x		;
RTS			;

Length:

LDA !Length
STA !1602,x

if !OffGrow
LDA $14AF|!addr
BEQ +
LDA !OffLen
STA !1602,x
BRA ++
+
endif


if !SilverSwitchGrow
LDA $14AE|!addr
BEQ +
LDA !SilverSwitchLen
STA !1602,x
BRA ++
+
endif

if !BlueSwitchGrow
LDA $14AD|!addr
BEQ +
LDA !BlueSwitchLen
STA !1602,x
BRA ++
+
endif

++
LDA $13
AND !GrowRate
BNE +

LDA !160E,x
CMP !1602,x
BEQ +

BMI ++
DEC
STA !160E,x
BRA +
++
INC
STA !160E,x

+
RTS

Disable:

if !BluePDis
LDA $14AD|!addr
BEQ +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
LDA #$00
STA !151C,x
BRA +++
+
endif

if !BluePDisRev
LDA $14AD|!addr
BNE +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
STA !151C,x
STA !1540,x
BRA +++
+
endif

if !SilverPDis
LDA $14AE|!addr
BEQ +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
LDA #$00
STA !151C,x
BRA +++
+
endif

if !SilverPDisRev
LDA $14AE|!addr
BNE +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
STA !151C,x
STA !1540,x
BRA +++
+
endif

if !OffDis
LDA $14AF|!addr
BEQ +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
LDA #$00
STA !151C,x
BRA +++
+
endif

if !OffDisRev
LDA $14AF|!addr
BNE +
LDA #$00
STA !C2,x
LDA #$01
STA !1528,x
STA !151C,x
STA !1540,x
BRA +++
+
endif

+++

RTS