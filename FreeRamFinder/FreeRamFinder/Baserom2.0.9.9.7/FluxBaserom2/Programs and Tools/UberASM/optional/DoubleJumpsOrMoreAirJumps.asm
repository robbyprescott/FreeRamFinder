;Use this as level or gamemode 14 (both must be in "main:").

;This one allows jumping and spinjumping in midair.

!ExtraJumpsInAir	= 1	;>How many extra jumps in air (in decimal, applies if limit enabled), 0 = infinite (cheeta-jump).
 !Freeram_JumpCountLeft	= $0E2B	;>[1 byte], a counter of how many jumps left (not applied if infinite).
!NJumpYSpeed		= $B0	;>How fast the player rises ($80-$FF where $80 is the fastest), normal jump.
!SJumpYSpeed		= $B6	;>Same as above, but spin.

;Note: Freeram is not autoconverted to SA-1 address. This is in case if you wanted to use freeram that the SA-1
;patch itself creates.
main:
.Airjump
	..Checks
	LDA $77				;\If mario is on ground, restore jumps
	AND.b #%00000100		;|
	BNE ..RestoreJumps		;/
	LDA $74				;>If net/vine climbing...
	ORA $75				;>Or water
	BNE ..RestoreJumps		;>Then restore jumps
	LDA $71				;\Don't jump when doing such actions such as dying.
	BNE ..Return			;/
	LDA $1407+!addr			;>If cape flying
	ORA $75				;>and/or swimming
	BNE ..Return			;>Then return.
	LDA $7D				;\If already going up, don't allow the player to waste jumps.
	BMI ..Return			;/
	LDA $16				;\If pressing jump, confirm
	BMI ...ContinueChecking		;/
	LDA $18				;\If not pressing spinjump nor jump, return
	BPL ..Return			;/

	...ContinueChecking
	if !ExtraJumpsInAir != 0
		LDA !Freeram_JumpCountLeft	;\If no jumps left, return.
		BEQ ..Return			;/
	endif

	..JumpConfirm
	if !ExtraJumpsInAir != 0
		LDA !Freeram_JumpCountLeft	;\Consume jump
		DEC A 				;|
		STA !Freeram_JumpCountLeft	;/
	endif

	..TypeOfJump
	LDA $16				;\Go to normal jump if B is pressed.
	BMI ...NormalJump		;/
	LDA $18				;\Go to spinjump if A is pressed.
	BPL ..Return			;/

	...Spinjump
	LDA #$01			;\Switch to spinjump
	STA $140D+!addr			;/
	LDA #!SJumpYSpeed		;\Spinjump up
	STA $7D				;/
	LDA #$04			;\SFX
	STA $1DFC+!addr			;/
	BRA ..BothJumps

	...NormalJump
	STZ $140D+!addr			;>Switch to normal jump
	LDA #!NJumpYSpeed		;\Jump up
	STA $7D				;/
	LDA #$35			;\SFX
	STA $1DFC+!addr			;/

	..BothJumps
	LDA #$0B			;\Jump pose (replaces long jump pose)
	STA $72				;/
	BRA ..Return			;>In case if you have code below.

	..RestoreJumps
	LDA.b #!ExtraJumpsInAir
	STA !Freeram_JumpCountLeft

	..Return
	RTL