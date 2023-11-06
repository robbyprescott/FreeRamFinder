;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Super Mario 64 - Crystal Tap
;	by MarioFanGamer
;
; This simple sprite allows the player to set the
; water level at the same position where the crystal
; is located when touched.
;
; It requires the use of the patch Interaction Line
; and UberASM.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; FreeRAM defines
!WaterLevelRam = $0E0F|!addr	; Must be the same as in the patch
!NewWaterLevel = $0E10|!addr	; Must be the same as in the UberASM code

!ActivateSfx = $0B				; Sound effect to play when switch is active
!ActivatePort = $1DF9|!addr		;

; This covers only half of the frames.
; The other half is drawn by flipping them vertically
Tiles:
db $E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE ; $80,$82,$84,$86,$88,$8A,$8C,$8E

print "INIT ",pc
RTL

print "MAIN ",pc
	PHB					; The usual stuff
	PHK					;
	PLB					;
	JSR CrystalTapMain	;
	PLB					;
RTL						;

CrystalTapMain:
	JSR Graphics		; Draw sprite
						;
	LDA !14C8,x			; Only run when sprite is alive...
	EOR #$08			;
	ORA $9D				; ... or level runs.
	BNE .Return			;
						;
	LDA #$07			; Animate every fourth frame
	STA $00				;
	LDA !14D4,x			; Get Y position
	XBA					;
	LDA !D8,x			;
	REP #$20			; A = 16-bit
	CLC : ADC #$0008	; Get centre of the sprite
	CMP !NewWaterLevel	; If not equal to the final position
	BNE .SlowAnimation	; 
	LDA !WaterLevelRam	;
	CMP !NewWaterLevel	;
	BEQ .SlowAnimation	;
	LDA #$0003			; Animate at double the speed.
	STA $00				;
						;
.SlowAnimation:			;
	SEP #$20			; A = 8-bit
						;
	LDA $14				; Frame counter
	AND $00				;
	BNE .NoGfxChange	;
	INC !1602,x			; Load next frame
	LDA !1602,x			; Each time there is a full rotation...
	AND #$07			;
	BNE .NoGfxChange	;
	LDA !15F6,x			; Flip the sprite
	EOR #$80			;
	STA !15F6,x			;
.NoGfxChange:			;
						;
	JSL $01A7DC|!bank	; Mario interaction
	BCC .Return			;
	LDA !14D4,x			; Get position
	XBA					;
	LDA !D8,x			;
	REP #$20			; A = 16-bit
	CLC : ADC #$0008	; Get centre of the sprite
	CMP !NewWaterLevel	; 
	BEQ .Return			;
	STA !NewWaterLevel	;
	SEP #$20			;
	LDA #!ActivateSfx	;
	STA !ActivatePort	;
.Return:				;
	SEP #$20			; A = 8-bit
RTS						;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Graphics
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Graphics:
	LDA !1602,x			;
	AND #$07			;
	TAY					;
	LDA Tiles,y			;
	STA $02				;
						;
	%GetDrawInfo()		;
						;
	LDA $00				;
	STA $0300|!addr,y	;
	LDA $01				;
	STA $0301|!addr,y	;
	LDA $02				;
	STA $0302|!addr,y	;
	LDA !15F6,x			;
	ORA $64				;
	STA $0303|!addr,y	;
	LDY #$02			;
	LDA #$00			;
	%FinishOAMWrite()	;
RTS						;
