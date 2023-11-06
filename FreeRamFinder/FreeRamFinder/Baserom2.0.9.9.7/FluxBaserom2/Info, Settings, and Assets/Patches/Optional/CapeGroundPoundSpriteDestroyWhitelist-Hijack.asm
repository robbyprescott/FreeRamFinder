;------------------------------------------------------------------------------------------
;This Patch let's you easily whitelist sprites that should not get hit
;when performing a Ground Pound with the cape. It works with normal and custom sprites.
;All you have to do is set up the lists of sprites below!
;You can add or remove sprites from the list.
;------------------------------------------------------------------------------------------

!table_Sprites	=	$04,$05,$06,$07,$0F

;------------------------------------------------------------------------------------------
;Defines (Don't change these!)
;------------------------------------------------------------------------------------------
!sizeTableSpr	= 	table_SprEnd-table_Spr

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

macro define_sprite_table(name, addr, addr_sa1)
    if !sa1 == 0
        !<name> = <addr>
    else
        !<name> = <addr_sa1>
    endif
endmacro

%define_sprite_table("9E", $9E, $3200)
%define_sprite_table("14C8", $14C8, $3242)
;------------------------------------------------------------------------------------------
;Main Code
;------------------------------------------------------------------------------------------
org $0294CE
	autoclean JML CheckSprites	
freecode

table_Spr:
	db !table_Sprites
table_SprEnd:

CheckSprites:
	PHB
	PHK
	PLB
	PHY
	LDA !14C8,x						;restore overwritten code and
	CMP #$08						;check if the sprite is dead
	BCC Return						;branch if sprite is dead
	LDY.b #!sizeTableSpr			;setup loop counter for normal sprites
checkSprLoop:
	LDA !9E,x
	CMP table_Spr,y
	BEQ Return
	DEY
	BPL checkSprLoop
Continue:
	PLY
	PLB
	JML $0294D5						;jump back to the original routine right after this hijack
Return:
	PLY
	PLB
	JML $0294F0						;jump back to the original code and continue the sprite loop