if read1($00FFD5) == $23
	sa1rom
else
	lorom
endif

;===================================================================================================

!whole_egg_tile		= $44	; Sprite tile of the uncracked Yoshi egg
!cracked_egg_tile	= $46	; Sprite tile of the cracked Yoshi egg
!smoke_puff_tile	= $62	; Sprite tile of smoke puff (hatched) Yoshi egg
!egg_shard_tile		= $29	; Sprite tile of Yoshi egg shard minor extended sprite

!whole_egg_page		= $00	; Graphics page used by hatching Yoshi egg + Yoshi's throat tile
!cracked_egg_page	= $00	;  $00 = SP1/SP2
!smoke_puff_page	= $00	;  $01 = SP3/SP4
!swallowing_page	= $00	; 

!whole_egg_prop		= $3A	; YXPPCCCT properties of Yoshi egg found in block or laid by Yoshi (default: green)
!color_egg_prop_x0	= $08	; YXPPCCCT properties of Yoshi Egg sprite (2C) at position X=0 (default: red)
!color_egg_prop_x1	= $06	; YXPPCCCT properties of Yoshi Egg sprite (2C) at position X=1 (default: blue)
!color_egg_prop_x2	= $04	; YXPPCCCT properties of Yoshi Egg sprite (2C) at position X=2 (default: yellow)
!color_egg_prop_x3	= $06	; YXPPCCCT properties of Yoshi Egg sprite (2C) at position X=3 (default: blue)
!egg_shard_prop		= $02	; YXPPCCCT properties of Yoshi egg shard minor extended sprite;
				;  Y- and X-flip automatically applied as needed

;===================================================================================================

org $018335			; YXPPCCCT properties of free-standing Yoshi Egg sprite (2C)
	db !color_egg_prop_x0
	db !color_egg_prop_x1
	db !color_egg_prop_x2
	db !color_egg_prop_x3

org $019C17			; Tile used by egg found in block or laid by Yoshi
	db !whole_egg_tile

org $01F75C			; Tile and graphics page for hatching Yoshi egg sequence
	db !smoke_puff_page
	db !cracked_egg_page
	db !cracked_egg_page
	db !whole_egg_page

	db !smoke_puff_tile
	db !cracked_egg_tile
	db !cracked_egg_tile
	db !whole_egg_tile

org $01F794			; Tile used by free-standing Yoshi Egg sprite (2C)
	db !whole_egg_tile

org $028EB2			; Tile used by Yoshi egg shard minor extended sprite
	db !egg_shard_tile

org $028EBC			; Base YXPPCCCT properties used by Yoshi egg shard minor extended sprite
	db !egg_shard_prop&$3F

org $07F42A			; YXPPCCCT properties used by egg found in block or laid by Yoshi
	db !whole_egg_prop