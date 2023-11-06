;do not insert this as blocks. This is uberasm code.
;put this in gamemode_code.asm in "gamemode_14:" or level_code.asm.
;you can edit the speeds, just go to the bottom.

;Tip: you can copy this instantly by pressing CTRL+A to select all,
;then CTRL+C to copy.

!freeram_dir		= $0DEF|!addr
!freeram_interact	= $0DF0

main:
	LDA !freeram_interact	;\Use !freeram_interact
	BEQ .goto_dir		;|as a timer of when the
	LDA $9D			;|cannons become re-interactable
	ORA $13D4|!addr	;|(so mario cannot be trapped
	BNE .goto_dir		;|inside cannon).
	LDA !freeram_interact	;|
	DEC A			;|
	STA !freeram_interact	;/
.goto_dir:
	LDA $71			;\If player dies, then reset the flag
	CMP #$09		;|(because if mario re-enters the level,
	BNE .dontreset		;|he's still being shooted, except freeram
	STZ !freeram_dir	;|that resets on level load).
	JMP .cannon_done		;/and you are done

.dontreset:
	LDA !freeram_dir	;\Let mario be free when 0.
	BNE .cannon_notdone	;|
	JMP .cannon_done		;/
.cannon_notdone:
	LDA #$01		;\Allow screen to scroll up.
	STA $1404|!addr	;/
	STZ $73			;\No spinjump or crouching (to prevent
	STZ $140D|!addr	;/player being able to "move").
	LDA $77			;\If player blocked..
	BNE .stop_player		;/Then stop player.
	LDY !freeram_dir	;\set x and y speed
	LDA cannon_x_speed,y	;|
	STA $7B			;|
	LDA cannon_Y_speed,y	;|
	STA $7D			;/
	BRA .set_facing_dir
.stop_player:
	STZ !freeram_dir	;\Revert player
	STZ $7D			;|
	STZ $7B			;/
	BRA .cannon_done
.set_facing_dir:
	LDA !freeram_dir	;\if mario is going straight
	CMP #$01		;|up or down, and/or inside
	BEQ .noface		;|cannon, then don't face
	CMP #$05		;|
	BEQ .noface		;|
	CMP #$09		;|
	BEQ .noface		;/
	LDY !freeram_dir	;\face correctly
	LDA mario_face_dir,y	;|
	STA $76			;/
.noface:
	LDA !freeram_dir
	ASL			;>Because JMP addresses are 2 bytes.
	TAX			;>Transfer to index
	JMP.w (.Facing,x)
.Facing:
	dw .cannon_done		;>#$00
	dw .up_jmp_pose		;>#$01
	dw .long_jmp_pose	;>#$02
	dw .long_jmp_pose	;>#$03
	dw .sit_pose		;>#$04
	dw .sit_pose		;>#$05
	dw .sit_pose		;>#$06
	dw .long_jmp_pose	;>#$07
	dw .long_jmp_pose	;>#$08
	dw .waiting			;>#$09

.waiting
;this is when the player is waiting in cannon. (happens if not #$01
;#$08).
	LDA #$FF		;\become invisible, not compatable w/
	STA $78			;/yoshi.
	LDA #$4C		;\disable controls version1:
	BRA .cannon_done
.up_jmp_pose:
	STZ $13ED|!addr
	LDA #$0B
	STA $72
	BRA .disable_ctrls2
.sit_pose:
	LDA #$1C
	STA $13ED|!addr
	LDA #$24
	STA $72
	BRA .disable_ctrls2
.long_jmp_pose:
	LDA #$0C
	STA $72
	STZ $13ED|!addr
.disable_ctrls2:
	LDA #$CF		;\disable controls version2:
.cannon_done:
	TRB $15			;|only allows L/R, select and start.
	TRB $16			;|
	TRB $17			;|
	TRB $18			;/
	RTL			;>if you have codes below here, remove this RTL
				;and move the table that was below here to the very
				;bottom of uberasm's file code (so that other codes
				;are located between the table and this code above).

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This should be located on the very bottom of the page if you have
;other codes past the RTL.
;This table should be located after (below) the pointer to it (which is:
;"cannon_x_speed" for example, or the game will crash).
;this is the speed table for each cannon direction, the order of the
;numbers follow:
;1st number = not used
;2nd number = up
;3rd number = up-right
;4th number = right
;5th number = down-right
;6th number = down
;7th number = down-left
;8th number = left
;9th number = up-left
;10th number = waiting in cannon (x and y speed are both zero)
;
;                   --  U   UR  R   DR  D   DL  L   LU  W
cannon_x_speed: db $00,$00,$2D,$40,$2D,$00,$D3,$C0,$D3,$00
cannon_Y_speed: db $00,$C0,$D3,$00,$2D,$40,$2D,$00,$D3,$00
;
;To find the magnitude of the diagional speed, here is the
;formula: S*sin(45)
;Where S is the unsigned speed (invert to negative by using
;#$100 - #$ss), example

;#$40 = 64 in decimal, so...

;64*sin(45)

;you'll get a value close to 45 in decimal (which is #$2D in hex),
;use that on BOTH X and Y speeds.
;Make sure your windows calculator is not in programmer mode or it
;will always round down.
;to have edited and still have "equal" positive (right and down)
;and negative (left and up) speeds, use this forumla (in hex):
;
;N=100-P
;
;N = negative value (#$80-#$FF)
;P = positive value (#$01-#$7F)

mario_face_dir:		;don't change this!!
	db $00,$00,$01,$01,$01,$00,$00,$00,$00,$00