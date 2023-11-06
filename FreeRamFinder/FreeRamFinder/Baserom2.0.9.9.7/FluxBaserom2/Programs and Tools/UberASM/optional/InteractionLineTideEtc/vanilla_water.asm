!WaterLevel = $0180 ; 150 is 6 tiles high?
!TypeOfInteract = $02		; $02 = Water, $04 = Lava, $06 = Ground, $08 = Magma

load:
	LDA #!TypeOfInteract
	STA !InteractionType
	REP #$20
	LDA #!WaterLevel
	STA !InteractionPos
RTL

init:
	%InitInteractLineHdma(3, $12)

main:
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL
