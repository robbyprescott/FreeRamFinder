!InitialWaterLevel = $0100

!NewWaterLevel = $0E17|!addr

!WaterSpeed = $0001

load:
	LDA #$02
	STA !InteractionType
	REP #$20
	LDA #!InitialWaterLevel
	STA !InteractionPos
	STA !NewWaterLevel

init:
	%InitInteractLineHdma(3, $12)
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL

main:
	REP #$20
	LDA !InteractionPos
	CMP !NewWaterLevel
	BEQ .NoChange
	BCS .Above
	CLC : ADC #!WaterSpeed
	CMP !NewWaterLevel
	BCC .Store
	LDA !NewWaterLevel
BRA .Store
.Above:
	SEC : SBC #!WaterSpeed
	CMP !NewWaterLevel
	BCS .Store
	LDA !NewWaterLevel
.Store:
	STA !InteractionPos

.NoChange:
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL
