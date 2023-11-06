;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SMW/SMB1 Mushroom Scale Platforms
;by Ice Man
;modified and upgraded by Von Fahrenheit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Extra bit:
; 0 = SMW styled scales (tiles below platform)
; 1 = SMB styled scales (tiles above platform, downward speed doubled)

	; used with smw style
	!smwtile1	= $0025		; empty tile left above
	!smwtile2	= $0132		; tile generated below

	; used with smb style
	!smbtile1	= $0025		; empty tile left below
	!smbtile2	= $0006		; tile generated above


	!tile		= !extra_byte_1,x	; which tile should be used
						; change to #$XX where XX is the tile number to use a constant
						; by default this lets the extra byte 1 value be used as the tile number
						; the CFG editor is used to determine which page should be used
						; to use with SP4 = GFX05, insert with extension = 0x80

;	!tile		= #$80			; SMW version
						; if you don't want to set tile with extra prop 1, comment that line and uncomment this one


	!distance	= !extra_byte_2,x	; distance between two platforms
						; 0 will default to 4 tiles

	!xflip		= !extra_byte_3,x	; 0 = both tiles look the same, 1 = the second (right) tile is flipped horizontally



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Init & Main Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "INIT ",pc	
		PHB : PHK : PLB
		LDA !D8,x					;Sprite Ypos Low Byte (table)
		STA !1534,x
		LDA !14D4,x					;Sprite Ypos High Byte (table)
		STA !151C,x					;Vertical direction	
		LDA !extra_byte_2,x
		BNE $02 : LDA #$40				; add distance set in extra byte 2
		CLC : ADC !E4,x
		STA !C2,x					;Sprite State
		LDA !14E0,x					;Sprite Xpos High Byte (table)
		ADC #$00					;Add in nothing
		STA !1602,x
		PLB
		RTL							;Return

	print "MAIN ",pc
		LDA !15EA,x					;Sprite's index to OAM
		PHA
		PHB
		PHK							;Wrapper
		PLB
		JSR Code_Start				;Execute sprite
		PLB
		PLA
		STA !15EA,x					;Sprite's index to OAM
		RTL							;Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Sprite code start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Code_Start:
		LDA #$02
		%SubOffScreen()
		STZ $185E|!Base2				;Keep track of a tile to generate			
		LDA !E4,x					;Sprite Xpos Low Byte (table)
		PHA							;Push A
		LDA !14E0,x					;Sprite Xpos High Byte (table)
		PHA							;Push A
		LDA !D8,x					;Sprite Ypos Low Byte (table)
		PHA							;Push A
		LDA !14D4,x					;Sprite Ypos High Byte (table)
		PHA							;Push A
		LDA !151C,x					;Vertical direction
		STA !14D4,x					;Sprite Ypos High Byte (table)
		LDA !1534,x
		STA !D8,x					;Sprite Ypos Low Byte (table)
		LDA !C2,x					;Sprite State
		STA !E4,x					;Sprite Xpos Low Byte (table)
		LDA !1602,x
		STA !14E0,x					;Sprite Xpos High Byte (table)
		LDY #$02					;#$02 into Y
		JSR Block_Init				;Generate tiles
		PLA							;Pull A
		STA !14D4,x					;Sprite Ypos High Byte (table)
		PLA							;Pull A
		STA !D8,x					;Sprite Ypos Low Byte (table)
		PLA							;Pull A
		STA !14E0,x					;Sprite Xpos High Byte (table)
		PLA							;Pull A
		STA !E4,x					;Sprite Xpos Low Byte (table)
		BCC Scale_Down
		INC $185E|!Base2					;Keep track of a tile to generate
		LDA #$F8					;Up-speed (right platform)
		JSR Set_Position			;Set sprite movement in current frame

	Scale_Down:
		LDA !15EA,x					;Sprite's index to OAM
		CLC							;Clear carry flag
		ADC #$08					;Add in #$08
		STA !15EA,x					;Sprite's index to OAM
		LDY #$00					;#$00 to Y
		JSR Block_Init				;Generate block init
		BCC Scale_Up
		INC $185E|!Base2					;Keep track of a tile to generate
		LDA #$08					;Down-speed (left platform)
		JSR Set_Position			;Set sprite movement in current frame

	Scale_Up:
		LDA $185E|!Base2					;Keep track of a tile to generate
		BNE Return
		LDY #$02					;#$02 to Y
		LDA !D8,x					;Sprite Ypos Low Byte (table)
		CMP !1534,x
		BEQ Return
		LDA !14D4,x					;Sprite Ypos High Byte (table)
		SBC !151C,x					;Vertical direction
		BMI Do_Position

		LDY #$FE					;Restore speed
	Do_Position:
		TYA							;Y -> A
		JSR Set_Position			;Set sprite movement in current frame

	Return:
		RTS							;Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generate tiles
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scale_SMW:
	dw !smwtile1,!smwtile2,!smwtile2,!smwtile1

