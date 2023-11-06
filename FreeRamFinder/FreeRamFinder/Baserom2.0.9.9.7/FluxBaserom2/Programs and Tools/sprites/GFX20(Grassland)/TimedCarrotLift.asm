;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Timed Carrot lift platform 
;; by Abdu
;; 
;; Extra Bit:
;; Not set 	= up right platform
;; Set 		= up left platform
;;
;; Extra Byte 1: timer for the platform 
;; 00 = 0 seconds
;; 01 = 1 second
;; 02 = 2 seconds
;; 03 = 3 seconds 
;; 04 = 4 seconds 
;; 05 = 5 seconds 
;; 06 = 6 seconds 
;; 07 = 7 seconds 
;; 08 = 8 seconds 
;; 09 = 9 seconds 
;;
;; Extra Byte 2:
;; 00 = Goes up.
;; Anything else goes down.
;; 
;; In a future update I will add a functionality which allows you to slide on these platforms
;; (Actually got it to work but it felt janky so I removed it from here.)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;=======Misc sprite tables defines=======
!ExtraBits 		= $04
!MovementTimer 	= !1540
!PlatformType 	= !1528 	; 0 up-right platform, anything else up-left.
!PreviousXPos	= !151C 	; used to see if the player is on the platform.
!Timer			= !1570
!TimerHigh		= !1534		; high byte for timer timer
!Touched		= !1504		; Flag set when the platform is touched
!Direction		= !extra_byte_2
!State			= !1504
;=======================================

;=======Changeable values defines=======
!SlideYSpeed	= $40

; Platform Tiles
!Top			= $E4
!Middle			= $E2
!Bottom			= $E0
; Number tiles
!One			= $B6
!Two			= $B5
!Three			= $B4
!Four			= $B3
!Five			= $A7
!Six			= $A6
!Seven			= $A5
!Eight			= $A4
!Nine			= $A3
;=======================================

TimeTableLow:
	;  x00, x01, x02, x03, x04, x05, x06, x07, x08, x09 
	db $00, $3F, $7F, $BF, $FF, $3F, $7F, $BF, $FF, $3F
TimeTableHigh: 
	;  x00, x01, x02, x03, x04, x05, x06, x07, x08, x09 
	db $00, $00, $00, $00, $00, $01, $01, $01, $01, $02

print "INIT ",pc
	LDA !7FAB10,x
	AND #!ExtraBits
	STA !PlatformType,x	
	PHB : PHK : PLB
	LDA !extra_byte_1,x
	TAY
	LDA TimeTableLow,y
	STA !Timer,x
	LDA TimeTableHigh,y
	STA !TimerHigh,x
	PLB
RTL


print "MAIN ",pc
	PHB : PHK : PLB
	JSR TimedCarrotTopLift
	PLB
RTL

InteractionYPos: 							; Interaction Y positions for the Carrot Top Lift at each X position. This effctively defines the shape of the platform.
	db $20, $20, $20, $20, $20, $20, $20, $20		; Up-Right platform
	db $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $1F, $1E, $1D, $1C, $1B, $1A, $19
	db $18, $17, $16, $15, $14, $13, $12, $11
	db $10, $0F, $0E, $0D, $0C, $0B, $0A, $09
	db $08, $07, $06, $05, $04, $03, $02, $01
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	
	db $00, $00, $00, $00, $00, $00, $00, $00		; Up-Left platform
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $02, $03, $04, $05, $06, $07, $08
	db $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
	db $11, $12, $13, $14, $15, $16, $17, $18
	db $19, $1A, $1B, $1C, $1D, $1E, $1F, $20
	db $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20



YSpeed:
	db $F8, $08		; up, down

XSpeed:
	db $08, $F8		; right, left

