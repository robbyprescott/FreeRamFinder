;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Flutter Jump
;;Original by Scepile3
;;Modification by UltimateYoshiMaster and MarioFanGamer
;;UberASM conversion by MarioFanGamer
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		Notes from original version:		      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;*People that are good at rapidly pressing buttons may find a slight advantage...
;;
;;*There is a slight glitch...(it deals with springs...)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Timers, set to some other location if you are already using these locations in RAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!TTFJ = $18B4|!addr	;[T]ime [T]o [F]lutter [J]ump
!FJR = $18B7|!addr	;[F]lutter [J]ump [R]est
!FC = $18CD|!addr	;[F]lutter [C]arry

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Other defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!FlutterAnimation = 1	; Change this to 0 to disable the flutter animation
!PlayerFlutter = 0		; Change this to 1 so only player 1 can flutter and 2 if only player 2 can flutter
!YoshiFlutter = 0		; Change this to 1 to disable fluttering with Yoshi and 2 if only Yoshi can flutter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
	LDA $9D
	BNE .Return1
if !PlayerFlutter == 1
	LDA $0DB3|!addr
	BEQ .GoOn
else
	if !PlayerFlutter == 2
		LDA $0DB3|!addr
		BNE .GoOn
	else
		BRA .GoOn
	endif
endif
.Return1
RTL

.GoOn
	LDA $187A|!addr
if !YoshiFlutter == 2
	BEQ .Reset
else
	if !YoshiFlutter == 1
		BNE .Reset
	else
		BNE .NotFluttering
	endif

	if !FlutterAnimation
		LDA !TTFJ
		BEQ .NotFluttering
		AND #$03
		CMP #$03
		BNE +
		LDA #$01
	+	LDY $148F|!addr
		BEQ +
		CLC : ADC #$07
		BRA .Store
	+	LDY $72
		CPY #$0C
		BNE .Store
		CLC : ADC #$04
	.Store
		STA $13E0|!addr
	.NotFluttering
	endif
endif

    LDA $77     	;(in order)Doesn't work if not in air, swimming, climbing, or on yoshi
    AND #$04		;On the ground?
    ORA $71			;Controllable
    ORA $75			;Swimming?
    ORA $74			;Climbing?
	ORA $1407|!addr	;Gliding with the cape
	ORA $1891|!addr
	;Add more checks if you don't want Mario to flutter
    BNE .Reset		;Exit
    LDA $1499|!addr  ;temperarily stops when facing screen
;    BEQ NoReturn
;    JMP Return
    BNE .Return
.NoReturn:
	LDA !TTFJ
	BEQ .NoFlutter	;If the player isn't flutter jumping then don't apply its effects
		DEC !FC		;boost more
		LDA !FC		;load boost amount
		STA $7D		;apply boost
		DEC !TTFJ	;decrement flutter jump counter
		BRA .Fluttered	;don't run the resting code if we're flutter jumping
.NoFlutter:
	LDA !FJR		;Is there still rest time to take care of?
	BEQ .NoRest	;Nope, skip
	DEC !FJR		;Yes, decrement the rest timer
.NoRest:
.Fluttered:
	LDA $16       ;change these two lines to alter which button you want to press. controller values are in the RAM section of smwcentral.net
	CMP #$80
	BNE .Return

	STZ $140D|!addr     ;remove this line if you don't want to allow mario to flutter while spin jumping (without this, mario spin flutters)
	LDA !FJR		;Are we resting?
	BNE .NoCheck
	LDA #$16	;How long to flutter jump
	STA !TTFJ
	LDA #$F8	;Starting Y speed for flutter jump
	STA !FC
	LDA #$20	;How long to rest afterwards
	STA !FJR
	LDA #$09     ;What sound to play		(list of sounds at http://www.smwcentral.net/?p=thread&id=6665)
	STA $1DF9|!addr	;Sound Bank to use
.NoCheck:
	BRA .Return
.Reset:	;Stop the flutter jump
	STZ !TTFJ
	STZ !FC
;	BRA Return
.Return:
	RTL
