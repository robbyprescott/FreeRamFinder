!CustomSprite = 0 ; set to 1 if you're using a custom sprite
!SpriteNumber = $35 ; Yoshi
!SpriteState = $01 ; init
!Trigger = $14AF

main:
    LDX #!sprite_slots-1
.loop
    if !CustomSprite
	LDA $7FAB9E,x
	else
    LDA !sprite_num,x
    endif
	CMP #!SpriteNumber
    BEQ .thing

.next
    DEX
    BPL .loop
    RTL

.thing
    LDA !Trigger
	BEQ .next
	LDA #!SpriteState
	STA !sprite_status,x ; $14C8
    LDA #$04 ; set (to 1 if vanilla, but 3 if custom??)
	STA !extra_bits,x ; ; $7FAB10
    BRA .next