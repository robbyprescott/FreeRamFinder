;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Wild Mechakoopa, by Darolac
;;
;; Based on the dissasembly of the Mechakoopa, by imamelia, this Mechakoopa
;; hops around with customisable period and customisable maximum height.
;;
;; Uses first extra bit: YES
;;
;; Update 1.01: Now it uses the first three extra bytes to control his Y speed, X speed 
;; and palette (respectively). It also has a define to control whenether face the player or 
;; not.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Framesjump = #$01 ; number of frames between two jumps.
!Extani = 0	; it controls wheter the recovering animation uses two palettes or eight.
!Palani1 = #$07 ; \ palettes used for the recovering animation.
!Palani2 = #$09	; /
!Palani3 = #$0B ; \
!Palani4 = #$05	;  |
!Palani5 = #$07 ;  |palettes used for the recovering animation if !Extani is set.
!Palani6 = #$09 ;  |
!Palani7 = #$0B ;  |
!Palani8 = #$05 ; /
!Palex = #$09	; mechakoopa palette when using the extra bit. By default is set to C.
!Palaniex1 = #$09 ; \ palettes used for the recovering animation for the extra bit version.
!Palaniex2 = #$07 ; /
!Palaniex3 = #$05 ; \
!Palaniex4 = #$0B ;  |
!Palaniex5 = #$09 ;  |palettes used for the recovering animation for the extra bit version
!Palaniex6 = #$07 ;  |if !Extani is set.
!Palaniex7 = #$05 ;  |
!Palaniex8 = #$0B ; /
!Nohop = 0	; if set, the mechakoopa will not jump.
!Face = 0 ; if set, it will turn to face the player.
!Framesface = 0	; if set, the mechakoopa will check Mario's position and change direction every 40 frames.
!Shorttimer = 1	; if set, this will shorten the timer of the Mecha to half the original value.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
db $F8,$08,$F8,$00,$08,$00,$10,$00

YDisp:
db $F8,$F8,$08,$00,$F9,$F9,$09,$00
db $F8,$F8,$08,$00,$F9,$F9,$09,$00
db $FD,$00,$05,$00,$00,$00,$08,$00

Tilemap:
db $40,$42,$60,$51,$40,$42,$60,$0A
db $40,$42,$60,$0C,$40,$42,$60,$0E
db $00,$02,$10,$01,$00,$02,$10,$01

TileProp:
db $00,$00,$00,$00,$40,$40,$40,$40

TileSize:
db $02,$00,$00,$02

Palette:
db !Palani1,!Palani2,!Palani3,!Palani4,!Palani5,!Palani6,!Palani7,!Palani8

Palettex:
db !Palaniex1,!Palaniex2,!Palaniex3,!Palaniex4,!Palaniex5,!Palaniex6,!Palaniex7,!Palaniex8

KeyXDisp:
db $F9,$0F

KeyTileProp:
db $4D,$0D

KeyTilemap:
db $70,$71,$72,$71

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
%SubHorzPos()
TYA		; turn to face the player
STA !157C,x	;
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
JSR MechakoopaMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MechakoopaMain:

LDA !14C8,x	; check the sprite state
CMP #$09		; if it is stunned...
BCC +	; run a different routine
JMP Stunned
+

JSR MechakoopaGFX	;

LDA !14C8,x	;
CMP #$08	; if the sprite status is not normal...
BNE Return00	;
LDA $9D		; or sprites are locked...
BNE Return00	; return
%SubOffScreen();
JSL $01803A|!BankB	; interact with the player and other sprites
JSL $01802A|!BankB	; update sprite position

LDA !1588,x	;
AND #$08			; if the sprite is touching the ceiling... 
BEQ NoCeiling			; ...set the Y speed to 0
STZ !AA,x			;

NoCeiling:

LDA !1588,x			;
AND #$04			; if the sprite is not on ground...
BEQ NoJump			; ...don't set any speed values

STZ !AA,x			;

if !Nohop == 0

LDA !1504,x
CMP !Framesjump
BEQ Jump
INC !1504,x
BRA NoJump

Jump:

LDA !extra_byte_1,x
STA !AA,x
STZ !1504,x

endif

if !Face == 1
if !Framesface == 1

LDA !C2,x	;
INC !C2,x	;
AND #$3F	; every 40 frames...
BNE +	;
endif

%SubHorzPos()
TYA		; turn to face the player
STA !157C,x	;
endif
+

NoJump:

LDA !extra_byte_2,x
STA $00
EOR #$FF
INC
STA $01

LDY !157C,x	;
LDA $00,y	; set the X speed depending on direction
STA !B6,x	;

NoSpeed:	;

LDA !1588,x	;
AND #$03	; if the sprite is touching a wall...
BEQ NoFlipDir	;
LDA !B6,x	;
EOR #$FF		; flip its X speed
INC		;
STA !B6,x		;
LDA !157C,x	;
EOR #$01		; and direction
STA !157C,x	;

NoFlipDir:	;

INC !1570,x	;
LDA !1570,x	;
AND #$0C	; set the sprite's frame
LSR #2		;
STA !1602,x	;

Return00:		;
RTS

Stunned:

if !Shorttimer != 0

