;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite AC + AD - Wooden Spike, moving down and up/Wooden Spike, moving up/down first (X&1)
; commented by yoshicookiezeus
;
; Uses extra bit: YES
; If the extra bit is not set, the sprite will work like original sprite AC
; (spike pointing down, moves down first). If it is set, the sprite will work
; like AD (spike pointing up, moves up or down first depending on x position).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


			!RAM_MarioSpeedX	= $7B
			!RAM_MarioXPos		= $94
			!RAM_MarioXPosHi	= $95
			!RAM_SpritesLocked	= $9D
			!RAM_SpriteSpeedY	= !AA
			!RAM_SpriteSpeedX	= !B6
			!RAM_SpriteState	= !C2
			!RAM_SpriteYLo		= !D8
			!RAM_SpriteXLo		= !E4
			!OAM_DispX		= $0300|!Base2
			!OAM_DispY		= $0301|!Base2
			!OAM_Tile		= $0302|!Base2
			!OAM_Prop		= $0303|!Base2
			!OAM_TileSize		= $0460|!Base2
			!RAM_SpriteYHi		= !14D4
			!RAM_SpriteDir		= !157C
			!RAM_SprObjStatus	= !1588
			!RAM_OffscreenHorz	= !15A0
			!RAM_SpritePal		= !15F6

			!Extra_Bits		= !7FAB10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc

			LDA !Extra_Bits,x
			AND #$04
			BNE AD_Init

			LDA !RAM_SpriteYLo,X
			SEC
			SBC #$40
			STA !RAM_SpriteYLo,X  
			LDA !RAM_SpriteYHi,X
			SBC #$00
			STA !RAM_SpriteYHi,X
			RTL

AD_Init:
			LDA !RAM_SpriteXLo,X
			AND #$10
			STA !151C,X
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR Sprite_Code_Start
			PLB
			RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sprite_Code_Start:
			JSR WoodSpikeGfx	; graphics routine
			LDA !RAM_SpritesLocked	;\ if sprites locked,
			BNE Return0		;/ return
			LDA #$00
            %SubOffScreen()
			JSR CODE_039488		; Mario interaction routine
			LDA !RAM_SpriteState,x	;\ jump to coding for current sprite state
			AND #$03		; |
			JSL $0086DF		;/

WoodenSpikePtrs:	dw CODE_039458		; going up
			dw CODE_03944E		; resting at top
			dw CODE_039441		; going down
			dw CODE_03946B		; resting at bottom

Return0:
			RTS			; return

CODE_039441:
			LDA !1540,x		;\ if time to go to next sprite state,
			BEQ CODE_03944A		;/ branch
			LDA #$20		; else, load y speed into accumulator
			BRA CODE_039475

CODE_03944A:
			LDA #$30		; set time until next sprite state change
			BRA SetTimerNextState

CODE_03944E:
			LDA !1540,x		;\ if not time to go to next sprite state,
			BNE Return1		;/ return
			LDA #$18		; else, load time until next sprite state change
			BRA SetTimerNextState			; return

CODE_039458:
			LDA !1540,x		;\ if time to go to next sprite state,
			BEQ CODE_039463		;/ branch
			LDA #$F0		; else, load y speed
			JSR CODE_039475
Return1:
			RTS			; return 

CODE_039463:
			LDA #$30		; load time until next sprite state change
SetTimerNextState:
			STA !1540,x		; store to sprite change timer
			INC !RAM_SpriteState,X	; go to next sprite state
			RTS			; return

CODE_03946B:
			LDA !1540,x		;\ if not time to go to next sprite state,
			BNE Return1		;/ return
			LDA #$2F		; else, load time until next sprite state change
			BRA SetTimerNextState
			RTS			; return 

CODE_039475:
			LDY !151C,x		;\ if sprite should start by going up (set in INIT routine by x position),
			BEQ CODE_03947D		;/ branch
			EOR #$FF		;\ else, reverse y speed
			INC A			;/
CODE_03947D:
			STA !RAM_SpriteSpeedY,x	; set y speed
			JSL $01801A
			RTS			; return


DATA_039484:		db $01,$FF

DATA_039486:		db $00,$FF

CODE_039488:
			JSL $01A7DC		;\ if Mario isn't touching sprite,
			BCC Return2		;/ return
			%SubHorzPos()
			LDA $0E			; |
			CLC			; |
			ADC #$04		; |
			CMP #$08		; |
			BCS CODE_03949F		;/ branch
			JSL $00F5B7		; hurt Mario
			RTS			; return

CODE_03949F:
			LDA !RAM_MarioXPos	;\ make Mario unable to walk through sprite
			CLC			; | by setting his x position to right next to it if he tries
			ADC DATA_039484,Y	; |
			STA !RAM_MarioXPos	; |
			LDA !RAM_MarioXPosHi	; |
			ADC DATA_039486,Y	; |
			STA !RAM_MarioXPosHi	; |
			STZ !RAM_MarioSpeedX	;/ as well as resetting his x speed
Return2:
			RTS			; return


WoodSpikeDispY:		db $00,$10,$20,$30,$40,$40,$30,$20
			db $10,$00

WoodSpikeTiles:		db $6A,$6A,$6A,$6A,$4A,$6A,$6A,$6A
			db $6A,$4A

WoodSpikeGfxProp:	db $81,$81,$81,$81,$81,$01,$01,$01
			db $01,$01

WoodSpikeGfx:		%GetDrawInfo()
			STZ $02			;\ Set $02 based on sprite number 
			LDA !Extra_Bits,x	; | 
			AND #$04		; | 
			BEQ CODE_0394DE		; | 
			LDA #$05		; | 
			STA $02			;/ 
CODE_0394DE:
			PHX 			; preserve sprite index
			LDX #$04		; setup loop counter
WoodSpikeGfxLoopSt:
			PHX			; preserve current tile number
			TXA
			CLC
			ADC $02
			TAX
			LDA $00			;\ set x position of tile
			STA !OAM_DispX,y		;/ 
			LDA $01			;\ set y position of tile 
			CLC			; | 
			ADC WoodSpikeDispY,x	; | 
			STA !OAM_DispY,y		;/ 
			LDA WoodSpikeTiles,x	;\ set tile number
			STA !OAM_Tile,y		;/ 
			LDA WoodSpikeGfxProp,x	;\ set tile properties
			STA !OAM_Prop,Y		;/ 
			INY			;\ as we wrote a 16x16 tile to OAM, we must increase the pointer by 4
			INY			; | 
			INY			; | 
			INY			;/ 
			PLX			; retrieve loop counter
			DEX			; decrease loop counter
			BPL WoodSpikeGfxLoopSt	; if still tiles left to draw, go to start of loop
			PLX			; retrieve sprite index
			LDY #$02		; the tiles written were 16x16
			LDA #$04		; we wrote five tiles 
			JSL $01B7B3
			RTS                       ; Return 

