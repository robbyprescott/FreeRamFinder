; This actually just kills any moving / spinning coin sprite on-screen, the moment it's spawned by klling a sprite e.g. with a fireball.
; So obviously don't use the normal moving coin sprite either.

; Useful for "teleport-on-all-sprites-killed" or something like this,
; because otherwise the spawned coin is considered a new sprite.

!IncreaseCoinCount = 0
!SpriteNumber = $21 ; moving coin
;!Trigger = $14AF

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
    STZ !sprite_status,x ; can change this to do something else when sprite
	if !IncreaseCoinCount
	INC $13CC
	endif
    BRA .next