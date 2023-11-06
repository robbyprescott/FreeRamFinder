!sa1	= 0			; 0 if LoROM, 1 if SA-1 ROM.
!dp	= $0000			; $0000 if LoROM, $3000 if SA-1 ROM.
!addr	= $0000			; $0000 if LoROM, $6000 if SA-1 ROM.
!bank	= $800000		; $80:0000 if LoROM, $00:0000 if SA-1 ROM.

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
	!bank	= $000000
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!bank	= $000000
endif

macro define_sprite_table(name, addr, addr_sa1)
	if !sa1 == 0
		!<name> = <addr>
	else
		!<name> = <addr_sa1>
	endif
endmacro

%define_sprite_table("D8", $D8, $3216)
%define_sprite_table("E4", $E4, $322C)
%define_sprite_table("14D4", $14D4, $3258)
%define_sprite_table("14E0", $14E0, $326E)

org $02E5E8|!bank
	autoclean JML MovingHoleMarioContact
	
org $02E61F|!bank
	autoclean JML MovingHoleSpriteContactClipping
	
freedata
print "Code is located at: $", pc
MovingHoleMarioContact:
	JSL $03B664|!bank
	
	LDA !E4,x
	CLC
	ADC #$10
	STA $04

	LDA !14E0,x
	ADC #$00
	STA $0A

	LDA #$10 ; Width of sprite clipping
	STA $06

	LDA !D8,x
	SEC
	SBC #$02
	STA $05

	LDA !14D4,x
	SBC #$00
	STA $0B

	LDA #$1A ; Height of sprite clipping
	STA $07

	JSL $03B72B|!bank
	JML $02E5EC|!bank

MovingHoleSpriteContactClipping:
	LDA !E4,x
	CLC
	ADC #$10
	STA $04

	LDA !14E0,x
	ADC #$00
	STA $0A

	LDA #$10 ; Width of sprite clipping
	STA $06

	LDA !D8,x
	SEC
	SBC #$02
	STA $05

	LDA !14D4,x
	SBC #$00
	STA $0B

	LDA #$2A ; Height of sprite clipping
	STA $07
	JML $02E623|!bank