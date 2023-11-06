!WaterLevel = $0180
!TypeOfInteract = $04		; $02 = Water, $04 = Lava, $06 = Ground, $08 = Magma

load:
	LDA #!TypeOfInteract
	STA !InteractionType
	REP #$20
	LDA #!WaterLevel
	STA !InteractionPos
RTL

init:
	%InitInteractLineHdma(3, $12)
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL

main:
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL
