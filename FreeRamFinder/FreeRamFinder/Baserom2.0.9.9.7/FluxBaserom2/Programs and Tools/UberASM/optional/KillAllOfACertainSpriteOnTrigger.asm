; Resets RAM too

!SpriteNumber = $2D ; baby Yoshi
!RAM = $14AF

main:
    LDX #!sprite_slots-1 ; 0B?
.loop

    LDA !sprite_num,x ; 14C8?
    CMP #!SpriteNumber
    BEQ .thing

.next
    DEX
    BPL .loop
    RTL

.thing
if read4($02FFE2) == $44535453 ; if pixi is installed
    LDA !extra_bits,x ; check if sprite is custom
    AND #$08
    BNE .next
endif

    ;LDA !sprite_x_high,x
    ;XBA
    ;LDA !sprite_x_low,x
	
	LDA !RAM
	BEQ .next
	LDA #$38 ; bang SFX
	STA $1DFC
	LDA #$04 ; "spin-jump" state, i.e. puff of smoke.
    STA !14C8,x
    LDA #$10 ; timer
    STA !1540,x
	STZ !RAM
    ;STZ !sprite_status,x                    ; 14C8.
    BRA .next