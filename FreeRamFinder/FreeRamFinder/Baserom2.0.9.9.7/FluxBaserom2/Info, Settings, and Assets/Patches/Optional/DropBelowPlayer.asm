;This patch let's the player drop items below them instead of next to them.
;The first value represents the offset (in pixels) when facing left, the second value
;represents the offset (in pixels) when facing right.
!table_onGround				= 	$F3,$0D		;offsets for dropping the item while being on the ground (vanilla by default)
!table_inAir				= 	$FF,$01		;offsets for dropping the item while being in the air

;When dropping a sprite, should it be matched with the player's X-Speed or not?
!MakeSpriteMatchPlayerSpeed	=	1			;0 = no, 1 = yes

;------------------------------------------------------------------------------------------
;SA-1 Defines (Don't change these!)
;------------------------------------------------------------------------------------------
if read1($00FFD5) == $23
    sa1rom
    !sa1  = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1  = 0
    !addr = $0000
    !bank = $800000
endif
;------------------------------------------------------------------------------------------
;Main Code
;------------------------------------------------------------------------------------------
org $019F99
	if !MakeSpriteMatchPlayerSpeed
		db $FF,$00
	else
		db $FC,$04
	endif

org $01A04B
	autoclean JSL DropBelowMario
freecode

table_Ground:
	db !table_onGround
	
table_Air:
	db !table_inAir

DropBelowMario:
	PHB							;|\ preserve bank 
	PHK							;||
	PLB							;|/
	LDY $76						;Y = Direction the player is facing
	LDA $13EF|!addr				;|\ Check if the player is touching ground
	BEQ PlayerIsInAir			;|/
	LDA $D1						;|\ Load drop offsets for the player being on ground
	CLC							;||
	ADC table_Ground,y			;|/
	BRA Return					;return to original code
PlayerIsInAir:
	LDA $D1						;|\ Load drop offsets for the player being in the air
	CLC							;||
	ADC table_Air,y				;|/
Return:	
	PLB							;restore bank
RTL	