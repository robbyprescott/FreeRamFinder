; Don't use with the doubel-bounce shell 
;
;This UberASM will cause a shell to be picked up again when
;bouncing off of it while holding run/grab
;
;By dtothefourth


!SkillsChallengeCounter = 1
!FreeRAM = $0EAB
	

main:
	LDA $15
	BIT #$40
	BNE +
	RTL
	+

	;LDA $148F
	;BEQ +
	;RTL
	;+

	LDX #!sprite_slots-1
	-

	LDA !14C8,x
	CMP #$09
	BNE +

	LDA !9E,x
	CMP #$04
	BMI +
	CMP #$09
	BPL +

	JSR Shell

	+
	DEX
	BPL -

	RTL

Shell:
	
	JSL $03B664
	JSL $03B69F
	JSL $03B72B

	BCC NoContact

	LDA #$0B
	STA !14C8,x
	LDA #$01
	STA $148F|!addr
	STA $1470|!addr
	
	if !SkillsChallengeCounter
	INC !FreeRAM
	endif

NoContact:
    
	RTS
	
; 2 - Falling off screen
; LDA !14C8,x
	;CMP #$02
	;BNE No
;No:	
    ;JSL $00F606