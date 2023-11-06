;Behaves $025
;If your level is possible to have yoshi in it, you must place
;"Reuseable_UpsidedownPswitch.asm" under this block to prevent (Yoshi_PswitchFix?)
;getting stuck inside this block when riding yoshi.

!TimerLast =	$40		;>How long the switch last (higher = longer), decrements every 4th
				; frame, SFX plays at $1E. $B0 is how long smw's origional p-switch
				; last.
!SwitchType =	$14AD|!addr	;>Switch type: $14AD = blue, $14AE = silver.
!NoMusic =	1		;>If you have installed a patch that removes p-switch music, set this
				; to 1.

!ScreenShake =	$20		;how long to shake screen. set to 0 to disable screen shake

!Sound = 	$0B		;sound to play after pressing the switch
!SoundAddr = 	$1DF9|!addr

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape
JMP MarioFireBall : JMP MarioAbove : JMP BodyInside : JMP HeadInside



MarioAbove:
	LDA !SwitchType		;\If switch is in its pressed state, then return
	BNE Return		;/

	LDA $7D			;\if player Y speed is going up
	BMI Solid		;/then treat the block as a regular cement block.

	LDA #!Sound		;\sfx.
	STA !SoundAddr		;/

	LDA #!TimerLast		;\set timer
	STA !SwitchType		;/

if !NoMusic = 0
	LDA #$0E		;\music	
	STA $1DFB|!addr		;/
endif

if !ScreenShake
	LDA #!ScreenShake	;\shake timer
	STA $1887|!addr		;/
endif

Solid:
	LDY #$01		;\Solid code.
	LDA #$30		;|
	STA $1693|!addr		;/
	RTL

BodyInside:
	LDA !SwitchType		;\If switch is in a pressed state, then return
	BNE Return		;/

	LDX #$00
	LDA $187A|!addr		;\If player is riding yoshi, warp the player 2 blocks up
	BEQ .NotOnYoshi		;/

	LDX #$02		;otherwise teleport 3 blocks up

.NotOnYoshi
	REP #$20			;\Teleport player to above the block on foot
	LDA $98				;|
	AND #$FFF0			;|
	SEC : SBC TeleportOffset,x	;|
	STA $96				;|
	SEP #$20			;/
	RTL

TeleportOffset:
dw $0020,$0030

MarioSide:
HeadInside:
SpriteV:
SpriteH:
MarioFireBall:
MarioBelow:
	LDA !SwitchType		;\If switch is not pressed, then become Solid.
	BEQ Solid		;/
MarioCape:
Return:
	RTL

print "Reuseable blue P-switch. Press it from above to active it. Watch out for a Yoshi glitch. See file for more."