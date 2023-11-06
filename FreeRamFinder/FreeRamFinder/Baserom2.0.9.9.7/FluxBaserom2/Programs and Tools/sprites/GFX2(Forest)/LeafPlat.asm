;Rideable Falling Leaf, by Blind Devil
;A platform kind of sprite that falls down similar to how SMW's feather does.

;Extra BYTE 1:
;$00 = leaf starts moving right.
;$01 = leaf starts moving left.

;Configurable defines:
;TILEMAPS
;What tiles to use for the leaf. Left and right tile, respectively.
!Tile1 = $CE
!Tile2 = $EE

;Speeds tables below.
LeafXAccel:
db $01,$FF
LeafXMaxSpd:
db $12,$EE
LeafYSpds:
db $10,$FC,$0E

;Code starts below.

print "INIT ",pc
LDA !C2,x		;load flag set by generator for sprite (determines random start direction)
BEQ +			;if equal zero, skip ahead.

JSL $01ACF9|!BankB	;generate random number
AND #$01		;preserve bit 0
BRA ++			;branch ahead

+
LDA !7FAB40,x		;load extra byte 1
AND #$01		;preserve bit 0
++
STA !157C,x		;store bit to sprite direction.

RTL			;return.

print "MAIN ",pc
PHB			;preserve data bank
PHK			;push program bank into stack
PLB			;pull program bank as new data bank
JSR SpriteCode		;call main sprite code
PLB			;restore previous data bank
RTL			;return.

Return:
RTS			;return.

SpriteCode:
JSR Graphics		;call graphics drawing routine.

LDA !14C8,x		;load sprite status
CMP #$08		;check if default/alive
BNE Return		;if not equal, return.
LDA $9D			;load sprites/animation locked flag
BNE Return		;if set, return.

LDA #$03		;load value
%SubOffScreen()		;call offscreen handling routine.

LDA !157C,x		;load sprite direction
TAY			;transfer to Y

LDA !B6,x		;load sprite's X speed
CLC			;clear carry
ADC LeafXAccel,y	;add speed value from table according to index
STA !B6,x		;store result back.
CMP LeafXMaxSpd,y	;compare with max speed value from table according to index
BNE +			;if not equal, branch ahead.

LDA !157C,x		;load sprite direction
EOR #$01		;flip bit 0
STA !157C,x		;store result back.

+
LDA !B6,x		;load sprite's X speed again
BPL +			;if positive, branch.
INY			;increment Y by one
+
LDA LeafYSpds,y		;load speed value from table
STA !AA,x		;store to sprite's Y speed.

JSL $01802A|!BankB      ;update positions based on speed values (apply gravity)

JSL $01A7DC|!BankB	;call player/sprite interaction routine
BCC Return		;if there's no contact, return.

%SubVertPos()
LDA $0F			;load sprite Y position relative to player
CMP #$E6		;compare to value
BPL .noride		;if positive, don't ride sprite.

LDA $7D			;load player's Y speed
BMI .noride		;if negative, don't ride sprite.

LDA #$01		;load value
STA $1471|!Base2	;store to type of platform player is riding address.
STZ $7D			;reset Y speed.
LDA #$E2		;load Y offset for player into A
LDY $187A|!Base2	;load riding Yoshi flag
BEQ +			;if not riding, don't change Y offset.
LDA #$D2		;else load new value for Y offset
+
CLC			;clear carry
ADC !D8,x		;add sprite's Y-pos, low byte, to it
STA $96			;store to player's Y-pos within the level, next frame, low byte.
LDA !14D4,x		;load sprite's Y-pos, high byte
ADC #$FF		;add value, with carry
STA $97			;store to player's Y-pos within the level, next frame, high byte.

LDA $77			;load player blocked status flags
AND #$03		;check if blocked on sides
BNE .noride		;if yes, don't update X-pos.

LDY #$00		;load value into Y
LDA $1491|!Base2	;load amount of pixels the sprite has moved horizontally
BPL +			;if positive, branch ahead
DEY			;else decrement Y
+
CLC			;clear carry
ADC $94			;add player's X-pos within the level, next frame, low byte, to it
STA $94			;store result to player's X-pos within the level, next frame, low byte.
TYA			;transfer Y to A
ADC $95			;add player's X-pos within the level, next frame, high byte, to it... with carry
STA $95			;store result to player's X-pos within the level, next frame, high byte.

.noride
RTS			;return.

Tilemap:
db !Tile1,!Tile2

XDisp:
db $08,$F8,$08

!YDisp = $FB

Properties:
db $40,$00

Graphics:
%GetDrawInfo()		;get sprite positions within the screen and OAM index for sprite tile slots

LDA !157C,x		;load sprite direction
STA $02			;store to scratch RAM.

PHX			;preserve sprite index
LDX #$01		;loop count

GFXLoop:
LDA $01			;load sprite Y-pos within the screen
CLC			;clear carry
ADC #!YDisp		;add displacement value
STA $0301|!Base2,y	;store to OAM.

LDA Tilemap,x		;load tilemap from table according to index
STA $0302|!Base2,y	;store to OAM.

PHX			;preserve loop count
TXA			;transfer X to A
CLC			;clear carry
ADC $02			;add direction value
TAX			;transfer A to X

LDA $00			;load sprite X-pos within the screen
CLC			;clear carry
ADC XDisp,x		;add displacement from table according to index
STA $0300|!Base2,y	;store to OAM.

LDX $15E9|!Base2	;load index of sprite being processed into X
LDA !15F6,x		;load palette/properties from CFG
LDX $02			;load sprite direction into X
ORA Properties,x	;get X-flip from table according to index
ORA $64			;add in level priority bits
STA $0303|!Base2,y	;store to OAM.
PLX			;restore loop count
INY #4			;increment Y by one four times
DEX			;decrement X by one
BPL GFXLoop		;keep looping while X is positive.

PLX			;restore sprite index
LDY #$02		;load value into Y (means all tiles are 16x16)
LDA #$01		;load value into A (amount of tiles drawn, minus one)
JSL $01B7B3|!BankB	;bookkeeping
RTS			;return.