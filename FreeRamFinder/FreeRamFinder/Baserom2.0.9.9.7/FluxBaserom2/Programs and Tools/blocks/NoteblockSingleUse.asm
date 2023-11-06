db $37

JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH
JMP Cape : JMP Fireball
JMP MarioCorner : JMP MarioInside : JMP MarioHead
JMP WallRun : JMP WallFeet

!activate_sides		= 0		; Whether the note block can be bounced from the sides or not.

!bounce_num			= $0B	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_block		= $02	; FF. See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $02	; YXPPCCCT properties

!allow_duplication = 0		; By default, custom blocks are immune to block duplication
							; But it is possible to still enable them if you recreate
							; the code which handles interaction with bounce blocks.

MarioHead:
MarioSide:
if !activate_sides
    LDA #$08
	STA $1DFC
	LDA $93
	INC
    BRA DoBounce
endif

Return:
Fireball:
MarioInside:
WallRun:
WallFeet:
MarioBelow:
Cape:
    LDY #$10	;act like tile 130
	LDA #$30
	STA $1693
    RTL

MarioAbove:
MarioCorner:
	LDA #$03
    BRA DoBounce

SpriteH:
	LDA !15A0,x
	BNE Return
	LDA !E4,x
	SEC : SBC $1A
	CLC : ADC #$14
	CMP #$1C
	BCC Return
	%check_sprite_kicked_horiz_alt()
	BCC Return
	LDA #$05
    BRA SpriteShared

SpriteV:
	LDA !14C8,x
	SEC : SBC #$09
	CMP #$02
	BCS Return
	LDA !AA,x
	BPL Return
	LDA !1588,x
	AND #$03
	BNE Return
	LDA #$08
if !allow_duplication
	STA !1FE2,x
	; This code is janky because it doesn't fully replicate
	; the interaction points. This dissonance causes the
	; game to duplicate blocks if you manage to kick a
	; shell at a block when their tops are touching each
	; other.
	LDA !E4,x
	CLC : ADC #$08
	STA $9A
	LDA !14E0,x
	ADC #$00
	STA $9B
	LDA !D8,x
	AND #$F0
	STA $98
	LDA !14D4,x
	STA $99
endif

SpriteShared:
	STA !1FE2,x
	%sprite_block_position()

	LDA #$00

DoBounce:
    ;WDM
	PHX
	PHY
	TAY
	LDA #!bounce_num
	LDX #!bounce_block
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y

	PLY
	PLX
    RTL

print "A noteblock that can only be bounced on once before poofing. Accurate physics."