;With this UberASM-Code, you can create unique password systems
;No credit needed (I appreciate it though :) ), just don't claim it as your own.
;Version: 1.1
;Made by: Nowieso. 
; SJC added fix to allow for A to be used too

; Skip this next section and enter your code below it

;--------------------------------------------------------------------------------
;Don't touch these.
;Format: byetUDLR
;--------------------------------------------------------------------------------
!button_ab 		= $80			;10000000		
!button_xy 		= $40			;01000000		
!button_select	= $20			;00100000		
;!button_start 	= $10			;00010000		
!button_up 		= $08			;00001000		U
!button_down 	= $04			;00000100		D
!button_left 	= $02			;00000010		L
!button_right 	= $01			;00000001		R
!ow_wrp_pos_end = 8		;overworld warp positions always end with 8 (?)
!amountTotalInputs = EndTable-InputTable

;----------------------------------------------------------------------------------

;Define your inputs in the table below.
;The inputs need to be done in the correct order.
;If the player made one wrong input, he has to start with the first input again.
;These are the buttons you can use for the password.
; !button_ab			If a OR b is pressed
; !button_xy     		If x OR y is pressed
; !button_select		If select is pressed
; !button_up			If up is pressed
; !button_down		 	If down is pressed
; !button_left		    If left is pressed
; !button_right		 	If right is pressed

;Define your inputs in this table. Feel free to add or remove inputs. 
InputTable:
db !button_ab,!button_ab,!button_ab,!button_up ; AorB,AorB,AorB,Up
EndTable:
;----------------------------------------------------------------------------------
;What should happen when the password-inputs are correct? Change the define (!choice) below.
; 1 = Kill the player
; 2 = Hurt the player
; 3 = Give the player 1-UP(s)
; 4 = Give the player a Power-UP
; 5 = Give the player some coins
; 6 = Give the player Star-Power
; 7 = End the level (normal exit)
; 8 = End the level (secret exit), triggers the keyhole animation
; 9 = Spawn a sprite
;10 = Change ON/OFF Switch state
;11 = Activate P-Switch
;12 = Teleport to current screen exit
;13 = Teleport the player to the overworld, no event triggered
;14 = Teleport the player to a different overworld position
;15 = Custom, write your own code
!choice = 10
;--------------------------------------------------------------------------------
;choice specific settings
;--------------------------------------------------------------------------------
;for !choice = 3
!amountLives = $01	   				;How many 1-UPs the player gets 
!1upSFX = $05						;1-UP SFX
!1upSFXBank = $1DFC					;1-UP SFX Bank
;for !choice = 4
!powerupType = $01   				;00=small Mario, 01=big Mario, 02=cape Mario, 03=fire Mario
;for !choice = 5
!amountCoins = #10  				;Amount of coins the player will get
;for !choice = 6
!starLength = $FF	  				;Amount of frames the player has star-power
!starMusic = $0D					;star music
!starMusicBank = $1DFB				;star music bank
;for !choice = 7
!lvlbeatenMusic = $0C				;level-beaten-music
!lvlbeatenMusicBank = $1DFB			;level-beaten-music Bank
;for !choice = 8
!keyholeSFX = $0F					;keyhole SFX
!keyholeSFXBank = $1DFB				;keyhole SFX Bank
;for !choice = 9
!spriteType = 0						;0 = normal sprite, 1 = custom sprite
!normalSpriteNumber = $80			;normal sprite number you want to spawn, default: key
!customSpriteNumber = $00			;custom sprite number you want to spawn
!X_distance = $30					;x distance between Mario and the position where the sprite spawns
!Y_distance = $00					;y distance between Mario and the position where the sprite spawns
!X_direction = 0					;0 = spawn sprite to the right of Mario, 1 = to the left
!Y_direction = 0					;0 = spawn sprite above Mario, 1 = below Mario
!spriteSpawnSFX = $10				;SFX to play, default: Kamek
!spriteSpawnSFXBank = $1DF9			;SFX bank
;for !choice = 10
!OnOFFSFX = $0B						;SFX to play
!OnOFFSFXBank = $1DF9				;SFX bank
;for !choice = 11
!switchType = 1		 				;0 = Blue Switch, 1 = Silver Switch, 2 = both
!PSwitchLength = $FF				;How long the P-Switch stays active
!PswitchMusic = $0E					;music that plays, you will have to change this if using custom music
!PswitchMusicBank = $1DFB			;music bank
;for !choice = 14
;if you are in layer 1 editing mode on the Main Overworld-Map, the X and Y values will be displayed in the bottom left corner of Lunar Magic
;if you are on a submap, you have to count the 16x16 tiles yourself, default: Yoshi's House
!ow_x_pos = 06						;Overworld X Position to warp Mario to
!ow_y_pos = 07						;Overworld Y Position to warp Mario to
!ow_warp_submap = $01				;$00 = Main map; $01 = Yoshi's Island; $02 = Vanilla Dome; $03 = Forest of Illusion; $04 = Valley of Bowser; $05 = Special World; $06 = Star World
;for !choice == 15
	cstm_code:
	;add your own code here:

	;do not use an RTL, the following line does that for you. It also handles what happens after the code was triggered, so DO NOT remove it
	JML finish
