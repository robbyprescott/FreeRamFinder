;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Hammerbrother Platform (Sprite 9C) ;
;       Disassembly by TheBiob       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Settings

; Which X acceleration values to use first
; 0 = platform starts on the left side and goes right initially
; 1 = platform starts on the right side and goes left initially
!DEF_invert_platform = 1

; Sprite uses the cfg properties (palette, gfx page) instead of the ones provided in the properties table
!DEF_use_cfg_properties = 0

; Next few parts control the sprite that's placed on the platform and how it's positioned.
; Do note that while this does allow you to put almost every sprite on the platform,
;   not many of the original games sprites work that well with this system.

; Sprite to put on the platform (9B = Hammerbrother) (-1 = disable this feature)
!DEF_sprite_on_platform = $9B
; Whether the sprite is a custom sprite or not (0 = normal sprite, 1 = custom sprite)
!DEF_sprite_is_custom = 0
; The sprite state the sprite on the platform should be in when kicked off the platform (-1 = don't set sprite state)
!DEF_set_sprite_state = 2
; Whether there should be a smoke effect when the sprite is kicked off the platform
!DEF_smoke_effect = 1

; Y speed for the sprite when knocked off the platform
!DEF_sprite_knockoff_speed = -64

; Sprite X offset when placed on the platform (Added, positive = right)
!DEF_sprite_x_offset = $0000
; Sprite Y offset when placed on the platform (Subtracted, positive = up)
!DEF_sprite_y_offset = $0010

; Acceleration values for the platform
AccelerationX:	db +1,-1
MaxSpeedX:		db +32,-32 ; should be divisible by the corresponding acceleration value

AccelerationY:	db +2,-2
MaxSpeedY:		db +32,-32 ; should be divisible by the corresponding acceleration value

; GFX related tables
; First set are used for spread wings, second set is used for folded wings
Tile:			db $40,$40,$C6,$C6 : db $40,$40,$5D,$5D
TileXOffset:	db $00,$10,$F2,$1E : db $00,$10,$FA,$1E
TileYOffset:	db $00,$00,$F6,$F6 : db $00,$00,$FE,$FE
TileProperties:	db $32,$32,$72,$32 : db $32,$32,$72,$32
TileSize:		db $02,$02,$02,$02 : db $02,$02,$00,$00

; Bounce offsets when hitting one of the blocks from below, purely graphical, do not affect the position of the blocks themselves.
BounceYOffset:	db $00,$04,$06,$08,$08,$06,$04,$00

; Sprite Code
main:
	PHB : PHK : PLB
		JSR SpriteMain
	PLB
if !DEF_invert_platform
	RTL
init:
	INC !1534,x ; Use the second pair of acceleration values first
else
init:
endif
	RTL

; Original game's routines, don't change them
SMW_FINISH_OAM = $01B7B3|!BankB
SMW_SOLID_BLOCK = $01B44F|!BankB
SMW_UPDATE_X_NO_GRAV = $018022|!BankB
SMW_UPDATE_Y_NO_GRAV = $01801A|!BankB
SMW_CREATE_SMOKE = $01AB6F|!BankB

; compatibility checks
!DEF_USES_NMSTL = 0
if read1($02DB82) == $22
!DEF_USES_NMSTL = 1
endif
%define_sprite_table("00AA", $00AA, $309E)
%define_sprite_table("00B6", $00B6, $30B6)

; This may be changed to any empty byte on the direct page
!sprite_num_cache = $87

; Do not change these
!num_sprites = $16
!sprite_num_pointer = $B4
!sprite_y_low_pointer = $CC
!sprite_x_low_pointer = $EE

; Define word addresses for these tables so we can use them in instructions like LDA.w
!sprite_speed_y_w = $3000+!sprite_speed_y
!sprite_speed_x_w = $3000+!sprite_speed_x
!sprite_misc_c2_w = $3000+!sprite_misc_c2

macro update_pointers(addr)
    REP #$20
    LDA <addr>
    AND #$00FF
    CLC
    ADC #!sprite_num
    STA !sprite_num_pointer
    ADC.w #!num_sprites
    STA !sprite_y_low_pointer
    ADC.w #!num_sprites
    STA !sprite_x_low_pointer
    SEP #$20

    LDA (!sprite_num_pointer)
    STA !sprite_num_cache
endmacro

SpriteMain:
	JSR Graphics
if !DEF_sprite_on_platform != -1
	LDA #$FF
	STA !1594,x
	LDY.b #!SprSize-1
-	LDA !14C8,y
	CMP #$08
	BNE .next
	if !DEF_sprite_is_custom
		LDA !7FAB10,x
		AND #$08
		BEQ .next ; not custom
		LDA !7FAB9E,x ; custom sprite number
	else
		LDA !9E,y
	endif
	CMP.b #!DEF_sprite_on_platform
	BEQ PutSpriteOnPlatform
.next
	DEY
	BPL -
	if !sa1
	JMP SkipSprite
	else
	BRA SkipSprite
	endif

PutSpriteOnPlatform:
	TYA				; \ $1594 = index of sprite on platform
	STA !1594,x		; /
	LDA !E4,x
	if !DEF_sprite_x_offset == 0
		STA.w !E4,y
		LDA !14E0,x
	else
		CLC : ADC.b #!DEF_sprite_x_offset
		STA.w !E4,y
		LDA !14E0,x
		ADC.b #!DEF_sprite_x_offset>>8
	endif
	STA !14E0,y
	LDA !D8,x
	if !DEF_sprite_y_offset == 0
		STA.w !D8,y
		LDA !14D4,x
	else
		SEC
		SBC.b #!DEF_sprite_y_offset
		STA.w !D8,y
		LDA !14D4,x
		SBC.b #!DEF_sprite_y_offset>>8
	endif
	STA !14D4,y
	LDA #$00
	STA !00AA,y	; \ Reset the sprites speed so sprites that usually have speed work better
	STA !00B6,y	; /
	; If the sprite is the vanilla hammer brother then run it's graphics routine
	if !DEF_sprite_is_custom == 0 && !DEF_sprite_on_platform == $9B
		if !DEF_USES_NMSTL
			LDA !15EA,x
			CLC : ADC #$10 ; how many OAM slots were written by the platform (in bytes, 4 bytes per OAM slot)
			STA !15EA,y
		endif
		TYX
		if !sa1
			STY $00
			%update_pointers($00)
		endif
		LDA #$02
		PHA : PLB
		PHK
		PEA.w .jslrtsreturn-1
		PEA.w $02B889-1
		JML $02DAFD|!BankB
	.jslrtsreturn
		PHK : PLB
		LDX $15E9|!addr
		if !sa1
			%update_pointers($15E9|!addr)
		endif
	endif
SkipSprite:
endif
	LDA $9D
	BNE .return
	LDA #$01
	%SubOffScreen()
	LDA $13
	AND #$01
	BNE .dontupdatespeed
	LDA !1534,x
	AND #$01
	TAY
	LDA !B6,x
	CLC
	ADC AccelerationX,y
	STA !B6,x
	CMP MaxSpeedX,y
	BNE +
	INC !1534,x
+	LDA !151C,x
	AND #$01
	TAY
	LDA !AA,x
	CLC
	ADC AccelerationY,y
	STA !AA,x
	CMP MaxSpeedY,y
	BNE .dontupdatespeed
	INC !151C,x
.dontupdatespeed
	JSL SMW_UPDATE_Y_NO_GRAV
	JSL SMW_UPDATE_X_NO_GRAV
	STA !1528,x
	JSL SMW_SOLID_BLOCK
	LDA !1558,x
	BEQ .return
	LDA #$01
	STA !C2,x
	%SubHorzPos()
	LDA $0E
	CMP #$08
	BMI +
	INC !C2,x
+
if !DEF_sprite_on_platform != -1
	LDY !1594,x
	BMI .return
	if !DEF_set_sprite_state != -1
		LDA.b #!DEF_set_sprite_state		; \ Set the sprite state of the sprite on the platform
		STA !14C8,y							; /
	endif
	LDA.b #!DEF_sprite_knockoff_speed
	STA.w !AA,y
	if !DEF_smoke_effect
		PHX
		TYX
		JSL SMW_CREATE_SMOKE
		PLX
	endif
endif
.return
	RTS

Graphics:
	%GetDrawInfo()
	LDA !C2,x
	STA $07
	LDA !1558,x
	LSR
	TAY
	LDA BounceYOffset,y
	STA $05
	LDY !15EA,x
	PHX
if !DEF_use_cfg_properties
	LDA !15F6,x
	STA $03
endif
	LDA $14
	LSR
	AND #$04
	STA $02
	LDX #$03
.gfxloop
	STX $06
	TXA
	ORA $02
	TAX
	LDA $00
	CLC
	ADC TileXOffset,x
	STA $0300|!addr,y
	LDA $01
	CLC
	ADC TileYOffset,x
	STA $0301|!addr,y
	PHX
	LDX $06
	CPX #$02
	BCS +
	INX
	CPX $07
	BNE +
	LDA $0301|!addr,y
	SEC
	SBC $05
	STA $0301|!addr,y
+	PLX
	LDA Tile,x
	STA $0302|!addr,y
	LDA TileProperties,x
if !DEF_use_cfg_properties
	AND #$F0
	ORA $03
endif
	STA $0303|!addr,y
	PHY
	TYA : LSR #2 : TAY
	LDA TileSize,x
	STA $0460|!addr,y
	PLY
	INY #4
	LDX $06
	DEX
	BPL .gfxloop
	PLX
	LDY #$FF
	LDA #$03
	JSL SMW_FINISH_OAM
	RTS

print "INIT ",hex(init)
print "MAIN ",hex(main)