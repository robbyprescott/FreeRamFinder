; Probably of limited use, because set @ init anyways

!CustomSprite = 1 ; set to 0 if it's a vanilla sprite
!SpriteNumber = $28 ; $A8 is...

!FirstExtraByteValue = $01
!SecondExtraByteValue = $00
!ThirdExtraByteValue = $00
!FourthExtraByteValue = $00

!Trigger = $14AF

main:
    LDX #!sprite_slots-1 ; sprte_slots = $12
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
    LDA #!FirstExtraByteValue
    STA !extra_byte_1,x
	;LDA #!SecondExtraByteValue
    ;STA !extra_byte_2,x
	;LDA #!ThirdExtraByteValue
    ;STA !extra_byte_3,x
	;LDA #!FourthExtraByteValue
    ;STA !extra_byte_4,x
	;STZ !sprite_status,x ; 14C8
    BRA .next
	
	
;%define_sprite_table("extra_byte_1",$7FAB40,$400099)
;%define_sprite_table("extra_byte_2",$7FAB4C,$4000AF)
;%define_sprite_table("extra_byte_3",$7FAB58,$4000C5)
;%define_sprite_table("extra_byte_4",$7FAB64,$4000DB)