!InitialWaterLevel = $0180
!TypeOfInteract = $02		; $02 = Water, $04 = Lava, $06 = Ground, $08 = Magma

!WaterBase = $0E11|!addr ; Default $1926, not cleared at level load
!FrameCounter = $0E16|!addr ; Default $17BB, contains the low byte of the level number when loading the levels. It's cleared when the loading is done.
!Amplitude = $20

CosineTable = $07F7DB

load:
	LDA #!TypeOfInteract
	STA !InteractionType
	REP #$20
	LDA #!InitialWaterLevel
	STA !WaterBase
	SEP #$20
BRA main

init:
	%InitInteractLineHdma(3, $12)
	STZ !FrameCounter

main:
	LDA $9D
	BNE +
	LDA $14
	AND #$01
	BNE +
	INC !FrameCounter
+	STZ $00
	LDA !FrameCounter
	BPL +
	INC $00
+	REP #$30
	AND #$007F
	ASL
	ASL
	TAX
	LDA CosineTable,x
	LSR $00
	BCC +
	EOR #$FFFF
	INC
+	SEP #$30
	STA $211B
	XBA
	STA $211B
	LDA #!Amplitude
	STA $211C
	REP #$20
	LDA $2135
	CLC : ADC !WaterBase
	STA !InteractionPos
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL


