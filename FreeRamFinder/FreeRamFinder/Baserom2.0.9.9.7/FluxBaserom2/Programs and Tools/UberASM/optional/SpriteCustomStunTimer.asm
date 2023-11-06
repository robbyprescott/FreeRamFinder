; by TheBiob, with mods by SJC 

!Sprite = $30 ; Dry bones, stays ledge. $0D Bobomb. $0F goomba 
!StunLength = $30 ; #$FF is normal? Set #$00 to stun forever.
!ExtraBitCheck = 0 ; for use with those sprites that can be made carryable with the extra bit set

main:
	LDX #!sprite_slots-1
-	if !ExtraBitCheck = 1
    LDA !7FAB10,x		;/
    AND #$04			;|
    BEQ +
	endif
	LDA !14C8,x
	BEQ +
	LDA !9E,x
	CMP #!Sprite
	BNE +
	LDA !1540,x
	INC
	BNE +
	LDA #!StunLength   
	STA !1540,x
+	DEX : BPL -
	RTL