; very minor fix by SJC, per Wyatt

;===============================================================================;
; Custom Green Gas Bubble														;
; by dogemaster																	;
;																				;
; Extra bit: Not set. (Extra Bits Field = 02)									;
; Extra byte 1: controls the movement pattern.                                  ;
;   - 00: always go left.                                                       ;
;   - 01: always go right.                                                      ;
;   - 02: go left first, then right, etc.                                       ;
;   - 03: go right first, then left, etc.                                       ;
;   - 04 or 05: go towards Mario, and keep the same direction.                  ;
;   - 06 or 07: go towards Mario, and then go back and forth.                   ;
;                                                                               ;
; Extra bit: Set. (Extra Bits Field = 03)										;
; Extra byte 1: controls the alt movement patterns and their intensity.			;
;   - 00 to 7F: Tracks mario and tries to reach him akin to the pink bubble 	;
;				from Casio Mario World. You can specify what speed it goes 		;
;				towards mario with. (would recommend 10 or 20)					;
;	- 80 to FF: Tracks mario horizontally akin to a disco shell. You can 		;
;				specify the max speed it reaches by inputting the speed you 	;
;				want plus 80. So for same speed like a disco shell you'd enter 	; 	
;				A0. (which is A0-80 = 20)										;
;																				;
; Extra byte 2: Controls the palette the bubble has.							;
;	- 0 = row 8																	;
;	- 1 = row 9 																;
;	- 2 = row A 																;
;	- 3 = row B 																;
;	- 4 = row C 																;
;	- 5 = row D 																;
;	- 6 = row E 																;
;	- 7 = row F																	;
;===============================================================================;


;===================================;
; Defines of general properties     ;
; Feel free to edit these.          ;
;===================================;

!XAcceleration    = $01
!YAcceleration    = $01
!MaxXSpeed        = $10   		; Max X speed before turning back.
!MaxYSpeed        = $10
!XSpeedUpdateFreq = $03   		;\ These control how often the acceleration gets applied. Lower = more frequently.
!YSpeedUpdateFreq = $03   		;/ Valid values: $00,$01,$03,$07,$0F,$1F,$3F,$7F,$FF.
                          		; For example, bigger YFreq values will result in "higher" sine wave patterns.
!MaxXSpeedTimer   = $20   		; How much to fly at max speed before turning back.
!ConstantXSpeed   = $10   		; X speed when the sprite is set to never change direction.

!DBXAcceleration = $02			; Disco Bubble's Acceleration.
!DBOscillate = 01				; Make the Bubble go up and down or not when its in Disco mode.

;====================================================;
; Don't edit this unless you know what you're doing! ;
;====================================================;

XAcceleration:
    db -!XAcceleration,!XAcceleration
YAcceleration:
    db !YAcceleration,-!YAcceleration
MaxXSpeed:
    db -!MaxXSpeed,!MaxXSpeed
MaxYSpeed:
    db !MaxYSpeed,-!MaxYSpeed
ConstantXSpeed:
    db -!ConstantXSpeed,!ConstantXSpeed

;===================================;
; Init routine                      ;
;===================================;

print "INIT ",pc
	%BES(.return)
	LDA !extra_byte_1,x     	;\ If the "face Mario" bit is set
    AND #$04                	;|
    BEQ +                   	;|
    %SubHorzPos()           	;| set initial direction based on his relative position.
    TYA                     	;|
    EOR #$01                	;|
    BRA ++                  	;/
+   LDA !extra_byte_1,x     	;\ Set initial direction.
    AND #$01                	;|
++  STA !1534,x             	;/
    LDA !extra_byte_1,x     	;\ Set movement pattern.
    AND #$02                	;|
    STA !1504,x             	;/
.return
	RTL

;===================================;
; Main routine                      ;
;===================================;

print "MAIN ",pc					
	PHB							;\
	PHK							;|
	PLB							;| Normal stuff.
	JSR EPIC    				;|
	PLB							;|
	RTL							;/

EPIC:
	JSR GasBubbleGfx			; Draw GFX.
	LDA !14C8,X				    ;\ Return if game frozen, or sprite killed.
	EOR #$08					;|
	ORA $9D						;|
	BNE Return			        ;/
	%BES(Casio)
	JSR YMovement

XMovement:
    LDA !1504,x
    beq ConstantSpeed
    LDA !1540,x             	;\ Skip for a short time when at max speed.
    BNE +                   	;/