TimedCarrotTopLift:
	JSR Graphics
	LDA $9D				; Return if game frozen.
	BEQ +
	RTS
	+
	%SubOffScreen()

	LDA !Touched,x		;\ Sprite not touched yet so no falling code should be ran.
	BEQ .notFalling		;/
	LDA !Timer,x		;\ Timer ran out
	BEQ .skip1			;/ so just fall down
	JSL $01801A|!BankB	; update Y position
	DEC !Timer,x		; Decrease timer
	
	LDY #$00				;\
	LDA !extra_byte_2,x		;|
	BEQ +					;|
	INY						;|
	+						;|
	LDA YSpeed,y			;| Y speed dependant on extra byte 2.
	STA !AA,x				;/
	
	LDA !PlatformType,x	;\  
	BEQ +				;|
	INY					;|
	TYA					;|
	AND #$01			;| X speed gets set based on extra bit
	TAY					;| 
	+					;|
	LDA XSpeed,y		;| 
	STA !B6,x			;/

	.skip1
	LDA !Timer,x			;\ see if timer is done
	BNE  .notFalling		;| if not dont fall yet
	LDA !TimerHigh,x		;| if high byte is 0 
	BEQ .fall				;/ then fall.
	
	; still couple more seconds left.
	DEC !TimerHigh,x		; decrease high byte timer.
	LDA #$FF 				;\ set it to be the max time possible
	STA !Timer,x			;/ I want to you to think about how this makes sense when you look at the low time table.

	.fall
	JSL $01802A|!BankB   
	
	.notFalling
	LDA !E4,x					;\ Preserve old X position, for moving Mario with the platform.
	STA !PreviousXPos,x			;/
	JSL $018022|!BankB			; Update X position.

	JSR GetClipping				;\ 
	JSL $03B69F|!BankB			;|
	JSL $03B72B|!BankB			;| Return if not in contact with the platform, or Mario is moving upwards.
	BCC .Ret					;|
	LDA $7D						;|
	BMI .Ret					;/
	
	LDA $94						;\ 
	SEC							;|
	SBC !PreviousXPos,x			;|
	CLC							;|
	ADC #$1C					;|
	LDY !PlatformType,x			;| Get the index to the to the Y pos table based on the X position.
	BEQ .skip					;| up-right platform so no need to index the second portion of the table.
	CLC							;|
	ADC #$38					;| so if its an up-left platform add #$38 to index the second portion.
	.skip						;|
	TAY							;/

	LDA $187A|!Base2			;\ 
	CMP #$01					;|
	LDA #$20					;|
	BCC .notOnYoshi				;| Get lower interaction point for Mario's Y position, accounting for whether he's on Yoshi or not.
	LDA #$30					;|  This point determines whether or not Mario is on top of the platform.
	.notOnYoshi					;|
	CLC							;|
	ADC $96						;|
	STA $00						;/

	LDA !D8,x					;\ 
	CLC							;|
	ADC InteractionYPos,y		;| If player is not touching the sprite at the current X position
	CMP $00						;|
	BPL .Ret					;/ the return.

	LDA $187A|!Base2			;\ 
	CMP #$01					;|
	LDA #$1D					;| Get upper interaction point for Mario's Y position, accounting for whether he's on Yoshi or not.
	BCC .noYoshiOnSpr			;|  This point indicates where Mario's feet are relative to his position.
	LDA #$2D					;|
	.noYoshiOnSpr				;|
	STA $00						;/

	LDA !D8,x					;\ 
	CLC							;|
	ADC InteractionYPos,y		;|
	PHP							;|
	SEC							;|
	SBC $00						;| Move Mario on top of the platform.
	STA $96						;|
	LDA !14D4,x					;|
	SBC #$00					;|
	PLP							;|
	ADC #$00					;|
	STA $97						;/
	STZ $7D						;| Clear Mario's Y speed.
	
	LDA #$01					;\ On Sprite flag is set.
	STA $1471|!Base2			;/
	STA !Touched,x
	

	LDY #$00					;\ 
	LDA $1491|!Base2			;|
	BPL .movePlayer				;|
	DEY							;|
	.movePlayer					;|
	CLC							;| Move player horizontally with the platform.
	ADC $94						;|
	STA $94						;|
	TYA							;|
	ADC $95						;|
	STA $95						;/	

	.Ret
RTS

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine that sets up some scratch RAM to get 
; Mario's clipping data for Carrot Top platform.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetClipping:
	LDA $94						;\ 
	CLC							;|
	ADC #$04					;|
	STA $00						;| Get clipping X position.
	LDA $95						;|
	ADC #$00					;|
	STA $08						;/

	LDA #$08					;\ 
	STA $02						;| Get interaction area as an 8x8 square.
	STA $03						;/

	LDA #$20
	LDY $187A|!Base2
	BEQ .notOnYoshi
	LDA #$30
	
	.notOnYoshi
	CLC							;\ 
	ADC $96						;|
	STA $01						;|Get clipping Y position.
	LDA $97						;|
	ADC #$00					;|
	STA $09						;/
