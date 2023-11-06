!dp = $0000
!addr = $0000
!bank = $800000
!sa1 = 0
if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!sa1 = 1
endif

macro define_sprite_table(name, addr, addr_sa1)
	if !sa1 == 0
		!<name> = <addr>
	else
		!<name> = <addr_sa1>
	endif
endmacro

%define_sprite_table(sprite_y_high, $14D4, $3258)
%define_sprite_table("14D4", $14D4, $3258)


org $02F2FC
	autoclean JSL FlowerFix
	NOP

freecode
FlowerFix:
	LDA !14D4,x
	STA $1729|!addr,y
	RTL