;--------------------------------------------------------------------------------
;general settings
;--------------------------------------------------------------------------------
!actionSFX = $29		  			;SFX to play when the password is correct
!actionSFXBank	 = $1DFC			;SFX Bank	
!screenNumberOnly = 0				;0 = the password can be used in the entire level, 1 = the password can only be used in a certain screen
!screenNumber = $00					;screen number where the player can use the password, if !screenNumberOnly = 1
!disableAfterUse = 0				;0 = password can be used infinitely, 1 = disable password after first use

!freeRAM = $0E55
;----------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
;START OF THE ACTUAL CODE
;-----------------------------------------------------------------------------------
init:
STZ !freeRAM
RTL
main:
if !screenNumberOnly == 1
	LDA $95
	CMP #!screenNumber
	BEQ +
	RTL
	+
endif
	LDA !freeRAM
	CMP.b #!amountTotalInputs+1
	BNE + 					;branch if A > !amountTotalInputs
	RTL
	+
	LDX !freeRAM
	CPX.b #!amountTotalInputs
	BEQ action
	LDA $18 ; SJC added three
    AND #$80 ;
    TSB $16 ;
	LDA $16
	BNE +					;if any button is pressed, branch
	RTL
	+
	LDA $16 
	BIT InputTable,x
	
	BNE + 					;branches if correct button is pressed
	STZ !freeRAM			;else, reset the inputs
	RTL
	+
	INC !freeRAM
	RTL
