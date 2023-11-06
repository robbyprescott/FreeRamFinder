; Minor edit by SJC to not use 2nd GFX page

; Line 166, mess around with LDA $16				
;		                  AND #$80
;                         If add LDA $18, can spin-jump out of cloud

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Lakitu cloud (sprite 87), by mellonpizza
;;
;; This is a disassembly of sprite 87 in SMW, the Lakitu cloud without a time limit.
;;
;; Uses first extra bit: NO
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SmileyFace = $DD ; Item box empty space. vanilla $4D (GFX02). BA is also empty on GFX02 
!SmileyYXPPCCCT = $38 ; 39, 2nd graphics page


print "INIT ",pc
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
		PHB
		PHK
		PLB
		JSR LakituCloud
		PLB
		RTL                       ; Return

DATA_01E76F:
	db $FC,$04,$FE,$02,$FB,$05,$FD,$03
	db $FA,$06,$FC,$04,$FB,$05,$FD,$03
DATA_01E77F:
	db $00,$FF,$03,$04,$FF,$FE,$04,$03
	db $FE,$FF,$03,$03,$FF,$00,$03,$03
	db $F8,$FC,$00,$04

DATA_01E793:
	db $0E,$0F,$10,$11,$12,$11,$10,$0F
	db $1A,$1B,$1C,$1D,$1E,$1D,$1C,$1B
	db $1A

LakituCloud:
		LDA $9D				; \ Branch if sprites locked
		BEQ NoCloudGfx		; /
BraToJmpGfx:
		JMP LakituCloudGfx

NoCloudGfx:
		LDA $14				; \ Decrement every 4th frame
		AND #$03			; |
		BNE +				; /
		LDA $18E0|!Base2		; \ Don't decrement if 0
		BEQ +				; /
		DEC $18E0|!Base2		; \ Store value to timer if $18E0 reached 0
		BNE +				; |
		LDA #$1F			; |
		STA !1540,x			; |
		+				; /
		LDA !1540,x			; \ Go to correct place based on timer
		BEQ NoPuffAway			; |
		DEC A				; |
		BNE BraToJmpGfx			; |
		STZ !14C8,x			; /
		LDA #$FF			; \ Set time until respawn
		STA $18C0|!Base2		; |
		LDA #$1E			; | Sprite to respawn = Lakitu
		STA $18C1|!Base2		; /
		RTS                       ; Return

NoPuffAway:
		LDY #$09			; \ Test to see if lakitu exists.
		-				; |
		LDA !14C8,y			; |
		CMP #$08			; |
		BNE +				; |
		LDA.w !9E,y			; |
		CMP #$1E			; |
		BNE +				; |
		TYA				; | If he does, store to $160E,x and jump.
		STA !160E,x			; |
		JMP LakituExists		; |
		+				; |
		DEY				; |
		BPL -				; /
		LDA !C2,x			; \ Branch if Mario controls the cloud.
		BNE MarioInCloud		; /
		LDA !151C,x			; \ Update speed if timer set
		BEQ .nospeed			; |
		JSL $018022|!BankB		; |
		JSL $01801A|!BankB		; |
.nospeed					; /
		LDA !154C,x			; \ If set to no player interaction, go to GFX.
		BNE +				; /
		JSL $01A7DC|!BankB		; \ Skip if no collision
		BCC +				; /
		LDA $7D				; \ No collision if mario going up
		BMI +				; /
		INC !C2,x			; > Set state to 01
		LDA #$11			; \ Set Y position of cloud relative to Mario
		LDY $187A|!Base2		; |
		BEQ .noyoshi			; |
		LDA #$22			; |
.noyoshi					; |
		CLC				; |
		ADC $D3				; |
		STA !D8,x			; |
		LDA $D4				; |
		ADC #$00			; |
		STA !14D4,x			; /
		LDA $D1				; \ X position
		STA !E4,x			; |
		LDA $D2				; |
		STA !14E0,x			; /
		LDA #$10			; \ Yspeed
		STA !AA,x			; |
		STA !151C,x			; / timer to update speed
		LDA $7B				; \ Xspeed from player xspeed
		STA !B6,x			; /
		+
		JMP LakituCloudGfx

