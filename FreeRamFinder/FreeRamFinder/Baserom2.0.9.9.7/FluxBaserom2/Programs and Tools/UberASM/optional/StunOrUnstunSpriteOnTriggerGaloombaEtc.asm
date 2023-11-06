; By SJandCharlieTheCat

!SpriteNumber = $0F ; Galoomba. $0D, $11, $A2
!Trigger = $14AF 

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
    LDA !Trigger 
	BEQ .Return
    LDA #$FF                ; Stun timer
    STA $1540,x             
    LDA #$09                ; Status = stunned 
    STA $14C8,x            
    BRA .next
	.Return
	STZ $1540,x ; necessary?
	LDA #$08                ; Status = normal
    STA $14C8,x             ; /
	RTL