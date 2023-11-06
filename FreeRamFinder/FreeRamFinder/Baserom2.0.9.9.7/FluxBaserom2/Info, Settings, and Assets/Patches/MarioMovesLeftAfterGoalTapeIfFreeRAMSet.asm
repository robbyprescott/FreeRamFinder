; Moves Mario left instead of right after getting the goal tape in the level this is enabled for, i.e. for left-facing levels.
; by meatloaf

; After patching this, get GoalTapeMoveLeft.asm from UberASM's /optional level asm/, put it in /level/ and set to for the level you want.



if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
else
	lorom
	!addr = $0000
endif

; set this value to non-zero in uberasm or similar for augmented behavior
!freeram = $0EEB

!byetudlr_hold = $15
!player_dir    = $76
!player_x_spd  = $7B

!GoalTile = $D4

; pre peace-sign goal routine override
org $00C97A
	JSR set_player_dir_and_get_walk_dir
	STX !player_dir
	LDA goal_walk_speed_tbl,x
	STA !player_x_spd
;       org $00C984

; post peace-sign goal routine override
org $00C9C5
	JSR set_goal_walk_direction
	NOP

org $00FF93  ; there's 45 bytes of space at the end of bank 0.
set_player_dir_and_get_walk_dir:
	JSR set_goal_walk_direction
	LSR
	EOR #$01
	TAX
	RTS

set_goal_walk_direction:
	LDA !freeram|!addr
	BNE .left
.right:
	LDA #%00000001        ; force holding right
	BRA .set_controller
.left:
	LDA #%00000010        ; force holding left
.set_controller:
	STA !byetudlr_hold    ; store to held buttons
	RTS

goal_walk_speed_tbl:
	db $FB : db $05

; goal tape gfx override
org $01C135
	JSR goal_gfx_set_props
;36 bytes avail
	LDA $00
	BCS .nosub         ; carry set when we're drawing flipped goalpost.
	SEC
	SBC #$08
.nosub:
	STA $0300|!addr,y
	CLC
	ADC #$08
	STA $0304|!addr,y
	CLC
	ADC #$08
	STA $0308|!addr,y

	LDA $01
	CLC
	ADC #$08
	STA $0301|!addr,y
	STA $0305|!addr,y
	STA $0309|!addr,y
	LDY #$00
	LDA #$02
	JMP $B7BB
	; 18 bytes of original routine left over
	padbyte $FF : pad $01C16E
;       org $01C16E

; 65 bytes free; this routine is 47 bytes long.
org $01FFBF
goal_gfx_set_props:
	LDA !freeram|!addr       ; load 'left goal' freeram
	BEQ .cont                ; continue as normal
	LDA #%01000000           ; set x-flip
.cont
	ORA #$32                 ; original properties + flip flag
	STA $0303|!addr,y        ;\ tile 1 props
	STA $0307|!addr,y        ;| tile 2 props
	STA $030B|!addr,y        ;/ tile 3 props
	ROL #2                   ; shift `x' part into carry.
	LDA #!GoalTile           ; load goal tile gfx
	BCS .gfx_reverse
	STA $0302|!addr,y
	INC A
	STA $030A|!addr,y
	BRA .return
.gfx_reverse
	STA $030A|!addr,y
	INC A
	STA $0302|!addr,y
.return
	STA $0306|!addr,y
	RTS
