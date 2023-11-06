; 	Sticky Block by NaroGugul

;	Will stick to it most of the sprites that can be carried:
;	Shells, goombas, beetles, baby yoshy, springs, p-switchs, throw blocks and Keys

!HowFar = $02 ; how far into the side of wall it goes. Default was $08


!Table1 = $7FA105	;store x position
!Table2 = $7FA205 	;store y position
!Table3 = $1FD6 	;Status: 00 = Initial sprite status / set when carried; 01 = Stuck

db $37

JMP Return : JMP Return : JMP Return
JMP Sticky : JMP Sticky
JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
JMP Return : JMP Return




Sticky:
	LDA $9E,x 
	CMP #$0E : BCC CheckState	; shell
	CMP #$0F : BEQ CheckState	; goomba
	CMP #$11 : BEQ CheckState	; buzzy beetle
	CMP #$2D : BEQ CheckState	; baby yoshi
	CMP #$2F : BEQ Stick		; spring
	CMP #$02 : BEQ CheckState	; blue koopa, no shell
	CMP #$3E : BEQ CheckState	; p-switch
	CMP #$53 : BEQ CheckState	; throw block
	CMP #$80 : BEQ CheckState	; Key
	
NOTSticky:
	LDA #$00 : STA !Table1,x
RTL
CheckState:
	LDA $14c8,x
	CMP #$08 : BEQ Stick
	CMP #$09 : BEQ Stick
	CMP #$0A : BEQ Stick
	CMP #$0B : BNE +
	LDA #$00 : STA !Table3,x
	+	BRA NOTSticky

Stick:

	LDA #$25				; \ Make this block passable.
	STA $1693				; |
	LDY #$00				; /
	

	LDA !Table3,x
	BNE +
		
		LDA $B6,x : BEQ +++
		BPL ++ : DEC $E4,x : BRA +++
		++	INC $E4,x
		+++
		
		LDA $E4,x : AND #$F0 : CLC : ADC #!HowFar : STA !Table1,x	; Store x ;;;;;;;;; 
		LDA $D8,x : STA !Table2,x ; Store y
		LDA #$01 : STA !Table3,x	; Set status
		BRA SetSpeed
	+
	

	
	LDA !Table1,x : STA $E4,x
	; LDA !Table2,x
	;Centralizar Y
		; AND #$0F : BEQ ++
		; LDA !Table2,x : SEC : SBC #$01 : STA !Table2,x
		; BRA +++
		; ++
		; LDA !Table2,x
	; +++
		%sprite_block_position()
		LDA $98
		STA $D8,x
	
	SetSpeed:
		STZ $B6,x
		%sprite_block_position()
		LDA $E4,x : STA $0E
		LDA $14E0,x : STA $0F
		LDA $D8,x : STA $0C
		LDA $14D4,x : STA $0D
		REP #$20
		LDA $9A : CMP $0E
		SEP #$20
		BCC + ; lesser
			LDA #$30 : STA $B6,x : BRA ++
		+
			LDA #$D0 : STA $B6,x
		++

		LDA $AA,x : BPL + : LDA #$FC : STA $AA,x : BRA Return
		+	LDA #$05 : STA $AA,x : BRA Return
	
	
Return:
RTL

print "Block which will stick to it most of the sprites that can be carried"