if !XSpeedUpdateFreq != $00
    LDA $14                 	;\ Change speed every 4 frames.
    AND #!XSpeedUpdateFreq  	;|
    BNE +                   	;/
endif
    LDA !1534,x             	;\ Handle X acceleration.
    AND #$01                	;|
    TAY                     	;|
    LDA !B6,x               	;|
    CLC                     	;|
    ADC XAcceleration,y     	;|
    STA !B6,x               	;|
    CMP MaxXSpeed,y         	;|
    BNE +                   	;|
    INC !1534,x             	;/
    LDA #!MaxXSpeedTimer    	;\ How long to fly at max speed for.
    STA !1540,x             	;/
+   BRA ++

ConstantSpeed:
    LDY !1534,x             	;\ Set constant speed based on direction.
    LDA ConstantXSpeed,y    	;|
    STA !B6,x               	;/
++

Common:
	INC !1570,X					; Handle the timer for animation.
	LDA #$01					;\ Process offscreen.
	%SubOffScreen()				;/
    JSL $018022|!BankB       	; Update X position without gravity.
  	JSL $01801A|!BankB       	; Update Y position without gravity.
	JSL $01A7DC|!BankB			; Subroutine that handles interaction between Mario and the sprite.

Return:
	RTS

YMovement:
if !YSpeedUpdateFreq != $00
    LDA $14                 	;\ Change speed every other frame.
    AND #!YSpeedUpdateFreq  	;|
    BNE +                   	;/
endif
    LDA !1594,x             	;\ Handle Y acceleration.
    AND #$01                	;|
    TAY                     	;|
    LDA !AA,x               	;|
    CLC                     	;|
    ADC YAcceleration,y     	;|
    STA !AA,x               	;|
    CMP MaxYSpeed,y         	;|
    BNE +                   	;|
    INC !1594,x             	;/
+
RTS

Casio:
	LDA !extra_byte_1,x			;\ If extra byte 1 > 7F, make it disco.
	BMI Disco					;/
	LDA !sprite_x_low,x			;\ store sprite position into scratch RAM.
	CLC							;|\ adding 32 pixels to make the bubble track mario from centre.
	ADC #$16					;|/  SJC fix
	STA $00						;|
	LDA !sprite_x_high,x		;|
	ADC #$00					;|
	STA $01						;|
	LDA !sprite_y_low,x			;|\ adding 32 pixels to make the bubble track mario from centre.
	ADC #$16					;|/ SJC fix
	STA $02						;|
	LDA !sprite_y_high,x		;|
	ADC #$00					;|
	STA $03						;/
		
	LDA $00						;\ subtract sprite x position with player x position.
	SEC : SBC $94				;|
	STA $00						;|
	LDA $01						;|
	SBC $95						;|
	STA $01						;/
		
	REP #$20					;\ subtract sprite y position with player y position (and a constant so it aims a bit lower).
	LDA $02						;|
	SEC : SBC $96				;|
	SBC #$0010					;|
	STA $02						;|
	SEP #$20					;/
		
	LDA !extra_byte_1,x			;\ make bubble track mario and go towards him.
	%Aiming()					;|
	LDA $00						;|
	STA !sprite_speed_x,x		;|
	LDA $02						;|
	STA !sprite_speed_y,x		;/
	BRA Common2					

Disco:
	LDA !sprite_x_low,x			;\ Check where mario is relative to the bubble's centre
	CLC 						;|
	ADC #$18					;|
	STA $00						;|
	LDA !sprite_x_high,x		;|
	ADC #$00					;|
	STA $01						;|
	LDY #$00					;|
	LDA $94						;|
	SEC							;|
	SBC $00						;|
	STA $0E						;|
	LDA $95						;|
	SBC $01						;|
	STA $0F						;|
	BPL +						;|
	INY							;/
+	TYA							;\ Make bubble face mario.
	STA !157C,x					;/
	LDA !extra_byte_1,x			;\ Save the Max speed the bubble can attain (and its negative) into scratch.
	SEC							;|
	SBC #$80					;|
	STA $00						;|
	EOR #$FF					;|
	INC 						;|
	STA $01						;/
	LDA !sprite_speed_x,x		;\ Track mario like a disco.
	LDY !157C,x					;|
	BNE +						;|
	CMP $00						;|
	BPL ++						;|
	CLC							;|
	ADC #!DBXAcceleration		;|
	BRA ++						;|