;-----------------------------------------------------------------------------------
;ACTION: What will be triggered if the inputs were done correctly, based on !choice
;-----------------------------------------------------------------------------------
action:
	LDA #!actionSFX
	STA !actionSFXBank|!addr
	if !choice == 1
		JSL $00F606					;kill player
	elseif !choice == 2
		JSL $00F5B7					;hurt player
	elseif !choice == 3
		LDA #!1upSFX
		STA !1upSFXBank|!addr 
		LDA $0DBE|!addr				;load lives
		CLC
		ADC #!amountLives
		STA $0DBE|!addr
	elseif !choice == 4
		LDA #!powerupType
		STA $19
	elseif !choice == 5
		LDA !amountCoins
		JSL $05B329
	elseif !choice == 6
		LDA #!starMusic				;star music
		STA !starMusicBank|!addr
		LDA #!starLength
		STA $1490|!addr
	elseif !choice == 7
		LDA #!lvlbeatenMusic		;level-beaten-music
		STA !lvlbeatenMusicBank|!addr
		LDA #$FF
		STA $1493|!addr
	elseif !choice == 8
		REP #$20				
		LDA $1A					
		CLC						
		ADC #$007C
		STA $1436|!addr			
		LDA $1C					
		CLC	
		ADC #$00A0
		STA $1438|!addr
		SEP #$20	
		LDA #!keyholeSFX
		STA !keyholeSFXBank|!addr		
		LDA #$30				
		STA $1434|!addr	
	elseif !choice == 9
		LDA #!spriteSpawnSFX		;kamek SFX
		STA !spriteSpawnSFXBank|!addr
		if !spriteType == 0
			;Normal Sprite
			LDA !186C,x				;Sprite off screen flag table, vertical
			BNE EndSpawn
			JSL $02A9DE				;Routine to search for free spite slot within the standard sprite slot region
			BMI EndSpawn
			LDA #$01
			STA !14C8,y				;Sprite status table: #$01 = Initial phase of sprite.
			LDA #!normalSpriteNumber
			STA !9E,y				;Sprite number, or Acts Like setting for custom sprites
			LDA $94					;Mario's X pos high
			if !X_direction == 0
				CLC					;CLC and ADC for Right
				ADC #!X_distance
			else
				SEC							
				SBC #!X_distance	;SEC and SBC for Left
			endif
			STA !E4,y				;Sprite X high
			LDA $95					;Mario's X pos low
			STA !14E0,y				;Sprite X low
			LDA $96					;Mario's Y pos high
			if !Y_direction == 0
				SEC					;SEC and SBC for Up
				SBC #!Y_distance
			else
				CLC					;CLC and ADC for Down
				ADC #!Y_distance	
			endif
			STA !D8,y				;Sprite Y high
			LDA $97					;Mario's Y pos low
			STA !14D4,y				;Sprite Y low
			PHX
			TYX
			JSL $07F7D2				;Resets most sprite tables and loads new values for some of them depending on the sprite number
			PLX
			EndSpawn:
		else
			;Custom Sprite
			LDA !186C,x
			BNE EndSpawn
			JSL $02A9DE
			BMI EndSpawn
			LDA #$01				;Sprite state
			STA !14C8,y
			PHX
			TYX
			LDA #!customSpriteNumber;This the sprite number to spawn.
			STA !7FAB9E,x
			PLX
			LDA $94					;Mario's X pos high
			if !X_direction == 0
				CLC					;CLC and ADC for Right
				ADC #!X_distance	
			else 
				SEC					;SEC and SBC for Left
				SBC #!X_distance
			endif
			STA !E4,y				;Sprite X high
			LDA $95					;Mario's X pos low
			STA !14E0,y				;Sprite X low
			LDA $96					;Mario's Y pos high
			if !Y_direction == 1
				CLC					;CLC and ADC for Down
				ADC #!Y_distance		
			else
				SEC					;SEC and SBC for Up
				SBC #!Y_distance
			endif
			STA !D8,y				;Sprite Y high
			LDA $97					;Mario's Y pos low
			STA !14D4,y				;Sprite Y low
			PHX
			TYX
			JSL $07F7D2
			JSL $0187A7
			LDA #$08
			STA !7FAB10,x
			PLX
			EndSpawn:
		endif
	elseif !choice == 10
		LDA #!OnOFFSFX
		STA !OnOFFSFXBank|!addr
		LDA $14AF|!addr
		EOR #$01
		STA $14AF|!addr
	elseif !choice == 11
		LDA #!PswitchMusic
		STA !PswitchMusicBank|!addr
		if !switchType == 0
			LDA #!PSwitchLength
			STA $14AD|!addr 				;blue switch timer
		elseif !switchType == 1
			LDA #!PSwitchLength
			STA $14AE|!addr 				;silver switch timer
			JSL $02B9BD
		elseif !switchType == 2
			LDA #!PSwitchLength
			STA $14AD|!addr 				;blue switch timer
			STA $14AE|!addr 				;silver switch timer
			JSL $02B9BD
		endif
	elseif !choice == 12
		LDA #$06
		STA $71
		STZ $89
		STZ $88
	elseif !choice == 13
		LDA #$0B							;gamemode $0B, leave level without beating it
		STA $0100|!addr
	elseif !choice == 14
		LDA #$0B							;gamemode $0B, leave level without beating it
		STA $0100|!addr
		REP #$20
		LDX $0DD6|!addr
		LDA #$0!ow_x_pos!ow_wrp_pos_end
		STA $1F17|!addr,x
		LSR #4
		STA $1F1F|!addr,x
		LDA #$0!ow_y_pos!ow_wrp_pos_end
		STA $1F19|!addr,x
		LSR #4
		STA $1F21|!addr,x
		SEP #$20
		LDA #!ow_warp_submap
		STA $1F11|!addr,x
	elseif !choice == 15
		JMP cstm_code
	endif
		finish:
;DISABLE AFTER USE?-----------------------------------------------------
	if !disableAfterUse == 1
		INC !freeRAM						;set !freeRAM to a value that will never be checked
	else
		STZ !freeRAM
	endif
	RTL