RTS


!NumXDisp1	= $12
!NumXDisp2	= $06					; Y disp for number tile.
!NumYDisp	= $10					; Y disp for number tile.

DiagPlatDispX:						; X offsets for each tile of the Carrot Top platform.
	db $10, $00, $10				; Up-Right
	db $00, $10, $00				; Up-Left

DiagPlatDispY:						; Y offsets for each tile of the Carrot Top platform.
	db $00, $10, $10				; Up-Right
	db $00, $10, $10				; Up-Left

DiagPlatTiles:						; Tile numbers for each tile of the Carrot Top platform.
	db !Top, !Bottom, !Middle		; Up-Right
	db !Top, !Bottom, !Middle		; Up-Left

DiagPlatGfxProp:					; YXPPCCCT for each tile of the Carrot Top platform.
	db $00, $00, $00				; Up-Right
	db $40, $40, $40				; Up-Left

DiagTileSizes:
	db $02, $02, $02
	db $02, $02, $02

Times:
	db !One, !Two, !Three, !Four
	db !Five, !Six, !Seven, !Eight
	db !Nine

Graphics:
	%GetDrawInfo()

	
	LDA !PlatformType,x
	STA $04

	LDA #$02					;\ Number of tiles to draw-1
	STA $05						;/

	LDA !15F6,x
	ORA $64
	STA $06

	LDA !TimerHigh,x			;\
	BNE .drawNum				;|
	LDA !Timer,x				;| check if platform time is about to run out
	CMP #$08					;|
	BCC .noNum					;/ not yet so branch.
	.drawNum
	INC $05						; increase number of tiles to draw-1

	LDA !TimerHigh,x
	XBA
	LDA !Timer,x
	; PHX
	REP #$20
	LSR #6
	SEP #$20
	TAX
	LDA Times,x					;\ Store tile.
	STA $0302|!Base2,y			;/


	LDA #!NumXDisp1				;\ 
	LDX $04 					;|
	CPX	#$00					;|
	BEQ +						;| X displacement of the number tile based on the type of platform.
	LDA #!NumXDisp2				;| (p.s probably can be done better but eh)
	+							;|
	CLC							;|
	ADC $00						;|
	STA $0300|!Base2,y			;/

	LDA $01						;\ Get sprite Y pos
	CLC							;|
	ADC #!NumYDisp				;| Add Y displacement
	STA $0301|!Base2,y			;/
	
	LDA $06
	STA $0303|!Base2,y

	PHY							;\ 
	TYA							;|
	LSR #2						;|
	TAY							;| Manually set the tile size.
	LDA #$00					;| 8x8 for number tile.
	STA $0460|!Base2,y			;|
	PLY							;/

	INY #4

	.noNum		
	LDA $04						;\ Platform type.
	CMP #$01					;|
	LDX #$02					;| Get index to the above tables, based on which platform this is.
	STX $02						;|
	BCC +						;|
	LDX #$05					;/
	+
	.loop
	LDA $00						;\ Get sprite X pos
	CLC							;| 
	ADC DiagPlatDispX,x			;| Add X displacement
	STA $0300|!Base2,y			;/

	LDA $01						;\ Get sprite Y pos
	CLC							;|
	ADC DiagPlatDispY,x			;| Add Y displacement
	STA $0301|!Base2,y			;/

	LDA DiagPlatTiles,x			; Get carrot lift tile number.
	STA $0302|!Base2,y

	LDA DiagPlatGfxProp,x		;\ Store tile properties
	ORA $06						;|
	STA $0303|!Base2,y			;/

	PHY							;\ 
	TYA							;|
	LSR #2						;|
	TAY							;| Manually set the tile size.
	LDA DiagTileSizes,x			;|
	STA $0460|!Base2,y			;|
	PLY							;/

	INY #4					 
	DEX							;\ Decrease number of tiles to draw					
	DEC $02						;|
	BPL .loop					;/ not done yet so loop.

	LDX $15E9|!addr				; Get sprite index back
	LDA $05						; Number of tiles-1 in A.
	LDY #$FF					; 16x16 tiles
	JSL $01B7B3|!BankB
RTS