+	CMP $01						;|
	BMI +						;|
	SEC							;|
	SBC #!DBXAcceleration		;|
++	STA !sprite_speed_x,x		;/
+	
if !DBOscillate
	JSR YMovement
endif

Common2:
	INC !1570,X					; Handle the timer for animation.
	LDA #$01					;\ Process offscreen.
	%SubOffScreen()				;/
    JSL $018022|!BankB       	; Update X position without gravity.
  	JSL $01801A|!BankB       	; Update Y position without gravity.
	JSL $01A7DC|!BankB			; Subroutine that handles interaction between Mario and the sprite.
RTS

Xoffset:						; X offsets for each tile in the gas bubble.
	db $00,$10,$20,$30
	db $00,$10,$20,$30
	db $00,$10,$20,$30
	db $00,$10,$20,$30

Yoffset:						; Y offsets for each tile in the gas bubble.
	db $00,$00,$00,$00
	db $10,$10,$10,$10
	db $20,$20,$20,$20
	db $30,$30,$30,$30

Tilemap:						; Tile numbers for each tile in the gas bubble.
	db $80,$82,$84,$86
	db $A0,$A2,$A4,$A6
	db $A0,$A2,$A4,$A6
	db $80,$82,$84,$86

Properties:						; This just deals with flipping the correct tiles vertically.
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $80,$80,$80,$80
	db $80,$80,$80,$80

OffsetTable:					; Which tiles to apply the below offsets to.
	db $00,$00,$02,$02			; Formatted as ------XY  (X = apply X offset, Y = apply Y offset).
	db $00,$00,$02,$02
	db $01,$01,$03,$03
	db $01,$01,$03,$03

ExtraXoffset:					; Extra X offsets the bubble will use for each frame of animation.
	db $00,$01,$02,$01

ExtraYoffset:					; Extra Y offsets the bubble will use for each frame of animation.
	db $02,$01,$00,$01

GasBubbleGfx:
	LDA !1570,X					;\ 
	LSR							;|
	LSR							;|
	LSR							;|
	AND #$03					;| Get extra X and Y offset value for the current frame of animation.
	TAY							;|
	LDA ExtraXoffset,Y			;|
	STA $02						;|
	LDA ExtraYoffset,Y			;|
	STA $03						;/
	LDA !15F6,x					;\ Load CFG/JSON values in scratch for later use. 
	STA $04						;/
	LDA !extra_byte_2,x			;\ Palette extra byte for later
	ASL							;|
	STA $05						;/
	%GetDrawInfo()				; we dont need to LDY !15EA,x because %getdrawninfo already does that, thanks James.
	LDX #$0F					; 16 tiles to draw so load 0F into X and commence the looping.

GFXLoop:
	LDA $00						;\ 
	CLC							;|
	ADC Xoffset,X				;|
	PHA							;|
	LDA OffsetTable,X			;|
	AND #$02					;|
	BNE +						;|
	PLA							;|
	CLC							;| Get the X offset for the current tile.
	ADC $02						;| Add the extra X offset if applicable, as well.
	BRA ++						;|
+								;|
	PLA							;|
	SEC							;|
	SBC $02						;|
++								;|
	STA $0300|!addr,Y			;/
	LDA $01						;\ 
	CLC							;|
	ADC Yoffset,X				;|
	PHA							;|
	LDA OffsetTable,X			;|
	AND #$01					;|
	BNE +						;|
	PLA							;|
	CLC							;| Get the Y offset for the current tile.
	ADC $03						;| Add the extra Y offset if applicable, as well.
	BRA ++						;|
+								;|
	PLA							;|
	SEC							;|
	SBC $03						;|
++								;|
	STA $0301|!addr,Y			;/
	LDA Tilemap,X				;\ Set the tilemap.
	STA $0302|!addr,Y			;/
	LDA $04						;\ Load in values from CFG/JSON.
	ORA Properties,X			;| Flip correct tiles.
	ORA #$30					;| Set the PP bits in YXPPCCCT.
	ORA $05						;|
	STA $0303|!addr,Y			;/

	INY							;\ 
	INY							;|
	INY							;| Loop for all 16 tiles.
	INY							;|
	DEX							;|
	BPL GFXLoop					;/
	LDX $15E9|!addr				; Epicly restore X.
	LDY #$02					;\ 
	LDA #$0F					;| Draw 16 16x16 tiles.
	JSL $01B7B3|!BankB			;/
RTS

