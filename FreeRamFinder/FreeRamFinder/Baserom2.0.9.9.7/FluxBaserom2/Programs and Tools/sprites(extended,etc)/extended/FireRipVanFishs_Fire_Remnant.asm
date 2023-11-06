;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Edited for Fire Rip van Fish to fit it's tilemap into vanilla tileset (no need to remap the fish itself)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TileMap:
db $AB,$BB			;Sprite's tilemap

!TimeForBlink = $50		;When flame will start blinking and stop harming player.

;cape interaction
Print "CAPE",pc
    LDA #$03
    STA $00

    ;LDA #$03
    STA $01

    ;LDA #$03
    STA $02

    LDA #$01
    STA $03

    %ExtendedCapeClipping()
    BCC CAPE_RETURN                ;$029647    |/

    LDA #$07                    ;$02A4DE    || Set timer for the smoke puff.
    STA $176F|!addr,X                ;$02A4E0    |/

    LDA #$01			;Change the sprite into a puff of smoke.
    STA $170B|!addr,x

CAPE_RETURN:
RTL

Print "MAIN ",pc
FlameRemnant:
LDA $9D				;Freeze flag
BNE GFX				;

INC $1765|!Base2,x		;Frame counter to show animation

LDA $176F|!Base2,x		;If extended sprite's timer is ran out
BEQ KillExtended		;erase
CMP #!TimeForBlink		;If it's timer is >= 50 (Or user-defined timer)
BCS .StillHurt			;Hurt mario on touch
AND #$01			;
BNE Return			;Blinking animation
BEQ GFX				;Sprite doesn't hurts when it's timer is about to run out.

.StillHurt
JSR Interaction			;hurt player and stuff

GFX:
%ExtendedGetDrawInfo()		;Originally $02A1A4
;LDY OAM_Pointers,x		;Not needed

LDA $01				;Tile's X position
STA $0200|!Base2,y		;

LDA $02				;Y position
STA $0201|!Base2,y		;ordinary stuff

LDA $1765|!Base2,x		;Do animation
LSR #2				;
AND #$01			;
TAX				;
LDA TileMap,x			;
STA $0202|!Base2,y		;

LDA $0203|!Base2,y		;
AND #$3F			;
ORA #$05			;Property magic
STA $0203|!Base2,y		;

LDX $15E9|!Base2		;

TYA				;sprite size = 8x8
LSR #2				;
TAY				;
LDA #$00			;
STA $0420|!Base2,y		;

Return:
RTL				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CODE_02A211 - erases extended sprite;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;In inefficient way.

KillExtended:		;
;LDA #$00              	;Nintendo stuck in NES era
;STA $170B|!Base2,X   	;

STZ $170B|!Base2,x	;That's better.
RTL

;again, default %ExtendedHurt isn't good, especially for 8x8 sprites (16x16 hitbox only iirc)
Interaction:
JSR GetExClipping

JSL $03B664|!BankB		;get mario's clipping

JSL $03B72B|!BankB		;
BCC .DiffRe			;

PHB				;
LDA.b #$02			;	
PHA				;
PLB				;
PHK				;
PEA.w .return-1			;
PEA.w $B889-1

JML $02A469|!BankB		;hurt mario

.return
PLB				;

.DiffRe
RTS				;

GetExClipping:
LDA $171F|!Base2,x		;Get X position
;SEC				;Calculate hitbox
;SBC #$02			;
STA $04				;

LDA $1733|!Base2,x		;
;SBC #$00			;Take care of high byte
STA $0A				;

LDA #$06			;width
STA $06				;

LDA $1715|!Base2,x		;Y pos
CLC				;
ADC #$02			;
STA $05				;

LDA $1729|!Base2,x		;
ADC #$00			;
STA $0B				;

LDA #$06			;length
STA $07				;
RTS				;
