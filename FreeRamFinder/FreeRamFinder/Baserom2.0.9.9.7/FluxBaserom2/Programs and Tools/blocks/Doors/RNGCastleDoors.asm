; Don't use odd number of rooms (probably)
; Don't use more than 8 rooms without...

; $7FA200 - $7FA5FF ; untouched RAM (1024 bytes)
; $7FA200 - $7FA20F ; scratch
; $7FA210 - $7FA21F ; tables

!NumberOfRoomsMinusOne = $07 ; LM level number starts at 51 by default. 5A is final

; settings
!small_door 		= 0					; >0 = allow all forms, 1 = small only.

; RAM
!RAM_FrameCounter	= $14
!RAM_ExitTable1 	= $19B8
!RAM_ExitTable2 	= $19D8

!FreeRAM        = $7FA240
!RAM_Shuffled   = !FreeRAM          ; free ram (8 bytes)
!RAM_Initial    = !FreeRAM+8        ; free ram (8 bytes)
!RAM_Index      = !FreeRAM+16       ; free ram (1 byte)





db $42
JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret
JMP Ret : JMP Ret : JMP BodyInside : JMP Ret






BodyInside:
	PHY
	REP #$20							;\ if mario is 4 pixels far to the left or further
	LDA $9A								;| or 3 pixels far to the right or further,
	AND #$FFF0							;| then return (this was used on the original
	SEC : SBC #$0005					;| smw's door to prevent mario from entering from
	CMP $94								;| the very edge)
	BCC + 								;| 
	JMP ret_16bit						;| 
	+									;| 
	CLC : ADC #$0008					;| 
	CMP $94								;| 
	BCS + 								;| 
	JMP ret_16bit 						;| 
	+									;| 
	SEP #$20							;/ 

	LDA $16								;\ check if mario enters the door correctly.	
	AND #$08							;| up button pressed
	BNE + 								;| 
	JMP PullYret 						;| 
	+ 									;| 
	LDA $8F								;| 
if !small_door > 0						;| 
	ORA $19								;| 
endif									;| 
	BNE PullYret						;/ 

	LDA #$0F							;\ play door sound
	STA $1DFC|!addr						;/




    ; ---- get random and put value in shuffled table ----
    .getrandomindex:

    LDA !RAM_Index                  	; destination start index (table size -1)
    TAX 

    LDA !RAM_FrameCounter				;\ use frame #$00-(X) (max index)
	AND !RAM_Index 						;| 
	;%random_routine() 		        	;/ A = random (#$0-X)

    TAY                             	;\ copy random index from scratch to shuffled
    PHX                             	;|
    TAX                             	;|
    LDA !RAM_Initial,x              	;|
    PLX                             	;|
    STA !RAM_Shuffled,x             	;/
    ; ----------------------------------------------------


    ; ---- shift scratch indices ----
    ; X = destination index, Y = random index, A = random value
    ; at start
    
    PHX                         		; backup index (X)
        .loop_shift_scratch:
        CPY #!NumberOfRoomsMinusOne                    	;\ if last index, break
        BEQ .break                  	;/

        TYX                         	;\ else, shift
        INX                         	;| transfer random index (Y) to (X) ; e.g. y = (5)
        LDA !RAM_Initial,x          	;|                                  ; e.g. x = y + 1 (6)
        TYX                         	;| move to previous index 
        STA !RAM_Initial,x          	;/
        INY                         	; move up random index ; e.g. y = 6
        BRA .loop_shift_scratch
    ; -------------------------------

    .break:
    PLX                         		; restore index (X)
    


    LDA !RAM_Index
    TAY 
Tele:
	PHY
if !EXLEVEL
	JSL $03BCDC|!bank
else
	LDA $5B
	AND #$01
	ASL 
	TAX 
	LDA $95,x
	TAX
endif	
warp2lvl:
	PLY

	LDA !RAM_Index

	CMP #$FF 							; if done, exit the level (<0)
	BEQ .exit_level

		PHX 							;\ else, get last shuffled index
		TYX 							;|
		LDA !RAM_Shuffled,x 			;|
		TAY 							;|
		PLX 							;/

		LDA exit_table1,y				;\ move exit from table into current screen exit
		STA !RAM_ExitTable1|!addr,x		;| 
										;| 
		LDA exit_table2,y				;| 
		STA !RAM_ExitTable2|!addr,x		;/ 

		LDA !RAM_Index 					;\ decrement index
		DEC 							;|
		STA !RAM_Index 					;/
		BRA .tele_done

	.exit_level:

	LDA final_exit_table1
	STA !RAM_ExitTable1|!addr,x
	LDA final_exit_table2
	STA !RAM_ExitTable2|!addr,x


	.tele_done:
	LDA #$06 							;\ teleport the player.
	STA $71  							;|
	STZ $88								;|
	STZ $89								;/
PullYret:
	PLY
Ret:
	RTL
ret_16bit:
	SEP #$20
	PLY
	RTL


; ---- exit tables ----
exit_table1:
db $51,$52,$53,$54,$55,$56,$57,$58		; level numbers

exit_table2:
db $04,$04,$04,$04,$04,$04,$04,$04		; level flags

final_exit_table1:
db $5A; ; exit room

final_exit_table2:
db $04;

; ---------------------





print "Shuffle doors"