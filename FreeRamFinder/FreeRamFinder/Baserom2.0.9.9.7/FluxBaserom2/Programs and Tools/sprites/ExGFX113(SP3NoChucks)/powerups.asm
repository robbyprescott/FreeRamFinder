;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hammer and boomerang Powerup Sprite, by ICB. Based on code by Lucario.
;; Converted by RussianMan.
;; 
;; When this sprite is collected, Mario gains ability of throwing custom projectiles!
;;
;; Extra Property byte determies which sprite tile,
;; as well as "powerup state" (in other words which sprite you can shoot).
;;
;; Extra property byte 2 determines it's behavor.
;; Bit 0 - Flip like flower
;; This'll make sprite flip it's tile like fire flower does
;;
;; To use power-ups propertly, UberASM must be inserted!
;; If it's not in gamemode, it should be enabled in levels with this sprite!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tiles:
db $6D,$67,$26,$26,$41		;if Extra prop is 1, it'll use tile 1 and etc.
; default 6D is hammer (SP3). 80 is boomerang. 26 may be SP1 flower. 89 is SP3/4 flower

ItemBox:			;item box contents for each player powerup that'll be reserved after picking this (Vanilla power-ups!)
db $00,$01,$04,$02

;CustomItems:
;db $05,$06,$07,$08

!Animation = $04		;animation to display when picked up.
!AnimationTime = $20		;how long animation plays

!FreeRam = $0DC4|!Base2		;Must be the same as in UberASM! 

!PickPowerupSound = $0A
!PickPowerupBank = $1DF9|!Base2
!PickPowerItemBoxSnd = $0B
!PickPowerItemBoxBnk = $1DFC|!Base2

Print "INIT ",pc
LDA !extra_prop_1,x		;less space used when storing and using shorter adress
STA !C2,x			;
RTL

Print "MAIN ",pc			
PHB
PHK				
PLB				
JSR SPRITE_ROUTINE	
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_ROUTINE:
		LDA !extra_prop_2,x	;if it should flip like fire flower, flip like fire flower
		AND #$01		;
		;LSR
		BEQ .Noflips		;

		LDA $14			;turn left-right
		AND #$08		;
		LSR #3			;
		STA !157C,x		;

;code for blink-falling supposed to be used with Item Box Special, but I can't get it to work. I'll leave this commented for now.

.Noflips
		LDA !1534,x		;check if it's blink-falling
		BEQ .NoBlinkFall	;

		LDA $14			;show GFX
		AND #$0C		;every 13 frames
		BEQ .NoGFX		;

		JSR SUB_GFX		;

.NoGFX
		LDA $9D			;
		BNE .RETURN		;

		LDA #$10		;
		STA !AA,x		;
		JSL $01801A|!BankB	;
		BRA .customInteraction	;interact with the player ofc
		;RTS			;

.NoBlinkFall
		;Compatibility with custom ?-block, raise out of block

		LDA !1540,x		;check if it's rising out of block
		BEQ .GFX		;
		CMP #$36		;
		BCS .RETURN		;

		LDA $64			;Yes, I copy-pasted my another power-up disassembly's code
		PHA			;because power-ups share same code

		LDA #$10		;
		STA $64			;
		JSR SUB_GFX		;

		PLA			;
		STA $64			;

		LDA $9D			;
		BNE .RETURN		;

		LDA #$FC		;
		STA !AA,x		;
		JSL $01801A|!BankB	;
.RETURN
		RTS

.GFX
		JSR SUB_GFX		;aesthetics

		LDA !14C8,x             ;return if sprite status != 8
                EOR #$08		;or
		ORA $9D			;return if sprites locked
                BNE .RETURN		;
                %SubOffScreen()         ;and off screen of course obviously  

		LDA !1588,x		;check if on floor
		AND #$04		;
		BEQ .noground		;
		STZ !AA,x		;it obviously shouldn't have Y speed.

.noground
		JSL $01802A|!BankB	;gravity

		;LDA $187A|!Base2	;remnant of first release	
		;BNE .RETURN		;since powers are handled in uberasm, we don't need to check yoshi here anymore

.customInteraction
		JSL $01A7DC|!BankB	;contact with Mario, blah blah blah
		BCC .RETURN	

		LDA #$04		;
		LDY !1534,x		;If it blink-falls (as if you dropped it from itembox)
		BNE .NoScore		;
		JSL $02ACE5|!BankB	;

.NoScore
		LDA !FreeRam		;
		BEQ .Nocustompower	;not custom power
		STA !FreeRam+2		;
		DEC			;

		LDY #!PickPowerItemBoxSnd
		STY !PickPowerItemBoxBnk

		STZ $0DC2|!Base2	;remove normal reserve item

		CMP !C2,x		;is power we currently have is the same as what this power-up would give?
		BEQ +			;if yes, don't play animation
		BRA .AnimationOnly	;

.Nocustompower
        	LDY $19             	;\Put Mario's power-up in item box.
        	BEQ .AnimationOnly	;|
        	LDA ItemBox,y		;|
		STA $0DC2|!Base2	;/

		LDA #!PickPowerItemBoxSnd
		STA !PickPowerItemBoxBnk

.AnimationOnly
		LDA #!Animation		;setup animation
		STA $71			;

		LDA #!AnimationTime	;timer for flower animation
		STA $149B|!Base2	;

		LDA #$01		;Make Mario just big
		STA $19			;
		;STA !FreeRam		;enable shooting ability
		STA $9D			;and freeze. Not permanently, don't worry!

+
		LDA #!PickPowerupSound	;sound effect	
		STA !PickPowerupBank	;

		STZ !14C8,x		;RIP this sprite 2008-2020

		LDA !C2,x		;enable power depending on extra prop.
		INC			;
		STA !FreeRam		;
		RTS			;done

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:        %GetDrawInfo()

;      $00 = sprite x position relative to screen border 
;      $01 = sprite y position relative to screen border
;      just in case you're interested what they are


		LDA $00                 ; set x position of the tile
		STA $0300|!Base2,y	;

		LDA $01                 ; set y position of the tile
		STA $0301|!Base2,y	;

		LDA !C2,x		;
		TAX			;
		LDA Tiles,x		;
 		STA $0302|!Base2,y	;

		LDX $15E9|!Base2	; restore sprite's original index

		LDA !157C,x		;
		LSR			;
		LDA #$00		;
		BCS .NoFlip		;
		ORA #$40		;

.NoFlip
                ORA !15F6,x             ; get sprite props through CFG file
                ORA $64                 ; add in the priority bits from the level settings
                STA $0303|!Base2,y      ; set properties
                    
                LDY #$02                ; #$02 means the tiles are 16x16
                LDA #$00                ; This means we drew one tile
                JSL $01B7B3|!BankB	;
                RTS			;