!SpriteNumber = $2D ; baby Yoshi

main:
    LDX #!sprite_slots-1
.loop

    LDA !sprite_num,x
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
	
	LDA $B6,x
    BEQ .Return
    INC $19
    .Return
	;STZ !RAM
    BRA .next