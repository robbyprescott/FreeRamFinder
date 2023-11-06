; Extracted/converted from JamesD28's Yoshi berry abilities sprites, by SJandCharlieTheCat
; You'll need to adjust the offset depending on extended sprite size


!ExtendedSpriteNumber = $0D			;/ $0D is baseball (requires GFX09 in SP$)
                                    ; List: https://www.smwcentral.net/?p=viewthread&t=23596 

!SpriteXSpeed = $28	; X speed for the extended sprite Yoshi shoots.
!SpriteYSpeed = $00	; Y speed for the extended sprite Yoshi shoots.

!SFXValue = $20 ; generic Yoshi spit sound
!SFXBank = $1DF9|!addr

main:

;LDX $15E9|!addr

LDA $187A|!addr			;/
BEQ .End				;\ Return if not on Yoshi.
LDA $16					;/
ORA $18					;|
AND #$40				;| If X or Y hasn't just been pressed, don't Sprite a shot.
BEQ .End				;\

STZ $14A3|!addr			; Zero the timer that changes Mario's pose for hitting Yoshi. Note that the pose will still appear for a frame, but this usually isn't noticeable.

LDX $18E2|!addr
LDY !157C-1,x			;/
LDA !E4-1,x				;|
CLC						;|
ADC SpriteXLoOffset,y		;|
STA $00					;| Sprite's X offset from Yoshi depending on his direction.
LDA !14E0-1,x			;|
ADC SpriteXHiOffset,y		;|
STA $01					;\

JSR ShootSprite			; Shoot Sprite.

LDA #$10				;/
STA !1558-1,x			;|	
LDA #$03				;| Set Yoshi's mouth to the spitting phase.
STA !1594-1,x			;\

LDX $15E9|!addr

LDA #!SFXValue
STA !SFXBank			;\ Sprite SFX.

;DEC !1504,x				;/
;BEQ KillPower			;\ Reduce the shots counter, and kill the power sprite if out of shots.

.End
RTL

ShootSprite:
PHK						;/
PEA.w .Return-1			;|
PEA $80C9				;| Find a free extended sprite slot.
JML $018EEF ; |!BankB		
.Return

LDA #!ExtendedSpriteNumber
STA $170B|!addr,y		;|
LDA $00					;|
STA $171F|!addr,y		;|
LDA $01					;|
STA $1733|!addr,y		;|
LDA !D8-1,x				;|
STA $1715|!addr,y		;|
LDA !14D4-1,x			;|
STA $1729|!addr,y		;|
LDA #$00				;|
STA $1779|!addr,y		;| Setup Sprite position and speed.
LDA !157C-1,x			;|
LSR						;|
LDA #!SpriteXSpeed	;|
BCC +					;|
EOR #$FF				;|
INC A					;|
+						;|
STA $1747|!addr,y		;|
LDA #!SpriteYSpeed	;|
STA $173D|!addr,y		;|
LDA #$A0				;|
STA $176F|!addr,y		;\
RTS

SpriteXLoOffset:
db $10,$F0

SpriteXHiOffset:
db $00,$FF