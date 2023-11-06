; Or you can use a variant of GFX00.asm 
; to make this into more frequent underwater bubble breathing for Mario


main:
    LDA #$06
	TAY
	LDA !15A0,x
	ORA !186C,x
	BNE Return
	TYA
	DEC !1528,x
	BPL Return
	PHA
	LDA #$28
	STA !1528,x
	LDY #$0B
Loop:
	LDA $17F0|!addr,y
	BEQ FreeSlotFound
	DEY
	BPL Loop
	DEC $185D|!addr
	BPL EndLoop
	LDA #$0B
	STA $185D|!addr
EndLoop:
	LDY $185D|!addr
FreeSlotFound:
	PLA
	STA $17F0|!addr,y
	LDA $94
	CLC
	ADC #$06
	STA $1808|!addr,y
	LDA $96
	CLC
	ADC #$00
	STA $17FC|!addr,y
	LDA #$7F
	STA $1850|!addr,y
	LDA #$FA 
	STA $182C|!addr,y
Return:            
	RTL  