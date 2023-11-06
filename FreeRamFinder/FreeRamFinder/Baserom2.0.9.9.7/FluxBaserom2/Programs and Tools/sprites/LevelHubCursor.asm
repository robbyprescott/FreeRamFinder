; For non-main pages?

;Cursor by Blind Devil
;A sprite that can be controlled with the D-pad and can click stuff.
;It doesn't interact with objects, but detects screen limits to avoid going out of bounds,
;and depending on the extra bit and extra byte (Extension) configuration, it can spawn or kill sprites via clicking.
;It also freezes Mario in place.

;Extra bit options:
;clear = won't spawn invisible object interactable sprite.
;set = will spawn invisible object interactable sprite (useful for clickable custom blocks).

;Extension options:
;0 = cursor can kill sprites.
;1 = cursor can spawn a normal sprite.
;2 = cursor can spawn a custom sprite with extra bit clear.
;3 = cursor can spawn a custom sprite with extra bit set.
;4 = cursor can't kill or spawn sprites.
;5 = makes it an invisible object interactable sprite. Used internally by the cursor, so don't use it.

;stop 1337-asm-writing lul
;and please comment properly your codes - for your own and everyone else's good :3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Customizable defines below.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;TILEMAPS
;Here you define what tiles the cursor will use.
	!CursorTile = $AC	;tile used for the cursor.
	!CursorPress = $AC	;tile used for the cursor when clicking.

;BUTTON TO CLICK
;What button to use for clicking. Depending on the controller data address:
;RAM $16: $80=B, $40=Y, $20=Select, $10=Start. UDLR not recommended, as they're already used to move the cursor.
;RAM $18: $80=A, $40=X, $20=L, $10=R.
	!ClickButton = $C0
	!ControllerData = $16		;can only be $16 or $18!

;CURSOR SPEED
;Speed which the cursor should move when a button in the D-pad is pressed.
;Applies to all directions.
	!CursorSpd = $7F ; normal 2B

;CURSOR CLICK TIMER
;How long, in frames, to display the clicked cursor tile when the button is pressed.
;It also prevents multiple rapid-clicking during this time.
	!CursorTimer = $0C

;SPRITE TO SPAWN
;What normal or custom sprite to spawn depending on the extension byte.
	!NormalSprite = $0F
	!CustomSprite = $BE

;DISABLE PAUSING
;If you don't want the player to pause the game when using this cursor, you can set here.
;Disabling is useful to menus, while letting it enabled might suit best for gimmicky levels.
;Possible values: 0 = don't disable. 1 = disable.
	!DisablePause = 0

!RepeatDelay = $14
!RepeatInterval = $04


;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite code starts here.
;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR SpriteCode
PLB
RTL

print "INIT ",pc
STZ !C2,x
RTL