LDA !1540,x	;
CMP #$F5	; if the stun timer has just started...
BNE Originaltimer
SEC		;
SBC #$7F	; cut the timer in half
STA !1540,x		;

endif

Originaltimer:

LDA !7FAB10,x	; check out extra bit
AND #$04	;
BEQ NoExplode	;

LDA !1540,x	; if the stun timer is not set...
CMP #$08
BNE NoExplode	; then is not exploding

LDA #$15
STA $1887|!Base2	; shake the ground
LDA #$0D		;
STA !9E,x	; Sprite = Bob-omb.
LDA #$08		;
STA !14C8,x	; Set status for new sprite.
JSL $07F7D2|!BankB	; Reset sprite tables (sprite becomes bob-omb)..
LDA #$01		; .. and flag explosion status.
STA !1534,x	;
LDA #$40		; Time for explosion.
STA !1540,x
LDA #$09		;
STA $1DFC|!Base2	; Sound effect.
LDA #$1B
STA !167A,x
RTS

NoExplode:

LDA $1A		;
PHA		;
LDA !1540,x	;
CMP #$30		; if the stun timer is below 30...
BCS NoShake	;
AND #$01	;
EOR $1A		; make the Mechakoopa shake back and forth 1 pixel
STA $1A		;
NoShake:		;

JSR MechakoopaGFX	;

LDY !15EA,x	;
LDA #$F0		;
STA $0309|!Base2,y	; prevent a glitched tile from showing up

PLA		;
STA $1A		;

LDA !14C8,x	;
CMP #$0B		; if the sprite is being carried...
BNE Return01	;
LDA $76		;
EOR #$01		;
STA !157C,x	; set the sprite direction

Return01:		;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MechakoopaGFX:

LDA !extra_byte_3,x		;
STA !15F6,x	;

LDA !7FAB10,x	; check out extra bit
AND #$04	;
BEQ NormalPal	;

LDA !Palex
STA !15F6,x	;

NormalPal:

LDA !1540,x	; if the stun timer is set...
BEQ NotStunnedGFX	;

LDY #$05		;
CMP #$05		;
BCC StunFrame4	;
CMP #$FA		;
BCC StoreStunFrame	;
LDY #$04		;
StunFrame4:	;
StoreStunFrame:	;
TYA		;
STA !1602,x	;

LDA !7FAB10,x	; check out extra bit
AND #$04	;
BEQ NormalAni	;

LDA !1540,x	;
CMP #$30		; if the stun timer is below 30...
BCS NotStunnedGFX	;

if !Extani == 0

AND #$01	;
TAY		;
LDA Palettex,y	; make the Mechakoopa flash palettes
STA !15F6,x	;

else

AND #$07	;
TAY		;
LDA Palettex,y	; make the Mechakoopa flash palettes
STA !15F6,x	;

endif

BRA NotStunnedGFX

NormalAni:

LDA !1540,x	;
CMP #$30		; if the stun timer is below 30...
BCS NotStunnedGFX	;

if !Extani == 0

AND #$01	;
TAY		;
LDA Palette,y	; make the Mechakoopa flash palettes
STA !15F6,x	;

else

AND #$07	;
TAY		;
LDA Palette,y	; make the Mechakoopa flash palettes
STA !15F6,x	;

endif

NotStunnedGFX:	;

%GetDrawInfo()

LDA !15F6,x	;
STA $04		;

TYA		;
CLC		;
ADC #$0C	;
TAY		;

LDA !1602,x	;
ASL #2		;
STA $03		;
LDA !157C,x	;
ASL #2		;
EOR #$04		;
STA $02		;

PHX		;
LDX #$03		; 4 tiles to draw

GFXLoop:		;

PHX		;
PHY		;
TYA		;
LSR #2		;
TAY		;
LDA TileSize,x	;
STA $0460|!Base2,y	;     

PLY		;
PLA		;
PHA		;
CLC		;
ADC $02		;
TAX		;

LDA $00		;
CLC		;
ADC XDisp,x	;
STA $0300|!Base2,y	;

LDA TileProp,x	;
ORA $04		;
ORA $64		;
STA $0303|!Base2,y	;

PLA		;
PHA		;
CLC		;
ADC $03		;
TAX		;

LDA Tilemap,x	;
STA $0302|!Base2,y	;

LDA $01		;
CLC		;
ADC YDisp,x	;
STA $0301|!Base2,y	;

PLX		;
DEY #4		;
DEX		;
BPL GFXLoop	;

PLX
LDY #$FF		;
LDA #$03		;
JSL $01B7B3|!BankB	;


LDA !15EA,x	;
CLC		;
ADC #$10	;
STA !15EA,x	;

%GetDrawInfo()	;

PHX		;
LDA !1570,x	;
LSR #2		;
AND #$03	;
STA $02		;

LDA !157C,x	;
TAX		;
LDA $00		;
CLC		;
ADC KeyXDisp,x	;
STA $0300|!Base2,y

LDA $01		;
STA $0301|!Base2,y	;

LDA KeyTileProp,x	;
ORA $64		;
STA $0303|!Base2,y	;

LDX $02		;
LDA KeyTilemap,x	;
STA $0302|!Base2,y	;

PLX		;
LDY #$00		;
LDA #$00		;
JSL $01B7B3|!BankB	;
RTS;
