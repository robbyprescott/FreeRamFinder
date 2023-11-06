;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Throw Speed Tweak - by dtothefourth
;
; This UberASM lets you tweak the speed of thrown items in various ways
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;FreeRAM
!Slot = $7FB500

!AddSpeed  = 0		;If 1, adds a fixed value to X or Y speed
!AddX 	   = $00	;Adds this amount to X speed, positive increases speed and negative decreases speed
!AddY	   = $00	;Adds this amount to Y speed

!MultSpeed = 0		;If 1, multiplies the throw speed by a value
!MultX	   = $0010  ;Multiplies X speed by this amount with 0010 being 1. So 0020 would be double speed, 0008 would be half speed etc
!MultY	   = $0010  ;Multiplies Y speed by this amount with 0010 being 1. So 0020 would be double speed, 0008 would be half speed etc

!SetSpeed  = 0		;If 1, sets the speed to an exact value (overrides add or mult)
!SetX	   = $00	;Fixed X speed in the throw direction
!SetY	   = $00	;Fixed Y speed

!Momentum  = 0		;If 1, adds a proportion of Mario's speed to the throw speed
!MomentX   = $0010	;Adds a multiple of Mario's X speed with 0010 being 1. So 0020 would add twice Mario's speed, 0008 would add half Mario's speed etc
!MomentY   = $0010  ;Adds a multiple of Mario's Y speed with 0010 being 1. So 0020 would add twice Mario's speed, 0008 would add half Mario's speed etc



!CapX	   = 1		;If 1, cap x speed to a max value
!MaxX	   = $60	;Maximum X speed (0-7F)		
!CapY	   = 1		;If 1, cap y speed to a max value
!MaxY	   = $60	;Maximum Y speed (0-7F)



init:
	LDA #$FF
	STA !Slot
	RTL

main:
	LDA $1470|!addr
	ORA $148F|!addr
	BNE +

	LDA !Slot
	CMP #$FF
	BEQ ++
	TAX

	LDA $15
	AND #$0F
	CMP #$04
	BEQ ++
	JSR Throw
	++	

	LDA #$FF
	STA !Slot
	RTL
	+

	LDX #!sprite_slots-1
	-

	LDA !14C8,x
	CMP #$0B
	BNE +

	TXA
	STA !Slot
	BRA +
	+
	DEX
	BPL -
	RTL

