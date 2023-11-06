;Behaves $025

!TimerLast =	$40		;>How long the switch last (higher = longer), decrements every 4th
				; frame, SFX plays at $1E. $B0 is how long smw's origional p-switch
				; last.
!SwitchType =	$14AD|!addr	;>Switch type: $14AD = blue, $14AE = silver.
!NoMusic =	1		;>If you have installed a patch that removes p-switch music, set this
				; to 1.
!SprActivate =	1		;>Activate the switch by kicking the sprite upwards into the switch:
				; 0 = false, 1 = true.

!ScreenShake =	$20		;how long to shake screen. set to 0 to disable screen shake

!Sound = 	$0B		;sound to play after pressing the switch
!SoundAddr = 	$1DF9|!addr

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape
JMP MarioFireBall : JMP TopCorner : JMP BodyInside : JMP HeadInside


MarioBelow:
	LDA !SwitchType		;\If switch is in its pressed state, then return act as $25 (a copy
	BNE Return		;/ of this to prevent a glitch where if going down while pressed.)

	LDA $7D			;\If player Y speed is going down
	BPL Solid		;/then treat the block as a regular cement block.
ActivateSwitch:
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
	LDA !SwitchType		;\If switch is active (pressed), return
	BNE Return		;/

	REP #$20		;\Otherwise when Solid (not pressed),
	LDA $98			;|push the player out of the block (downwards).
	AND #$FFF0		;|
	LDA $19			;|\If player has small hitbox (by small mario or
	BEQ SmallHitbox		;||big ducking mario), then use different position.
	LDA $73			;||
	BNE SmallHitbox		;|/
				;|
	CLC : ADC #$0010	;|
				;|
SmallHitbox:			;|
	STA $96			;|
	SEP #$20		;/

SkipSmlHTBX:
	LDA #$20		;\And don't maintain Y speed
	STA $7D			;/
	RTL

if !SprActivate != 0
SpriteV:
	LDA !SwitchType		;\If switch is in its pressed state, then return act as $25 (a copy
	BNE Return		;/of this to prevent a glitch where if going down while pressed.)
	LDA !AA,x		;\If sprite not kicked upwards, then treat it
	BPL Solid		;|as a cement block (when unpressed)
	LDA !14C8,x		;|
	CMP #$09		;|
	BNE Solid		;/
	BRA ActivateSwitch
endif
HeadInside:
TopCorner:
MarioAbove:
MarioSide:
SpriteH:
MarioFireBall:

if !SprActivate = 0
SpriteV:
endif
SolidCheck:
	LDA !SwitchType		;\If switch is not pressed, then Solid.
	BEQ Solid		;/
MarioCape:
Return:
	RTL

print "Reuseable upside-down blue P-switch. Press it from below to active it. Watch out for a Yoshi glitch. See file for more."