MarioInCloud:
		JSR LakituCloudGfx		; > GFX
		PHB				; \ Set bank
		LDA.b #$02|(!BankB>>16)		; |
		PHA				; |
		PLB				; /
		JSL $02D214|!BankB		; > Movement/control in cloud
		PLB				; > Restore bank
		LDA !AA,x			; \ Sprite Yspeed + 3 = player yspeed
		CLC				; |
		ADC #$03			; |
		STA $7D				; /
		LDA $14				; \ Use timer as index
		LSR #3				; |
		AND #$07			; |
		TAY				; |
		LDA $187A|!Base2		; |
		BEQ +				; |
		TYA					; | +8 if on yoshi
		CLC					; |
		ADC #$08			; |
		TAY					; |
		+					; /
		LDA $D1				; \ Set Xpos based on player
		STA !E4,x			; |
		LDA $D2				; |
		STA !14E0,x			; /
		LDA $D3				; \ Yposition fluctuates slightly based
		CLC				; | on time, but is still relative to player.
		ADC DATA_01E793,y		; |
		STA !D8,x			; |
		LDA $D4				; |
		ADC #$00			; |
		STA !14D4,x			; /
		STZ $72				; > Set player on ground
		INC $1471|!Base2		; > Set player on top of solid sprite flag
		INC $18C2|!Base2		; > Set player in lakitu
		LDA $16				; \ Branch, until A is pressed.
		AND #$80			; |
		BEQ Return01E897	; /
		LDA #$C0			; \ Player Yspeed
		STA $7D				; /
		LDA #$10			; \ Disable interaction
		STA !154C,x			; /
		STZ !C2,x			; > State 0
Return01E897:
		RTS				; Return

LakituExists:
		PHY				;
		JSR CODE_01E98D			; > Handle some lakitu stuffs
		LDA $14         		; \ Set lakitu's vertical displacement vs. cloud
		LSR #3          		; |
		AND #$07        	 	; |
		TAY             	 	; |
		LDA DATA_01E793,y		; |
		STA $00				; |
		PLY                 		; /
		LDA !E4,x           ; \ Set lakitu's position
		STA.w !E4,y         ; |
		LDA !14E0,x         ; |
		STA !14E0,y         ; |
		LDA !D8,x           ; |
		SEC                 ; |
		SBC $00             ; |
		STA.w !D8,y         ; |
		LDA !14D4,x         ; |
		SBC #$00            ; |
		STA !14D4,y         ; |
		LDA #$10            ; |
		STA !154C,x         ; /

LakituCloudGfx:
		%GetDrawInfo()
		LDA !186C,x			; \ If offscreen vertically, no drawing.
		BNE Return01E897		; /
		LDA #$F8			;
		STA $0C				;
		LDA #$FC			;
		STA $0D				;
		LDA #$00			;
		LDY !C2,x			;
		BNE +				;
		LDA #$30			;
		+					;
		STA $0E				;
		STA $18B6|!Base2		;
		ORA #$04			;
		STA $0F				;
		LDA $00				; \ GFX x and y to scratch ram
		STA $14B0|!Base2		; |
		LDA $01  	           	; |
		STA $14B2|!Base2          	; /
		LDA $14             		; \ Frame index to $02
		LSR                 		; |
		LSR                 		; |
		AND #$0C            		; |
		STA $02             		; /
		LDA #$03            		; \ Tiles to draw
		STA $03             		; /
		-                   		;
		LDA $03             		; \ Set index of drawn tile
		TAX                 		; /
		LDY $0C,x           		; \ Xpos
		CLC                 		; |
		ADC $02             		; |
		TAX                 		; |
		LDA DATA_01E76F,x   		; |
		CLC                 		; |
		ADC $14B0|!Base2    		; |
		STA $0300|!Base2,y         	; /
		LDA DATA_01E77F,x   		; \ Ypos
		CLC                 		; |
		ADC $14B2|!Base2    		; |
		STA $0301|!Base2,y        	; /
		LDX $15E9|!Base2	        ; X = Sprite index
		LDA #$60            		; \ Cloud tile
		STA $0302|!Base2,y         	; /
		LDA !1540,x         		; \ Cloud tile when dissapearing
		BEQ +               		; |
		LSR #3              		; |
		TAX                 		; |
		LDA CloudTiles,x    		; |
		STA $0302|!Base2,y         	; |
		+                   		; /
		LDA $64             		; \ Property
		STA $0303|!Base2,y         	; /
		INY #4              		; > Increase OAM index
		DEC $03             		; \ Loop until all tiles drawn
		BPL -               		; /
		LDX $15E9|!Base2           	; X = Sprite index
		LDA #$F8            		; \ Set OAM
		STA !15EA,x         		; /
		LDY #$02            		; \ OAM write finisher
		LDA #$01            		; |
		JSL $01B7B3|!BankB       	; /
		LDA $18B6|!Base2           	; \ Multiple coin block counter(Used as OAM reference(?!))
		STA !15EA,x         		; /
		LDY #$02            		; \ another write
		LDA #$01            		; |
		JSL $01B7B3|!BankB         	; /
		LDA !15A0,x         		; \ Skip if offscreen horizontally
		BNE Return01E984    		; /
		LDA $14B0|!Base2		; (make more tiles or something)
		CLC                 		;
		ADC #$04            		;
		STA $0208|!Base2  		;
		LDA $14B2|!Base2           ;
		CLC                 ;
		ADC #$07            ;
		STA $0209|!Base2    ;
		LDA #!SmileyFace    ;
		STA $020A|!Base2    ;
		LDA #!SmileyYXPPCCCT            ;
		STA $020B|!Base2    ;
		LDA #$00            ;
		STA $0422|!Base2    ;
