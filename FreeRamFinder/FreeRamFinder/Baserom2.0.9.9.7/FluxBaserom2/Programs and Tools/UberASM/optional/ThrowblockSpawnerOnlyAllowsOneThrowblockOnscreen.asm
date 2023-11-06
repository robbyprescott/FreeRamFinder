; in conjunction use with the (normally) infinite throwblock spawner block

!SpriteNumber = $53 ; throwblock

main:
    LDX #!sprite_slots-1
.loop
    LDA !sprite_num,x
    CMP #!SpriteNumber
    BEQ .DoThing
.next
    DEX
    BPL .loop
    RTL
.DoThing
	LDA #$01
	STA $0E23
	endif
    BRA .next