InvisibleSprite:
JSL $019138|!BankB	;make sprite interact with objects (why it didn't interact even with the unchecked option in CFG is beyond me)

LDA !15AC,x		;load sprite decrementer
BNE +			;if not zero, return.

STZ !14C8,x		;else erase itself.

+
Return2:
RTS			;return.

SpriteCode:
LDA !7FAB40,x		;load first extension byte
CMP #$05		;compare to value
BEQ InvisibleSprite	;if not equal, branch to normal cursor sprite code.

JSR DrawGraphics	;draw graphics subroutine.

if !DisablePause
LDA #$02		;load value
STA $13D3|!Base2	;store this every frame to the "disable flipping pause status" timer.
endif

LDA #$02		;load value
STA $18BD|!Base2	;store to stun the player.

LDA $9D			;load sprites/animation locked flag
BNE Return2	;if not zero, return.
LDA !14C8,x		;load sprite status
CMP #$08		;check if it's regular/active
BNE Return2	;if not equal, return.

JSR Click		;subroutine that handles cursor clicking.

JSR ScreenDetect	;subroutine that handles screen range detection.


STZ !AA,x		;reset sprite Y speed.
STZ !B6,x		;reset sprite X speed.

; state = 0 if different buttons
LDA $15
AND #$0F
CMP !1504,x
BEQ +
STZ !C2,x
+

LDA !C2,x
BNE .state_12

; state 1 - new button press
JSR MoveOnce
INC !C2,x
LDA #!RepeatDelay
STA !163E,x
BRA .update_pos

.state_12
LDA !C2,x
DEC
BNE .state_2
; state 2 - delay before repeat
LDA !163E,x
BNE +
INC !C2,x
+
BRA .update_pos


.state_2
LDA !163E,x
BNE +

LDA #!RepeatInterval
STA !163E,x
JSR MoveOnce
+

.update_pos
; lol this is terrible
JSL $01801A|!BankB	;update ypos no gravity
JSL $018022|!BankB	;update xpos no gravity
JSL $01801A|!BankB	;update ypos no gravity
JSL $018022|!BankB	;update xpos no gravity


; set x pos min/max
LDA !14E0,x
XBA
LDA !E4,x
REP #$20
SEC
SBC $1A
BMI +++

CMP #$0010
BCS +
+++
LDA #$0010-1
+
CMP #$00EF
BCC +
LDA #$00EF+1
+
CLC
ADC $1A
SEP #$20
STA !E4,x
XBA
STA !14E0,x


;set y pos min/max
LDA !14D4,x
XBA
LDA !D8,x
REP #$20
SEC
SBC $1C

BMI +++

CMP #$0010
BCS +
+++
LDA #$0010-1
+
CMP #$00CF
BCC +
LDA #$00CF+1
+
CLC
ADC $1C
SEP #$20
STA !D8,x
XBA
STA !14D4,x

; save controller input for next frame
LDA $15
AND #$0F
STA !1504,x

MotherReturn:
RTS

MoveOnce:
LDA !151C,x
EOR #$FF
AND $15
AND #$0F

BEQ MotherReturn
LDY #$23  ; sound of Mario arrive at new tile on OW
STY $1DFC

LDY #$04
-
ROR
BCS +
DEY
BEQ MotherReturn
BRA -
+
DEY

PHA

LDA !B6,x
CLC
ADC button_x,y
STA !B6,x

LDA !AA,x
CLC
ADC button_y,y
STA !AA,x

CPY #$00
BEQ +
PLA
BRA -

+
PLA
RTS

; UDLR
button_y:
db -!CursorSpd, !CursorSpd, 0, 0
button_x:
db 0, 0, -!CursorSpd, !CursorSpd


Click:
LDA !15AC,x		;load click decrementer
BNE .ret		;if not zero, return.

LDA !ControllerData	;load user-defined controller data address.
AND #!ClickButton	;check input
BNE .clicked		;if pressed, branch.

.ret
RTS			;return.

.clicked
LDA #!CursorTimer	;load amount of frames
STA !15AC,x		;store to decrementer.

LDA !7FAB10,x		;load extra bits
AND #$04		;check if first extra bit is set
BEQ +			;if not, branch ahead.

JSR Spawners		;spawn sprite handler

+
LDA !7FAB40,x		;load first extension byte
JSL $0086DF|!BankB	;call 2-byte pointer subroutine

dw KillSprites
dw GenSprite
dw GenSprite
dw GenSprite
dw Nothing

Spawners:
LDA #$FA		;load X offset
STA $00			;store to scratch RAM.
LDA #$F3		;load Y offset
STA $01			;store to scratch RAM.
STZ $02 : STZ $03	;no XY speed
LDA !7FAB9E,x		;load this sprite's number
SEC			;set carry - spawn custom sprite
%SpawnSprite()
CPY #$FF		;check if sprite wasn't spawned
BEQ .ret		;if value is equal, return.

PHX			;preserve sprite index
TYX			;transfer index of generated sprite
LDA #$04		;load amount of frames to keep sprite alive
STA !15AC,x		;store to sprite decrementer.
LDA #$05		;load extension value
STA !7FAB40,x		;store to first extension byte.
PLX			;restore X

.ret
RTS			;return.

KillSprites:
LDY #!SprSize-1		;loop count (loop though all sprite number slots)

.Loop
PHX
LDA !14C8,y		;load sprite status
BEQ .LoopSprSpr		;if non-existant, keep looping.
CMP #$04		;check if spinjumped
BEQ .LoopSprSpr		;if equal, keep looping.

LDA !7FAB9E,x		;load this sprite's number
STA $07			;store to scratch RAM.
TXA			;transfer X to A (sprite index)
STA $08			;store it to scratch RAM.
TYA			;transfer Y to A
CMP $08			;compare with sprite index
BEQ .LoopSprSpr		;if equal, keep looping.
TYX			;transfer Y to X
LDA !7FAB9E,x		;load sprite number according to index
CMP $07			;compare with cursor's number from scratch RAM
BEQ .LoopSprSpr		;if equal, keep looping.
PLX			;restore sprite index.

JSL $03B6E5|!BankB	;get sprite A clipping (this sprite)
PHX			;preserve sprite index
TYX			;transfer Y to X
JSL $03B69F|!BankB	;get sprite B clipping (interacted sprite)
JSL $03B72B|!BankB	;check for contact
BCC .LoopSprSpr		;if carry is set, there's contact, so branch.

LDA #$04		;load sprite state (spinjumped)
STA !14C8,x		;store to sprite state table.
LDA #$1F		;load value
STA !1540,x		;store to spinjumped sprite timer.

JSL $07FC3B|!BankB	;display spinjump stars
LDA #$08		;load sound effect
STA $1DF9|!Base2	;store to address to play it.
PLX			;restore sprite index
RTS			;return.

.LoopSprSpr
PLX			;restore sprite index
DEY			;decrement loop count by one
BPL .Loop		;and loop while not negative.
RTS			;end? return.

GenSprite:
LDA #$FB		;load X offset
STA $00			;store to scratch RAM.
LDA #$FB		;load Y offset
STA $01			;store to scratch RAM.
STZ $02 : STZ $03	;no XY speed

LDA !7FAB40,x		;load first extension bit
CMP #$01		;compare to value
BEQ normal		;if equal, spawn normal sprite.

LDA #!CustomSprite	;load custom sprite number
SEC			;set carry - spawn custom sprite
%SpawnSprite()
CPY #$FF		;check if sprite wasn't spawned
BEQ .ret		;if value is equal, return.

LDA !7FAB40,x		;load first extension bit
CMP #$03		;compare to value
BNE .ret		;if not equal, don't set extra bit for it.

PHX			;preserve sprite index
TYX			;transfer index of generated sprite
LDA !7FAB10,x		;load extra bits of spawned sprite
ORA #$04		;set first extra bit
STA !7FAB10,x		;store result back.
PLX			;restore X

.ret
RTS			;return.

normal:
LDA #!NormalSprite	;load normal sprite number
CLC			;set carry - spawn custom sprite
%SpawnSprite()

Nothing:
RTS			;return.

;Sprite XY coordinates relative to screen calc subroutine + border detection
;This one you might find interesting! Feel free to rip lol

ScreenDetect:
JSR HorzDetect		;oh yeah
JSR VertDetect		;moar subroutines
RTS			;return.

HorzDetect:
LDA !14E0,x		;load sprite x-pos within level, high byte
XBA			;flip high/low bytes of A
LDA !E4,x		;load sprite x-pos within level, low byte (hooray we got the 16-bit coordinate in A now)
REP #$20		;16-bit A
SEC			;set carry
SBC $1A			;subtract layer 1 x-pos (A now holds sprite x-pos within the screen)

CMP #$0010		;compare A to value
BCC .blockleft		;if lower or equal, set flag to disable going left any further.
CMP #$00EF		;else compare again
BCC .resetbits		;if lower or equal, reset both bits. else it's higher, so we'll set flag to disable going right.

SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
ORA #$01		;set bit to block going right
BRA .storebits		;branch ahead.

.blockleft
SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
ORA #$02		;set bit to block going left
BRA .storebits		;branch ahead.

.resetbits
SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
AND #$FC		;mask bits - clear block left and block right bits
.storebits
STA !151C,x		;store result back.

LDA !B6,x		;load sprite X speed
BEQ .ret		;if equal zero, return.

STZ !B6,x		;reset sprite X speed.
.ret
RTS			;return.

VertDetect:
LDA !14D4,x		;load sprite y-pos within level, high byte
XBA			;flip high/low bytes of A
LDA !D8,x		;load sprite y-pos within level, low byte (hooray we got the 16-bit coordinate in A now)
REP #$20		;16-bit A
SEC			;set carry
SBC $1C			;subtract layer 1 y-pos (A now holds sprite y-pos within the screen)

CMP #$0010		;compare A to value
BCC .blockleft		;if lower or equal, set flag to disable going left any further.
CMP #$00CF		;else compare again
BCC .resetbits		;if lower or equal, reset both bits. else it's higher, so we'll set flag to disable going right.

SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
ORA #$04		;set bit to block going down
BRA .storebits		;branch ahead.

.blockleft
SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
ORA #$08		;set bit to block going up
BRA .storebits		;branch ahead.

.resetbits
SEP #$20		;8-bit A
LDA !151C,x		;load sprite address used for flags
AND #$F3		;mask bits - clear block up and block down bits
.storebits
STA !151C,x		;store result back.

LDA !AA,x		;load sprite Y speed
BEQ .ret		;if equal zero, return.

STZ !AA,x		;reset sprite Y speed.
.ret
RTS			;return.

;;;;;;;;;;;;;;;;;;;;;;;;
;Graphics routine below.
;;;;;;;;;;;;;;;;;;;;;;;;

DrawGraphics:
!XDisp = $02		;tile X displacement.
!YDisp = $02		;tile Y displacement.

%GetDrawInfo()

LDA $00			;get sprite X-pos from scratch RAM
CLC			;clear carry
ADC #!XDisp		;add X displacement
STA $0200|!Base2,y	;store to OAM.

LDA $01			;get sprite Y-pos from scratch RAM
CLC			;clear carry
ADC #!YDisp		;add Y displacement
STA $0201|!Base2,y	;store to OAM.

LDA !15AC,x		;load click timer
BNE +			;if not zero, branch.

LDA #!CursorTile	;load tile value (normal cursor)
BRA ++			;and branch ahead.
+

LDA #!CursorPress	;load tile value (pressed cursor)
++
STA $0202|!Base2,y	;store to OAM.

LDA !15F6,x		;load palette/properties from CFG
ORA $64			;set priority bits from level
STA $0203|!Base2,y	;store to OAM.

PHY			;preserve Y
TYA			;transfer Y to A
LSR #2			;divide by 2 twice
TAY			;transfer A to Y
LDA #$02		;load value (tile is set to 16x16)
ORA !15A0,x		;horizontal offscreen flag
STA $0420|!Base2,y	;store to OAM (new Y index).
PLY			;restore Y
RTS			;return.

;mind these OAM values and codes - they have the highest priority, so tiles will appear in front of other sprites and Mario as well.