Return01E984:               ;
		RTS                 ; Return


CloudTiles:
	db $66,$64,$62,$60
DATA_01E989:
	db $20,$E0
DATA_01E98B:
	db $10,$F0
DATA_01EBB4:
	db $01,$FF,$01,$00,$FF,$00,$20,$E0
	db $0A,$0E

CODE_01E98D:
		%SubHorzPos()	    ;
		TYA                 ; \ Set Lakitu's direction
		LDY !160E,x         ; |
		STA !157C,y         ; /
		STA $00             ;why not TAY?
		LDY $00             ;
		LDA $18BF|!Base2    ;
		BEQ +++             ;
		PHY                 ; \ Preserve indexes
		PHX                 ; /
		LDA !160E,x         ; \ Check offscreen for lakitu
		TAX                 ; |
		LDA #$00 : %SubOffScreen()
		LDA !14C8,x         ; \ If lakitu is killed from offscreen,
		PLX                 ; | kill the cloud too.
		CMP #$00            ; |
		BNE +               ; |
		STZ !14C8,x         ; |
		+                   ; /
		PLY                 ; \ Inverted direction to Y
		TYA                 ; |
		EOR #$01            ; |
		TAY                 ; /
		+++                 ;
		LDA $13             ; \ Process every other frame from true frame counter
		AND #$01            ; |
		BNE ++              ; /
		LDA !B6,x           ; \ If not at max speed, accelerate
		CMP DATA_01E989,y   ; |
		BEQ +               ; |
		CLC                 ; |
		ADC DATA_01EBB4,y   ; |
		STA !B6,x           ; |
		+                   ; /
		LDA !1534,x         ; \ Vertical speed oscillation
		AND #$01            ; |
		TAY                 ; |
		LDA !AA,x           ; |
		CLC                 ; |
		ADC DATA_01EBB4,y   ; |
		STA !AA,x           ; |
		CMP DATA_01E98B,y   ; |
		BNE ++              ; |
		INC !1534,x         ; |
		++                  ; /
		LDA !B6,x           ;
		PHA                 ;
		LDY $18BF|!Base2    ; \ If timer = 0, add change in layer1 to speed
		BNE +               ; |
		LDA $17BD|!Base2    ; |
		ASL #3              ; |
		CLC                 ; |
		ADC !B6,x           ; |
		STA !B6,x           ; |
		+                   ; /
		JSL $018022|!BankB  ; > xspeed no gravity
		PLA                 ;
		STA !B6,x           ;
		JSL $01801A|!BankB  ; > yspeed no gravity
		LDY !160E,x         ;
		LDA $13             ;
		AND #$7F            ;
		ORA !151C,y         ;
		BNE Return01EA16    ;
		LDA #$20            ;
		STA !1558,y         ;
		JSL $01EA19|!BankB  ; > Make spiny egg
Return01EA16:           	    ;
		RTS                       ; Return