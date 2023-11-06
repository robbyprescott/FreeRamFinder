!HdmaFreeRAM = $7F8600

HdmaInit:
	ORA #$0002				; One register, write twice
	STA $4300,x				;
	LDA.w #!HdmaFreeRAM		; Address of table
	STA $4302,x				;
	SEP #$20				; A = 8-bit
	LDA.b #!HdmaFreeRAM>>16	; Bank of table
	STA $4304,x				;
	TXA						;
	LSR #4					; Divide index by 16
	TAX						;
	LDA.l .BitFlags,x		; Get bit of HDMA
	TSB $0D9F|!addr			; Enable HDMA for this channel
RTL

.BitFlags:
db $01,$02,$04,$08,$10,$20,$40,$80

CalculateLayer2Pos:
	REP #$20
	LDA #$0102
	SEC : SBC !InteractionPos
	CLC : ADC $1C
	STA $20
	SEP #$20
RTL

CalculateLayer3Pos:
	REP #$20
	LDA #$0101
	SEC : SBC !InteractionPos
	CLC : ADC $1C
	STA $24
	SEP #$20
RTL


; The routine which writes.
CalculateHdma:
	CLC : SBC $1C			;
	BMI .UnderWater			; If value is negative, the water level is above camera
	CMP #$00E0				; If value is at least 0x00E0, the water is offscreen
	BCC .WaterVisible		; Otherwise, draw layer 3 how it is

; Invisible water means only draw air tiles at a fixed position.
.NoWaterVisible:
	LDA #$0001				; db $01 : dw $xx00
	STA !HdmaFreeRAM+0		;
	DEC						; db $01 : dw $0000 : db $00
	STA !HdmaFreeRAM+2		;
	SEP #$20				; A = 8-bit
RTL

; Water fills the whole screen
; The question is: How much?
.UnderWater:
	CMP #$FFE0				; If surface is visible, just write a simple HDMA table
	BCC .Submerged			;

; If the surface is visible, drawing water is easy.
.WaterVisible:
	EOR #$FFFF				; Invert position
	SEC : ADC #$0100		; Shift tilemap by 0x0100 + 1 pixels
	STA !HdmaFreeRAM+1		;
	SEP #$20				; A = 8-bit
	LDA #$01				; Write line count
	STA !HdmaFreeRAM+0		;
	DEC						; Termination byte
	STA !HdmaFreeRAM+3		;
RTL

; If the surface isn't visible anymore, things get a bit more complicated.
; This is because the graphics have to loop between a value which is not
; a power of two (0x00E0).
.Submerged:
	LDX #$00				; Set X to 0
	EOR #$FFFF				; Invert accumulator (division is unsigned)
	INC						;
	SEC : SBC $00			; Fix position (loop point is 0x20 below the surface)
	STA $4204				; Get difference
	LDY #$E0				; Get height of image
	STY $4206				;
	NOP #2					; Two minor cycles (just to be sure)
	LDA #$0100				; Offset (also three cycles)
	CLC : ADC $00			; Offset two i.e. loop start (and 6 cycles)
	CLC : ADC $4216			; Add with the results (also 2 + 3 cyles from addition)
	STA $00					; Preserve position
	LDA $02					; Calculate line count ()
	CLC : SBC $4216			;
	CMP #$0080				; HDMA can't write for more than 0x80 scanlines
	BCC ..SingleLine		;
	PHA						; Preserve scanline count
	LDA #$0080				; Write 0x80 scanlines
	STA !HdmaFreeRAM+0		;
	LDA $00					; Get layer 3 position
	STA !HdmaFreeRAM+1		;
	PLA						; Restore it back
	SEC : SBC #$0080		; Fix position
	INX #3					; Increment X.
..SingleLine				;
	STA !HdmaFreeRAM+0,x	; Write scanline count
	LDA $00					;
	STA !HdmaFreeRAM+1,x	; Write position
	SEC : SBC #$00E0		;
	STA !HdmaFreeRAM+4,x	; Write offset position for next rows
	SEP #$20				;
	LDA #$01				; Scanline count for the remaining lines
	STA !HdmaFreeRAM+3,x	;
	DEC						; Termination byte
	STA !HdmaFreeRAM+6,x	;
RTL