Throw:

	if !MultSpeed && !SetSpeed == 0

	if !MultX != $0010

	LDA !B6,x
	BMI +
	TAY
	REP #$20
	LDA #!MultX
	JSR Multiply
	LSR #4
	CMP #$0100
	SEP #$20
	BCS ++++
	CMP #$00
	BPL +++
	++++
	LDA #$7F
	+++
	STA !B6,x
	BRA ++
	+

	TAY
	REP #$20
	LDA #!MultX
	JSR Multiply
	LSR #4
	CMP #$0F00
	SEP #$20
	BCC ++++
	CMP #$00
	BMI +++
	++++
	LDA #$80
	+++
	STA !B6,x
	++
	endif

	if !MultY != $0010

	LDA !AA,x
	BMI +
	TAY
	REP #$20
	LDA #!MultY
	JSR Multiply
	LSR #4
	CMP #$0100
	SEP #$20
	BCS ++++
	CMP #$00
	BPL +++
	++++
	LDA #$7F
	+++
	STA !AA,x
	BRA ++
	+

	TAY
	REP #$20
	LDA #!MultY
	JSR Multiply
	LSR #4
	CMP #$0F00
	SEP #$20
	BCC ++++
	CMP #$00
	BMI +++
	++++
	LDA #$80
	+++
	STA !AA,x
	++
	endif	


	endif

	if !AddSpeed && !SetSpeed == 0

	if !AddX != $00

	LDA !B6,x
	BMI +
	
	CLC
	ADC #!AddX
	BPL +++

	LDA #!AddX
	BPL ++++
	LDA #$00
	BRA +++
	++++
	LDA #$7F


	+++
	STA !B6,x
	BRA ++
	+

	SEC
	SBC #!AddX
	BMI +++

	LDA #!AddX
	BPL ++++
	LDA #$00
	BRA +++
	++++
	LDA #$80


	+++
	STA !B6,x
	++
	endif

	if !AddY != $00

	LDA !AA,x
	BMI +
	
	CLC
	ADC #!AddY
	BVC +++
	JSR Sign
	+++
	STA !AA,x
	BRA ++
	+

	CLC
	ADC #!AddY
	BVC +++
	JSR Sign
	+++
	STA !AA,x
	++
	endif	

	endif

	if !SetSpeed

	LDA !B6,x
	BMI +
	LDA #!SetX
	BRA ++
	+
	LDA #!SetX
	EOR #$FF
	INC
	++
	STA !B6,x

	LDA #!SetY
	STA !AA,x

	endif


	if !Momentum

	if !MomentX != $0000

	LDA $7B
	BMI +
	TAY
	REP #$20
	LDA #!MomentX
	JSR Multiply
	LSR #4
	CMP #$0100
	SEP #$20
	BCS ++++
	CMP #$00
	BPL +++
	++++
	LDA #$7F
	+++
	CLC
	ADC !B6,x
	BVC +++
	
	JSR Sign

	+++
	STA !B6,x
	BRA ++
	+

	TAY
	REP #$20
	LDA #!MomentX
	JSR Multiply
	LSR #4
	CMP #$0F00
	SEP #$20
	BCC ++++
	CMP #$00
	BMI +++
	++++
	LDA #$80
	+++
	CLC
	ADC !B6,x
	BVC +++

	JSR Sign

	+++
	STA !B6,x
	
	++
	endif

	if !MomentY != $0000

	LDA $7D
	BMI +
	TAY
	REP #$20
	LDA #!MomentY
	JSR Multiply
	LSR #4
	CMP #$0100
	SEP #$20
	BCS ++++
	CMP #$00
	BPL +++
	++++
	LDA #$7F
	+++
	CLC
	ADC !AA,x
	BVC +++
	
	JSR Sign
	
	+++
	STA !AA,x
	BRA ++
	+

	TAY
	REP #$20
	LDA #!MomentY
	JSR Multiply
	LSR #4
	CMP #$0F00
	SEP #$20
	BCC ++++
	CMP #$00
	BMI +++
	++++
	LDA #$80
	+++
	CLC
	ADC !AA,x
	BVC +++
	
	JSR Sign

	+++
	STA !AA,x
	
	++
	endif


	endif

	if !CapX

	LDA !B6,x
	BMI +
	CMP #!MaxX
	BCC ++
	LDA #!MaxX
	STA !B6,x
	BRA ++
	+
	CMP.B #($0100-!MaxX)
	BCS ++
	LDA.B #($0100-!MaxX)
	STA !B6,x
	++
	endif	

	if !CapY

	LDA !AA,x
	BMI +
	CMP #!MaxY
	BCC ++
	LDA #!MaxY
	STA !AA,x
	BRA ++
	+
	CMP.B #($0100-!MaxY)
	BCS ++
	LDA.B #($0100-!MaxY)
	STA !AA,x
	++
	endif

	RTS

Sign:
	AND #$80
	BNE +
	LDA #$80
	RTS
	+
	LDA #$7F
	RTS


;Multiplies A (16 bit) by Y (8 bit) - Output A low 16 bits, Y 8 overflow bits for 24 bit result
Multiply:
	if !sa1 == 0
		sep #$20
		sta $211b
		xba
		sta $211b
		sty $211c
		sty $211c
		rep #$20
		lda $2134
		ldy $2136
	else
		SEP #$20
		STZ $2250				

		REP #$20				
		STA $2251				
		TYA
		AND #$00FF
		STA $2253				

		NOP     				
		BRA $00 

		LDA $2306
		LDY $2308				

	endif
	rts