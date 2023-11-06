; SJC: Requires ExGFX113 in SP3, or ExGFX213 for non-outlined
; Note that the usual jank will still apply,
; including a bit more GFX jank when moving screens, now that the second Yoshi's not invisible.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; UnInvisible Yoshi - by dtothefourth
;
; Draws an outline of the invisible Yoshi that exists
; when spawning two at once.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Tile1    = #$0A ; Head tile
!Tile1Alt = #$0E ; Head tile, mouth open
!Tile2    = #$0C ; Body tile


; Positions and properties for each tile
; Head, Body, Head Left, Body Left

XOff:
	db $0A, $00, $F6, $00
YOff:
	db $04, $10, $04, $10
Props:
	db $7B, $7B, $3B, $3B ; SJC mod. Default db $71, $71, $31, $31, palette 8?


main:
	LDA $13D4|!addr
	BEQ +
	RTL
	+
	STZ $00
	
 	LDX #!sprite_slots-1
	LDY #$30
	-
	LDA !14C8,x
	BEQ NextC
	LDA !9E,x
	CMP #$35 ; Yoshi
	BNE NextC
	INC $00
NextC:
	DEX
	BPL -
	LDA $00
	CMP #$02
	BPL +
	RTL
	+
	LDX #!sprite_slots-1
	LDY #$30
	-
loop:
	LDA $0201|!addr,y
	CMP #$F0
	BEQ end
	INY #$4
	BNE loop
	RTL
	end:
	LDA !14C8,x
	BNE +
	JMP next
	+
	LDA !15C4,x
	AND #$01
	BEQ +
	JMP next
	+
	LDA !186C,x
	BEQ +
	JMP next
	+
	LDA !9E,x
	CMP #$35
	BEQ +
	JMP next
	+
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	LDA !D8,x
	STA $02
	LDA !14D4,x
	STA $03
	PHX
	LDA !157C,x
	ASL
	TAX
	REP #$20
	LDA $00
	SEC
	SBC $1A
	STA $04
	SEP #$20
	CLC
	ADC XOff,x
	STA $0200|!addr,y
	REP #$20
	LDA $02
	SEC
	SBC $1C
	SEP #$20
	CLC
	ADC YOff,x
	STA $0201|!addr,y

	LDA $14
	SEC
	SBC #$02
	AND #$30
	CMP #$00
	BEQ +
	LDA !Tile1
	BRA ++
	+
	LDA !Tile1Alt
	++
	STA $0202|!addr,y
	LDA Props,X
	STA $0203|!addr,y
	PLX
	PHY
	TYA
	LSR #2
	TAY
	LDA $05
	AND #$01
	ORA #$02
	STA $0420|!addr,y
	PLY

	loop2:
	LDA $0201|!addr,y
	CMP #$F0
	BEQ end2
	INY #$4
	BNE loop2
	RTL
	end2:
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	LDA !D8,x
	STA $02
	LDA !14D4,x
	STA $03
	PHX
	LDA !157C,x
	ASL
	TAX
	REP #$20
	LDA $00
	SEC
	SBC $1A
	STA $04
	SEP #$20
	CLC
	ADC XOff+1,x
	STA $0200|!addr,y
	REP #$20
	LDA $02
	SEC
	SBC $1C
	SEP #$20
	CLC
	ADC YOff+1,x
	STA $0201|!addr,y
	LDA !Tile2
	STA $0202|!addr,y
	LDA Props,X
	STA $0203|!addr,y
	PLX
	PHY
	TYA
	LSR #2
	TAY
	LDA $05
	AND #$01
	ORA #$02
	STA $0420|!addr,y
	PLY
	RTL

next:
	DEX
	BMI +
	JMP -
	+
	RTL