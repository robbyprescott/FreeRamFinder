;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Press R to switch between characters
; By Noobish Noobsicle, modification by Meirdent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CoinStore = 0			;Whether to store separate coins for Mario and Luigi
				;(0 = Disabled, 1 = Enabled)

!PowerupStore = 2		;Whether to store separate powerups for Mario and Luigi
				;(0 = Disabled, 1 = Enabled, 2 = Enabled but clear on death)

init:
    STZ $0DA0 ; both controllers
	RTL
	
main:
	STZ $1401|!addr			;disable L/R scrolling

	LDA $18				;check if controller button is newly pressed..
	AND #$10			;R button
	BEQ Return			;

	LDX $0DB3|!addr			;current player
	if !CoinStore
		LDA $0DBF|!addr		;load current coin count
		STA $0DB6|!addr,x	;store to individual player coin count
	endif
	if !PowerupStore
		LDA $19			;load current powerup
		STA $0DB8|!addr,x	;store to individual player powerup
	endif

	TXA
	BEQ ToLuigi			;if current player is Mario, switch to Luigi
    
	STZ $0DB3|!addr			;set player to Mario

	LDA #$30			;reset Mario's name on the status bar
	STA $0EF9|!addr			;
	LDA #$31			;
	STA $0EFA|!addr			;
	LDA #$32			;
	STA $0EFB|!addr			;
	LDA #$33			;
	STA $0EFC|!addr			;
	LDA #$34			;
	STA $0EFD|!addr			;

	BRA Store

ToLuigi:
	INC $0DB3|!addr			;set player to Luigi

Store:
	LDX $0DB3|!addr
	if !CoinStore
		LDA $0DB6|!addr,x	;load individual player coin count
		STA $0DBF|!addr		;store to current coin count
	endif
	if !PowerupStore
		LDA $0DB8|!addr,x	;load individual player powerup
		STA $19			;store to current powerup
	endif

Return:
	if !PowerupStore == 2
		LDA $71			;check if player is..
		CMP #$09		;dying
		BNE +			;

		STZ $0DB8|!addr		;remove Mario's powerup
		STZ $0DB9|!addr		;remove Luigi's powerup
	+
	endif

	RTL