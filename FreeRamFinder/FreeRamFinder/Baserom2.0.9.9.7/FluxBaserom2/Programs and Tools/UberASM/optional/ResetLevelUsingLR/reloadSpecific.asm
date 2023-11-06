	; This code will reload to a specific room, with specific settings.

!level		=	$0103		; level/secondary exit to load
!secondary	=	0			; secondary exit flag
!water		=	0			; water level flag (secondary exit only)
!midway		=	0			; midway (overrides secondary/water flags, requires "seperate settings for midway entrance" be checked)

main:
	LDA.b #!level
	STA $0C
	if !midway
		LDA.b #!level>>8|$0C
	else
		LDA.b #!level>>8|(!secondary*6)|(!water<<3)
	endif
	STA $0D
    JSL LRReset
    RTL