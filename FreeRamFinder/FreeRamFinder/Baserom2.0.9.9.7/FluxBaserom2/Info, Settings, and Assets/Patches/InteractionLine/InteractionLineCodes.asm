@includefrom InteractionLinePatch.asm

KillMario = $00F606|!bank
KillMarioNoContr = $00F629|!bank
SpriteInLava = $019330|!bank

InteractPointY = $00E89E|!bank
SpriteVTable = $0190F7|!bank
SpriteWaterY = $019133|!bank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Player interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MarioInteractions:
dw .WaterInteraction-1
dw .LavaInteraction-1
dw .GroundInteraction-1
dw .LavaInteraction-1

.WaterInteraction:
	REP #$20				; A = 16-bit
	LDX #$02				; Loop it three times
-	LDA.l ..InteractionType,x
	TAY						; Index
	LDA ($00),y				; Get Y offset
	CLC : ADC $96			; Add with Mario's position
	CMP !InteractionPos		; Check if it's above the water line
	CLC						; Clear carry (no interaction)
	BMI ..AboveLine			;
	SEC						; Set carry (do interaction)
..AboveLine:				;
	ROL $8A					; Add it to water interaction (don't worry, $8B contains nothing)
	DEX						;
	BPL -					;
	SEP #$20				;
RTS							;

; From left to right:
; 1. MarioAbove
; 2. MarioBelow
; 3. MarioBody
..InteractionType:
db $00,$06,$08

.LavaInteraction:
	REP #$20				; A = 16-bit
	LDY #$08				; MarioAbove
	LDA ($00),y				; Get Y offset
	CLC : ADC $96			; Add with Mario's position
	SEC : SBC #$0010		; Shift it by one block upwards (surface doesn't kill Mario)
	CMP !InteractionPos		; Check lava level
	SEP #$20				; A = 8-bit
	BMI ..AboveLine			;
	PLA : PLA				; Terminate PEA
JML KillMarioNoContr		; Kill Mario and disable Mario's controls, no further interactions
							;
..AboveLine:				;
RTS							;


.GroundInteraction:
	REP #$20				; A = 16-bit
	LDY #$00				; MarioBody
	LDA ($00),y				; Get Y offset
	CLC : ADC $96			; Add with Mario's position
	CMP !InteractionPos		; Check ground level
	BMI ..NotCrushed		;
	PLA						; Terminate PEA
	SEP #$20				; A = 8-bit
	JSL KillMario			; Kill Mario
JML $00EAA5|!bank			; Don't interact further anymore
							;
..NotCrushed				;
	LDY #$08				; MarioAbove
	LDA ($00),y				; Get Y offset
	CLC : ADC $96			; Add with Mario's position
	CMP !InteractionPos		; Check ground level
	SEP #$20				; A = 8-bit
	BMI ..Return			;
	LDA $7D					; Rising = no ground interaction
	BMI ..Return			;
	LDA #$28				; Set falling speed (handles falling line)
	STA $7D					; This isn't as bad as with layer 2, at least.
	LDA $96					; Get player position within block
	SEC : SBC !InteractionPos; Get difference
	AND #$0F				; Confine it to whole block
	STA $91					;
	LDA $96					; Set Mario's position to the ground
	SEC : SBC $91			;
	STA $96					;
	LDA $97					; High byte
	SBC #$00				;
	STA $97					;
	PHK						; Set up return address
	PEA ..Return-1			;
	PEA.w $0084CF-1			;
JML $00EF6B|!bank			; Handle ground interaction
							;
..Return:					;
RTS							;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Sprite interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteInteractions:
dw .WaterInteraction-1
dw .LavaInteraction-1
dw .GroundInteraction-1
dw .MagmaInteraction-1

.LavaInteraction:
	JSR GetSpriteW			; Get SpriteW interaction point
	JSR CmpLine				; Check if interaction point is above line
	BMI ..Return			;
	LDA !9E,x				; The Yoshi exception!
	CMP #$35				;
	BEQ ..Yoshi				;
	LDA !167A,x				; Other sprites which run interaction for every frame
	AND #$02				; (i.e. platforms) are save from lava
	BNE .WaterInteraction	;
..Yoshi:					;
	PLA						; Terminate and replace JSL
	LDA #$54				;
	STA $01,s				;
	LDA #$91				;
	STA $02,s				;
	LDA !164A,x				;
	ORA #$81				;
	STA !164A,x				;
JML SpriteInLava			; Kill sprite
							;
..Return:					;
RTL							;

.WaterInteraction:			;
	JSR GetSpriteW			; Get SpriteW interaction point
	JSR CmpLine				; Check if interaction point is above line
	BMI ..Return			;
	LDA !164A,x				; Mark sprite in water
	ORA #$01				;
	STA !164A,x				;
..Return:					;
RTL							;

.GroundInteraction:			;
	LDA !AA,x				; Sprite must be falling
	BPL ..GroundInteract	;
	LDY #$03				; SpriteBelow
	JSR GetSpriteV			; Get SpriteV interaction point
	JSR CmpLine				; Check if interaction point is above line
	BMI ..Return			;
	LDA !1588,x				; Mark sprite blocked from below
	ORA #$28				; Both, in general and layer 2 (for a moving line)
	STA !1588,x				;
RTL							;
							;
..GroundInteract			;
	LDY #$02				; SpriteAbove
	JSR GetSpriteV			; Get SpriteV interaction point
	STA $0C					; Save it for later
	JSR CmpLine				; Check if interaction point is above line
	BMI ..Return			;
..OnGround:					;
	LDA !1686,x				; Sprite can interact with ground
	AND #$84				;
	BNE ..Return			;
	LDA !14C8,x				; Only certain sprite types can't interact with ground:
	CMP #$02				; Falling
	BEQ ..Return			;
	CMP #$05				; Sinking in lava
	BEQ ..Return			;
	CMP #$0B				; Carried
	BEQ ..Return			;
	LDA !15D0,x				;
	BNE ..Eaten				;
	LDA $0C					; Offset sprite
	SEC : SBC !InteractionPos
	AND #$0F				;
	STA $00					;
	LDA !D8,x				; Put sprite on ground.
	SEC : SBC $00			;
	STA !D8,x				;
	LDA !14D4,x				; Fix high byte
	SBC #$00				;
	STA !14D4,x				;
..Eaten:					;
	LDA !1588,x				; Mark sprite blocked from below
	ORA #$84				; Both, in general and layer 2 (for a moving line)
	STA !1588,x				;
..Return:					;
RTL							;

.MagmaInteraction:			;
	LDY #$02				; SpriteAbove
	JSR GetSpriteV			; Get SpriteV interaction point
	STA $0C					; Save it for later
	JSR CmpLine				; Check if interaction point is above line
	LDA !9E,x				; The Yoshi exception!
	CMP #$35				;
	BEQ ..Yoshi				;
	LDA !167A,x				; Other sprites which run interaction for every frame
	AND #$02				; (i.e. platforms) are save from lava
	BNE .GroundInteraction_OnGround
..Yoshi:					;
	PLA						; Terminate and replace JSL
	LDA #$54				;
	STA $01,s				;
	LDA #$91				;
	STA $02,s				;
	LDA #$05				;
	STA !14C8,x				;
	LDA #$40				;
	STA !1558,x				;
RTL							;
							;
..Return:					;
RTL							;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Fireball interaction
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


FireballInteractions:
dw .NoInteraction-1
dw .NoInteraction-1
dw .GroundInteraction-1
dw .GroundInteraction-1

.NoInteraction:
RTS

.GroundInteraction:
	LDA $01					; Get interaction point
	XBA						;
	LDA $00					;
	JSR CmpLine				; Compare with interaction line
	BMI .NoInteraction		;
	LDA #$01				; Fireball hit the ground
	TSB $0E					;
RTS							;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Shared routines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Input:
;	X = Current sprite index
;	Y = Interaction point type (0 = Left, 1 = Right, 2 = Bottom, 3 = Top)
GetSpriteV:
	STY $00					;
	LDA !1656,x				; Get SpriteV from object clipping
	AND #$0F				;
	ASL #2					; *4
	CLC : ADC $00			; Bottom interaction point
	TAY						; Set it as the index
	LDA.w SpriteVTable,y	;
	CLC : ADC !D8,x			; Load directly from ROM
	XBA						; Preserve low byte
	LDA !14D4,x				;
	ADC #$00				; Offsets are always positive
	XBA						;
RTS							;


; Input:
;	X = Current sprite index
GetSpriteW:
	LDA.b #read1(SpriteWaterY)
	CLC : ADC !D8,x			; Load directly from ROM
	XBA						; Preserve low byte
	LDA !14D4,x				;
	ADC #$00				;
	XBA						;
RTS							;


; Input:
;	A (16-bit): Position of the interaction point
; Do note that you must access this routine in 8-bit mode.
CmpLine:
	CMP !InteractionPos		; Check water level (low byte)
	XBA						; Restore high byte
	SBC !InteractionPos+1		; Check water level (heigh byte)
RTS							;
