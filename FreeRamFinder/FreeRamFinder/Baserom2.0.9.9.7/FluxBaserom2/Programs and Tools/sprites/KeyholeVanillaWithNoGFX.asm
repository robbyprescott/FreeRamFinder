;--------------------------------------------------------
; init routine
;--------------------------------------------------------

print "INIT ",pc
	RTL

;--------------------------------------------------------
; main routine wrapper
;--------------------------------------------------------

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR sprite
	PLB
	RTL

;--------------------------------------------------------
; main routine
;--------------------------------------------------------

sprite:
    JSR gfx

    LDA $9D
    BNE return

	REP #$20
	LDA #$0005
	STA $08
	LDA #$0001
	STA $0A
	LDA #$0006
	STA $0C
	LDA #$000E
	STA $0E
	SEP #$20
	
	%SetSpriteClippingAlternate()
	LDY #!SprSize-1
-
	PHY
	LDA !sprite_num,y
	CMP #$80
	BNE +
	LDA !sprite_status,y
	CMP #$0B
	BNE +

	REP #$20
	LDA #$0001
	STA $00
	STA $02
	LDA #$000E
	STA $04
	STA $06
	SEP #$20
	
	LDA !sprite_x_high,y
	XBA
	LDA !sprite_x_low,y
	REP #$20
	CLC
	ADC $00
	STA $00
	SEP #$20
	LDA !sprite_y_high,y
	XBA
	LDA !sprite_y_low,y
	REP #$20
	CLC
	ADC $02
	STA $02
	SEP #$20
	
	%CheckForContactAlternate()
	BCC +
	LDA #$0F
	STA $1DFC|!Base2
	LDA #$06
	STA $71
	STZ $88
	STZ $89
+
	PLY
	DEY
	BPL -
return:
    RTS

;--------------------------------------------------------
; graphics routine
;--------------------------------------------------------
y_offset:
	db $00,$08
	
tilemap:
	db $5F,$5F ; vanilla $EB,$FB, SJC
	
gfx:
	%GetDrawInfo()

	PHX
	LDX #$01
-
	LDA #$04
	CLC
	ADC $00
	STA $0300|!Base2,y
	
	LDA y_offset,x
	CLC
	ADC $01
	STA $0301|!Base2,y
	
	LDA tilemap,x
	STA $0302|!Base2,y
	
	PHX
	LDX $15E9|!Base2
	LDA !15F6,x
	ORA $64
	STA $0303|!Base2,y
	PLX
	
	INY #4
	DEX
	BPL -
	
	PLX
	LDY #$00
	LDA #$01
	%FinishOAMWrite()
	RTS
