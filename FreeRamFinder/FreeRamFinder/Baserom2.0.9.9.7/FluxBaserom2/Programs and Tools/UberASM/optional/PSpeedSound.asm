; By default, rapid footsteps sound

; $13E4: Player dash timer/P-meter. Increments with #$02 every frame the player is walking on the ground with the dash button held, otherwise decrements until it is zero. 
; #$70 indicates that the player is at its maximum running speed, and also means that the player is able to fly with a cape.

; Max X speeds ($7B) are 49/37/21 for sprinting, running, and walking respectively. 
; However, it's worth noting that Mario's X speed oscillates in a 0-1-0-1-2 pattern when running, e.g. 47-48-47-48-49 for sprinting.

!SoundRate =		$03		; $01, $03, $07, $0F, $1F, $3F or $7F. ($0F is nice walking.)
!SFXNum =			$01		
!SFXBank =			$1DF9+!addr	;>Sound port

main:
	LDA $77        ; must be on ground
	BEQ Return
	
    LDA $13E4+!addr
	LSR #4			;>Divide by 16 (rounded down)
	STA $00

	LDA $13E4+!addr		;
	CMP #$70		;
	BCC Return		

	LDA $13			;\Only play a frame with a "cool down" after
	AND #!SoundRate	;|
	BNE Return		;/

	LDA $9D			;>If frozen...
	ORA $13D4+!addr		;>Or paused...
	BNE Return		;>Then don't play SFX (but still blink). 
	LDA #!SFXNum	;\Play SFX
	STA !SFXBank	;/

Return:
RTL