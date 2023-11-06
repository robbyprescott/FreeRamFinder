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
;sprite tool / pixi defines
%define_sprite_table("D8", $D8, $3216)
%define_sprite_table("14D4", $14D4, $3258)

org $01BEE7
	autoclean JML WandWrapFix
	
freecode

WandWrapFix:
	REP #$20		;just in case $00-$01 are used
	LDA $00
	PHA
	SEP #$20
	
	LDA !D8,x		;Get 16-bit Y pos
	SEC
	SBC $1C
	STA $00
	LDA !14D4,x
	SBC $1D
	STA $01
	
	REP #$20		;Place wand where the Magikoopa's hand is at
	LDA $00			;\If wand is offscreen vertically, simply don't draw
	CLC
	ADC #$0010
	CMP #$FFF8
	BMI .NoDraw
	CMP.w #$00E0-1
	BPL .NoDraw
	SEP #$20
	STA $0309|!addr,y
	
	.NoDraw
	REP #$20
	PLA
	STA $00
	SEP #$20
	JML $01BEF2|!bank