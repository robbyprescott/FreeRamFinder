!InitWaterLevel = $0150		; Initial water height. 150 is 6 tiles high?
!WaterMinPos = $0190		; Lowest position of the water, default $0190
!WaterMaxPos = $0120		; Highest position of the water, default $0120
!TypeOfInteract = $02		; $02 = Water, $04 = Lava, $06 = Ground, $08 = Magma

!InitWait = $00				; Time until the tide starts moving at level start ($00 = 256, vanilla)
!TideWait = $4B				; Default $4B. Time till the tide moves after it moved.
!InitDir = $00				; $00 = Up, $01 = Down
!MaxSpeed = $04				; Fastest speed for tide.

; FreeRAM
; Some are the same as in vanilla SMW.

!TideTimer = $1B9D|!addr		; vanilla RAM
!TideSpeed = $0E13|!addr		; Default was $1DFD: not vanilla, two bytes? cleared level load
!TideDir = $0E15|!addr			; Default was $1E00: not vanilla, cleared level load
!InteractSubpix = $0E12|!addr	; Default was $1F3B: not vanilla, not cleared @ level load

load:
	LDA #!TypeOfInteract
	STA !InteractionType
	REP #$20
	LDA #!InitWaterLevel
	STA !InteractionPos
	SEP #$20

init:
	;LDA #!InitWait
	;STA !TideTimer
	LDA #!InitDir
	STA !TideDir

	%InitInteractLineHdma(3, $12)
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL

main:
	LDA $9D			; Don't run code if paused
	ORA $13D4|!addr
	BNE .Return
	
	LDY !TideDir
	LDA $14
	AND #$03
	BNE .MoveTide
	
	LDA !TideSpeed
	BNE .StillMoving
	
	;DEC !TideTimer
	;BNE .Return

.StillMoving:
	CMP WaterSpeedLimit,y
	BEQ .NoAccell
	CLC : ADC WaterAccell,y
	STA !TideSpeed

.NoAccell:
	;LDA #!TideWait
	;STA !TideTimer
	
.MoveTide:
	REP #$20
	TYA
	ASL
	TAX
	LDA !InteractionPos
	CMP WaterPosLimit,x
	BNE .DontInvert

	TYA
	SEP #$20
	EOR #$01
	STA !TideDir
	REP #$20

.DontInvert:
	LDA !TideSpeed
	AND #$00FF
	ASL #4
	SEP #$20
	CLC : ADC !InteractSubpix
	STA !InteractSubpix
	REP #$20
	XBA
	AND #$00FF
	BIT #$0008
	BEQ .NotNegative
	ORA #$FFF0

.NotNegative:
	ADC !InteractionPos
	STA !InteractionPos

.Return:
	%CalculateInteractLineHdma(!InteractionPos, $20, $E0)
RTL

WaterAccell:
db $FF,$01

WaterSpeedLimit:
db -!MaxSpeed,!MaxSpeed

WaterPosLimit:
dw !WaterMaxPos,!WaterMinPos
