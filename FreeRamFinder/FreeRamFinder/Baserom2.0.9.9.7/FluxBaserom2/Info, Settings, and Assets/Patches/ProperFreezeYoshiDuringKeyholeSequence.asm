;SA-1 stuff
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	!gsu = 0

	if read1($00FFD6) == $15
		sfxrom
		!dp = $6000
		!addr = !dp
		!bank = $000000
		!gsu = 1
	elseif read1($00FFD5) == $23
		sa1rom
		!dp = $3000
		!addr = $6000
		!bank = $000000
		!sa1 = 1
	endif
	;Sprite SA-1
		macro define_sprite_table(name, addr, addr_sa1)
			if !sa1 == 0
				!<name> = <addr>
			else
				!<name> = <addr_sa1>
			endif
		endmacro
		%define_sprite_table("9E", $9E, $3200)
		%define_sprite_table("AA", $AA, $9E)
		%define_sprite_table("B6", $B6, $B6)
		%define_sprite_table("C2", $C2, $D8)
		%define_sprite_table("D8", $D8, $3216)
		%define_sprite_table("E4", $E4, $322C)
		%define_sprite_table("14C8", $14C8, $3242)
		%define_sprite_table("14D4", $14D4, $3258)
		%define_sprite_table("14E0", $14E0, $326E)
		%define_sprite_table("14EC", $14EC, $74C8)
		%define_sprite_table("14F8", $14F8, $74DE)
		%define_sprite_table("1504", $1504, $74F4)
		%define_sprite_table("1510", $1510, $750A)
		%define_sprite_table("151C", $151C, $3284)
		%define_sprite_table("1528", $1528, $329A)
		%define_sprite_table("1534", $1534, $32B0)
		%define_sprite_table("1540", $1540, $32C6)
		%define_sprite_table("154C", $154C, $32DC)
		%define_sprite_table("1558", $1558, $32F2)
		%define_sprite_table("1564", $1564, $3308)
		%define_sprite_table("1570", $1570, $331E)
		%define_sprite_table("157C", $157C, $3334)
		%define_sprite_table("1588", $1588, $334A)
		%define_sprite_table("1594", $1594, $3360)
		%define_sprite_table("15A0", $15A0, $3376)
		%define_sprite_table("15AC", $15AC, $338C)
		%define_sprite_table("15B8", $15B8, $7520)
		%define_sprite_table("15C4", $15C4, $7536)
		%define_sprite_table("15D0", $15D0, $754C)
		%define_sprite_table("15DC", $15DC, $7562)
		%define_sprite_table("15EA", $15EA, $33A2)
		%define_sprite_table("15F6", $15F6, $33B8)
		%define_sprite_table("1602", $1602, $33CE)
		%define_sprite_table("160E", $160E, $33E4)
		%define_sprite_table("161A", $161A, $7578)
		%define_sprite_table("1626", $1626, $758E)
		%define_sprite_table("1632", $1632, $75A4)
		%define_sprite_table("163E", $163E, $33FA)
		%define_sprite_table("164A", $164A, $75BA)
		%define_sprite_table("1656", $1656, $75D0)
		%define_sprite_table("1662", $1662, $75EA)
		%define_sprite_table("166E", $166E, $7600)
		%define_sprite_table("167A", $167A, $7616)
		%define_sprite_table("1686", $1686, $762C)
		%define_sprite_table("186C", $186C, $7642)
		%define_sprite_table("187B", $187B, $3410)
		%define_sprite_table("190F", $190F, $7658)
		%define_sprite_table("1FD6", $1FD6, $766E)
		%define_sprite_table("1FE2", $1FE2, $7FD6)
;hijacks
	org $01EA9A
	autoclean JML FixUnDucking
	
	org $01EB16
	autoclean JML FixDucking

	org $01F1E5
	autoclean JML FixSpitting
	;^This address also handles yoshi to extend his tongue,
	;and yes if you trigger a keyhole without a key in yoshi's
	;mouth and press X or Y, SFX of yoshi extending his tongue
	;will still play.
;main code
	freecode
	FixUnDucking:
		LDA $13FB|!addr
		ORA $9D
		BNE .No
		STZ $18DC|!addr
		.No
		LDA !C2,x
		JML $01EA9F

	FixDucking:
		LDA $13FB|!addr
		ORA $9D
		BNE .CODE_01EB21
		LDA $15
		AND.b #%00000100
		BEQ .CODE_01EB21
		LDY #$04
		INC $18DC|!addr
		.CODE_01EB21
		JML $01EB21
	
	FixSpitting:
		LDA $13FB|!addr
		ORA $9D
		BNE .No
		BIT $16
		BVC .Return01F1DE
		JML $01F1E9
		.No
		.Return01F1DE
		JML $01F1DE