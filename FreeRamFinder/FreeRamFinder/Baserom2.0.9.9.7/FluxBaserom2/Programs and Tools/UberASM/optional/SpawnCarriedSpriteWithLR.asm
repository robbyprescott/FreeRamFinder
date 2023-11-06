;Settings

	!sprnum_L = $53		;Sprite # to spawn when pressing L
	!custom_L = 0		;0 = not a custom sprite, 1 = custom sprite.
	
	!sprnum_R = $07		;Sprite # to spawn when pressing R
	!custom_R = 0		;0 = not a custom sprite, 1 = custom sprite.
	
	!cape = 0			;0 = cannot spawn item while flying, 1 = can spawn item while flying.

;The code is actually in the library file. This allows for the possibility of using it with
;different settings in different levels without repeated code being inserted.

main:
	LDA #!sprnum_L
	STA $00
	LDA #!sprnum_R
	STA $01
	LDA #!custom_L
	STA $02
	LDA #!custom_R
	STA $03
if !cape
		SEC
else
		CLC
endif
	JSL SpawnCarriedSpriteWithLRLibrary_main
	RTL 