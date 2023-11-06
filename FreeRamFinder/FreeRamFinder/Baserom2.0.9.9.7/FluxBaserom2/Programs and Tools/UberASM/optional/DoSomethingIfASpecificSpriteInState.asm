!SpriteNumber = $80 ; key
!SpriteState = $0B ; carried

main:
LDX #!sprite_slots-1 ; This is #$0C?
.loop
LDA !9E,x
CMP #!SpriteNumber
BNE .next
LDA !14C8,x
CMP #!SpriteState
BNE .next
INC $19 ; your code here
.next
DEX
BPL .loop
RTL