Scale_SMB:
	dw !smbtile2,!smbtile1,!smbtile1,!smbtile2
	
	Block_Init:
		PHY
		JSR MushroomScaleGfx		;Draw scale graphics
		PLY

		.Main
		LDA !D8,x					;Sprite Ypos Low Byte (table)
		AND #$0F					;Generate tile every 16 pixel
		BNE Invisible_Block
		LDA !AA,x					;Sprite Y Speed Table
		BEQ Invisible_Block
		LDA !AA,x					;Sprite Y Speed Table
		BPL Generate_Block
		INY							;Increase Y

	Generate_Block:
		TYA
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04 : BNE SMB_Scales			;#$01 = SMB scales

		LDA Scale_SMW,y : STA $00		;Set scale tiles
		LDA Scale_SMW+1,y : STA $01
		BRA Continue_Block			;Continue block code

	SMB_Scales:
		LDA Scale_SMB,y : STA $00		;Set scale tiles
		LDA Scale_SMB+1,y : STA $01

	Continue_Block:
		LDA !E4,x					;Sprite Xpos Low Byte (table)
		STA $9A						;Block creation: X position (low)
		LDA !14E0,x					;Sprite Xpos High Byte (table)
		STA $9B						;Block creation: X position (high)
		LDA !D8,x					;Sprite Ypos Low Byte (table)
		STA $98						;Block creation: Y position (low)
		LDA !14D4,x					;Sprite Ypos High Byte (table)
		STA $99						;Block creation: Y position (high)
		STZ $1933|!Base2
		REP #$20
		JSR WithinBounds
		LDA $00
		%ChangeMap16()
		SEP #$30

	Invisible_Block:
		STZ !1528,x
		JSL $01B44F|!BankB					;Invisible Block Main
		RTS							;Return

	Set_Position:
		LDY $9D						;Lock sprites timer
		BNE Return2
		PHA							;Push A
		BMI .main
		LDA !extra_bits,x
		AND #$04 : BEQ .main
		ASL !sprite_speed_y,x

	.main	JSL $01801A|!BankB					;ypos no gravity
		PLA							;Pull A
		STA !sprite_speed_y,x					;Sprite Y Speed Table
		LDY #$00					;#$00 to Y
		LDA $1491|!Base2					;Set sprite movement in current frame
		EOR #$FF					;XOR #$FF
		INC A						;Increase A
		BPL More_Position
		DEY							;Decrease Y

	More_Position:
		CLC							;Clear carry flag
		ADC !1534,x
		STA !1534,x
		TYA							;Y -> A
		ADC !151C,x					;Vertical direction
		STA !151C,x					;Vertical direction

	Return2:
		RTS							;Return


	WithinBounds:
	.Y	LDA $98 : BMI ..0
		CMP $13D7|!Base2 : BCC .X
		LDA $13D7|!Base2
		SEC : SBC #$0010
		BRA ..W

	..0	LDA #$0000
	..W	STA $98

	.X	LDA $9A : BMI ..0
		SEP #$20
		XBA
		CMP $5E : BCC .R
		DEC A
		XBA
		LDA #$F0
		REP #$20
		STA $9A
		RTS
	..0	STZ $9A
		RTS

	.R	REP #$20
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw GFX
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	MushroomScaleGfx:
		%GetDrawInfo()
		LDA $00						;
		SEC : SBC #$08					;of mushroom scale
		STA $0300|!Base2,y					;left and right.
		CLC : ADC #$10					;
		STA $0304|!Base2,y					;

		LDA $01						;Set Y-position of
		DEC A						;mushroom scale
		STA $0301|!Base2,y					;left and right.
		STA $0305|!Base2,y					;

		LDA !tile					;Tile to use for 
		STA $0302|!Base2,y					;mushroom scale
		STA $0306|!Base2,y					;left and right.

		LDA !xflip
		BEQ $02 : LDA #$40
		STA $02

		LDA !15F6,x					;
		ORA $64						;Properties of
		STA $0303|!Base2,y					;mushroom scale
		ORA $02
		STA $0307|!Base2,y					;

		LDA #$01                	;Tiles drawn -1
		LDY #$02                	;460 = 2 (all 16x16 tiles)
		JSL $01B7B3|!BankB					;Don't draw off screen
		RTS							;Return