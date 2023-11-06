; ########################################################################
; #                                                                      #
; #  OW Speed Changer, more or less made by WhiteYoshiEgg                #
; #  (pretty much all the code is by carol, I just cleaned it up a lot)  #
; #                                                                      #
; ########################################################################

	; ###############
	; # DEFINITIONS #
	; ###############

	!Speed		= $01		;    $01 = twice     the    original    speed,
					;    $02 = three  times  the  original  speed,
					;    [...] $FF = 256 times the original speed.

					;    ($00   will  keep   the  original  speed.)


	!YoshiSpeed	= $02		;    Speed  to  use   while  riding  on  Yoshi
					;    (same values as above).



!sa1	= 0
!addr	= $0000
!bank	= $800000

if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
	!bank	= $000000
endif

	; ############
	; # THE CODE #
	; ############

org $048241				;    Hijack Game Mode 0E ("On Overworld")
	autoclean JML ApplySpeed

freecode
reset bytes
print " Inserted at $",pc

ApplySpeed:
	PEA $0004
	PLB
	LDY #!Speed			;    Load speed value into Y

	LDA $0DD6|!addr : LSR #2 : TAX	; \
	LDA $0DBA|!addr,x		;  | If the player is on Yoshi,
	BEQ .noYoshi			;  | load the Yoshi speed value instead
	LDY #!YoshiSpeed		; /

.noYoshi


.loop	
	TYA				; \
	BEQ .return			;  |
					;  | Then all we need to do
	PHY				;  | is execute SMW's OW speed routine Y times.
	JSR .runSpeedRoutine		;  |
	PLY				;  | (Each iteration makes it go faster, of course.)
					;  |
	DEY				;  |
	BRA .loop			; /


.return
	LDX #$01			; \ Restore the hijacked code and return
	JML $048246|!bank		; /

.runSpeedRoutine

	LDA $13D9|!addr			; \
	CMP #$04			;  |
	BNE ..return			;  | Don't do this if the player isn't walking,
	LDA $13D4|!addr			;  | the game is paused
	BNE ..return			;  | or the ground is shaking
	LDA $1BA0|!addr			;  |
	BNE ..return			; /

	PHK				; \
	PEA.w ..return-1		;  | Run SMW's OW speed routine
	PEA.w $048575-1			;  |
	JML $04945D|!bank		; /
..return
	RTS