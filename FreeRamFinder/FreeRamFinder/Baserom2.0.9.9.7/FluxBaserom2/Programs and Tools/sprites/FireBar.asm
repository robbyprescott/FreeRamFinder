;Customized Firebar
;by Isikoro

Fireball_Tile:	db $2C,$2D,$2C,$2D	;Small
				db $A6,$AA,$A6,$AA	;Big
Fireball_Prop:	db $04,$04,$C4,$C4	;Small
				db $05,$05,$C5,$C5	;Big

Clip_Size:		db $06,$00,$0C
Clip_Disp:		dw $0001,$0002

					print "INIT ",pc
					LDA !extra_byte_1,x	
					STA !AA,x
					
					AND #$20 : BNE +
					LDA !E4,x : ORA #$04 : STA !E4,x
					LDA !D8,x : ORA #$04 : STA !D8,x
					
+					LDA !extra_byte_2,x	: STA $0F
					AND #$7F : STA !B6,x
					
					LDA !extra_bits,x : AND #$04
					BEQ +
					LDA !B6,x : EOR #$FF : INC : STA !B6,x
					
+					LDA !extra_byte_3,x : TAY
					ASL #5 : ORA #$08 : STA !C2,x
					TYA : LSR #3 : STA !1504,x
					
					LDA !extra_prop_2,x
					BEQ .UnUsed_Table
					LDA !extra_byte_1,x	: STA $0F
					AND #$40 : STA !1594,x
					BRA Init_Not_Pendulum
.UnUsed_Table:		LDA !extra_byte_4,x
					TAY : LSR #4 : STA $00
					TYA : ASL #4 : ORA $00
					STA !extra_byte_4,x
					AND #$08 : STA !1594,x
					
					TYA
					AND #$F7 : BEQ Init_Not_Pendulum
					
					LDA !extra_bits,x : AND #$FB
					LDY !B6,x : BMI +
					ORA #$04
+					STA !extra_bits,x
					
Init_Not_Pendulum:	LDA !E4,x : STA $04	: LDA !14E0,x : STA $05
					LDA !D8,x : STA $06 : LDA !14D4,x : STA $07
					
					LDA !1594,x : BEQ +
					
					REP #$20
					
					SEC : LDA $1A : SBC $1E : STA $00
					SEC : LDA $1C : SBC $20 : STA $02
					
					CLC : LDA $04 : ADC $00 : STA $04
					CLC : LDA $06 : ADC $02 : STA $06
					
					SEP #$20
					
					STA !D8,x : XBA : STA !14D4,x
					LDA $04 : STA !E4,x : LDA $05 : STA !14E0,x
					
+					LDA !extra_prop_1,x
					BEQ No_Shift
					
					CLC
					LDA !AA,x : BIT #$20 : BEQ $01 : SEC
					AND #$1F : BCC $01 : ASL
					SBC #$03 : BCC No_Shift
					AND #$FE : ASL #3 : STA $08
					LDA $5B : LSR
					BCS Shift_Vert
					
					LDA $0F : BMI Shift_Left
					LDA !14E0,x : XBA : LDA !E4,x
					REP #$20 : CMP $94
					SEP #$20 : BMI Shift_Erase
Shift_Right:		CLC
					LDA !E4,x : ADC $08 : STA !E4,x
					BCC Overlap_Check : INC !14E0,x
					BRA Overlap_Check
					
No_Shift:			RTL
					
Shift_Left:			SEC
					LDA !E4,x : SBC $08 : STA !E4,x
					BCS Overlap_Check : DEC !14E0,x
					BRA Overlap_Check
					
Shift_Vert:			LDA $0F : BMI Shift_Top
					CLC
					LDA !D8,x : ADC $08 : STA !D8,x
					BCC Overlap_Check : INC !14D4,x
					BRA Overlap_Check
					
Shift_Top:			SEC
					LDA !D8,x : SBC $08 : STA !D8,x
					BCS Overlap_Check : DEC !14D4,x
					BRA Overlap_Check
					
Overlap:			LDX $0E
Shift_Erase:		LDA #$80 : STA !14E0,x : STA !14D4,x
					%SubOffScreen_New()
					RTL

Overlap_Check:		LDA !extra_byte_1,x : STA $0C
					LDA !extra_byte_3,x : STA $0D
					LDA !extra_bits,x : STA $0B
					STZ $00 : STZ $01
					LDA $17BE|!Base2 : BPL $02 : DEC $00
					LDA $17BF|!Base2 : BPL $02 : DEC $01
					LDA !7FAB9E,x
					STA $0F : STX $0E
					TXY
					LDX #!SprSize-1
.Loops:				CPX $0E : BEQ .Next
					LDA !7FAB9E,x
					CMP $0F : BEQ .Position_Check
.Next:				DEX : BPL .Loops
					LDX $0E
					RTL
					
.Position_Check:	LDA !14C8,x : CMP #$08 : BNE .Next
					LDA !extra_byte_1,x : CMP $0C : BNE .Next
					LDA !extra_byte_3,x : CMP $0D : BNE .Next
					LDA !extra_bits,x : CMP $0B : BNE .Next
					
					CPX $0E : BCS .Layer2_Interlocking
					LDA !D8,x : CMP !D8,y : BNE .Next
					LDA !14D4,x : CMP !14D4,y : BNE .Next
					LDA !E4,x : CMP !E4,y : BNE .Next
					LDA !14E0,x : CMP !14E0,y : BNE .Next
					JMP Overlap
					
.Layer2_Interlocking:
					LDA !D8,y : SBC $17BE|!Base2 : XBA
					LDA !14D4,y : SBC $00 : CMP !14D4,x : BNE .Next
					XBA : CMP !D8,x : BNE .Next
					SEC
					LDA !E4,y : SBC $17BF|!Base2 : XBA
					LDA !14E0,y : SBC $01 : CMP !14E0,x : BNE .Next
					XBA : CMP !E4,x : BNE .Next
					JMP Overlap
					
                    print "MAIN ",pc
                    PHB : PHK : PLB
                    JSR START_SPRITE_CODE
                    PLB
                    RTL
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Carry_Offset:		db $00,$FF
					
START_SPRITE_CODE:	LDA $13D8|!Base2 : STA $08
					LDA !14E0,x : STA $09
					LDA $5B : AND #$01
					BEQ .Horizontal
					STA !14E0,x					;レイヤー２と共に動かして
.Horizontal:		LDA #$40 : STA $13D8|!Base2 ;コースから出ても消えないように
					LDA !AA,x
					AND #$20
					LSR #3 : STA $D7 			;ファイアボールのサイズが小なら00、大なら04
					LDA !AA,x
					AND #$1F : STA $0C			;ファイアボールの数－１
					ASL #3
					LDY $D7 : BEQ $01 : ASL
					
					%SubOffScreen_New()
					
					LDA $09 : STA !14E0,x
					LDA $08 : STA $13D8|!Base2
					
					LDA !extra_prop_2,x : BEQ UnUsed_Table
					BMI Table_16Bit
					AND #$7F : STA $0B
					LDA !extra_byte_3,x : STA $09
					LDA !extra_byte_4,x : STA $0A
					LDA [$09]
					CLC : ADC !extra_byte_2,x
					TAY
					LDA !extra_bits,x
					AND #$04 : BEQ Table_Clockwise
					TYA : EOR #$FF : INC : TAY
Table_Clockwise:	TYA : LSR #3 : XBA
					TYA : ASL #5 : ORA #$08
					BRA Use_Table
Table_16Bit:		AND #$7F : STA $0B
					LDA !extra_byte_3,x : STA $09
					LDA !extra_byte_4,x : STA $0A
					LDA !extra_bits,x : AND #$04 : PHA
					REP #$20
					LDA !extra_byte_2-1,x : AND #$FF00 : LSR #3
					CLC : ADC [$09] 
					PLY : BEQ Use_Table+2
					EOR #$FFFF : INC
					BRA Use_Table+2
					
UnUsed_Table:		LDA !1504,x : XBA : LDA !C2,x
Use_Table:			REP #$20
					LSR #4 : STA $04
					DEC : LSR : SEP #$21
					SBC #$C0 : STA $0F
					LDA !extra_byte_1,x : AND #$C0
					STA $0E
					SEC
					LDA $0F : SBC $0E : STA $0F
					
Circle:				REP #$30
					LDA $04
					AND #$00FF : ASL : TAX		;cos_index
					EOR #$0100 : TAY			;sin_index
					LDA $04 : LSR : STA $D5
					LDA $07F7DB|!BankB,x
					ASL #3
					TYX					;sin
					
					LDY $D4
					BPL $04 : EOR #$FFFF : INC
					STA $0DD1|!Base2		;Vertical spacing between fireballs

					LDA $07F7DB|!BankB,x
					ASL #3
					
					CPY #$C000
					BPL $04 : EOR #$FFFF : INC
					STA $0DCF|!Base2		;Horizontal spacing between fireballs
					SEP #$30
					
					LDX $15E9|!Base2
					
					LDA !14C8,x	: CMP #$08 : BNE RETURN_
					LDA $9D : BNE RETURN_
					LDA !extra_prop_2,x : BNE With_Layer2_
					
					LDA !extra_byte_4,x : TAY
					AND #$F7 : BEQ Not_Pendulum
					AND #$07 : STA $05
					TYA : AND #$F0 : STA $06 ; Accumulating fraction bits for fixed point Rotational speed.
					LDY $0F : CPY #$7F : BEQ ++
					BCS To_Counter
					
To_Clockwise:		LDA !151C,x : ADC $06 : STA !151C,x
					LDA !B6,x : ADC $05 : STA !B6,x
					LDA !extra_bits,x
					BCC Pendulum_Return : ORA #$04 : STA !extra_bits,x
					BRA Pendulum_Return
					
++					LDA !extra_bits,x
					BRA Pendulum_Return
					
To_Counter:			LDA !151C,x : SBC $06 : STA !151C,x
					LDA !B6,x : SBC $05 : STA !B6,x
					LDA !extra_bits,x
					BCS Pendulum_Return : AND #$FB : STA !extra_bits,x
					
Pendulum_Return:	LDY #$00
					AND #$04 : BNE $01 : INY
+					LDA !B6,x : CLC : ADC !C2,x : STA !C2,x
					LDA !1504,x : ADC Carry_Offset,y : STA !1504,x
With_Layer2_:		BRA With_Layer2
RETURN_:			BRA RETURN
					
Not_Pendulum:		LDY #$00
					LDA !AA,x : BIT #$C0
					BEQ ONOFF_Unrelated
					BPL ONOFF_Inversion
					
					CLC : AND #$40 : ROL #3 : EOR $14AF|!Base2 : BEQ With_Layer2
					
ONOFF_Inversion:	LDA $14AF|!Base2 : BEQ ONOFF_Unrelated
					LDA !B6,x : EOR #$FF : INC : BRA +
					
ONOFF_Unrelated:	LDA !B6,x
+					BPL $01 : INY
					CLC : ADC !C2,x : STA !C2,x
					LDA !1504,x : ADC Carry_Offset,y : STA !1504,x
					
With_Layer2:		LDA !1594,x : BEQ RETURN
					
					SEC : LDY #$00
					LDA $17BE|!Base2 : BPL $01 : INY
					LDA !D8,x : SBC $17BE|!Base2 : STA !D8,x
					LDA !14D4,x : SBC Carry_Offset,y : STA !14D4,x
					
					SEC : LDY #$00
					LDA $17BF|!Base2 : BPL $01 : INY
					LDA !E4,x : SBC $17BF|!Base2 : STA !E4,x
					LDA !14E0,x : SBC Carry_Offset,y : STA !14E0,x
					
RETURN:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
.FireBar_GetDrawInfo:
   STZ !186C,x
   LDA !14E0,x
   XBA
   LDA !E4,x
   REP #$20
   SEC : SBC $1A
   STA $00
   CLC
   ADC.w #$0040
   CMP.w #$0180
   SEP #$20
   LDA $01
   BEQ +
   LDA #$01
+  STA !15A0,x
   TDC
   ROL A
   STA !15C4,x

   LDA !14D4,x
   XBA
   LDA !190F,x
   AND #$20
   BEQ .CheckOnce
.CheckTwice
   LDA !D8,x
   REP #$21
   ADC.w #$001C
   SEC : SBC $1C
   SEP #$20
   LDA !14D4,x
   XBA
   BEQ .CheckOnce
   LDA #$02
.CheckOnce
   STA !186C,x
   LDA !D8,x
   REP #$21
   ADC.w #$000C
   SEC : SBC $1C
   SEP #$21
   SBC #$0C
   STA $01
   XBA
   BEQ .OnScreenY
   INC !186C,x
.OnScreenY
   LDY !15EA,x
					LDA $00 : STA $0E			;Center axis drawing X position
					LDA $01 : DEC : STA $D6		;Center axis drawing Y position
					STZ $D5 : STZ $0D			;Multiply the number by 16.
					
					STY $0F					;Fireball_Clipping
					LDA $D7 : LSR : TAY
					LDA Clip_Size,y : STA $0DC7|!Base2
					STZ $0DC8|!Base2
					LDA Clip_Disp,y
					CLC : ADC !E4,x : STA $04
					LDA !14E0,x : ADC #$00 : STA $05
					LDA Clip_Disp,y
					CLC : ADC !D8,x : STA $0A
					LDA !14D4,x : ADC #$00 : STA $0B
					
					JSL $03B664|!BankB
					LDA $01 : XBA : LDA $08
					STA $01 : XBA : STA $08
					LDA $03 : STA $0DC9|!Base2
					STZ $03 : STZ $0DCA|!Base2
					
					REP #$21
					STZ $06
					LDA $1A : PHA : ADC Clip_Disp,y : STA $1A
					CLC
					LDA $1C : PHA : ADC Clip_Disp,y : STA $1C
					SEP #$20
					
					LDA $0DD0|!Base2 : BPL $02 : DEC $06
					LDA $0DD2|!Base2 : BPL $02 : DEC $07
					
					LDA $14 : AND #$0C : LSR #2
					ADC $D7 : TAX : STY $D7
					
					TYA : BEQ .Small
					
					PHX
					LDY $0F
					
					LDA $0E : STA $0300|!Base2,y
					LDA $D6 : STA $0301|!Base2,y
					
					REP #$21
					LDA $0D : ADC $0DCF|!Base2 : STA $0D
					CLC : LDA $D5 : ADC $0DD1|!Base2 : STA $D5
					
					ASL $0DCF|!Base2 : ASL $0DD1|!Base2
					
					SEP #$21
					LDA $0E : SBC $0300|!Base2,y
					TAX	: BEQ $02 : LDX $06
					CLC : ADC $04 : STA $04
					TXA : ADC $05 : STA $05
					
					SEC
					LDA $D6 : SBC $0301|!Base2,y
					TAX	: BEQ $02 : LDX $07
					CLC : ADC $0A : STA $0A
					TXA : ADC $0B : STA $0B
					
					PLX
					
.Small:				LDY $0F
					
					LDA Fireball_Tile,x
					STA $0DCB|!Base2
					LDA Fireball_Prop,x
					ORA $64 : STA $0DCC|!Base2
					
					STZ $0DD3|!Base2
					LDX $0C : CPX #$10 : BCS +
					LDA !B6,x : CMP #$40 : BCS +
					STA $0DD3|!Base2
+					LDA $D7 : BEQ .No_Contact
					
.Loops:				;.Fireball_Contact:	; 内側→外側
					LDA $0DD3|!Base2 : BEQ .EveryFrame
					TXA : EOR $14 : LSR : BCC .No_Contact
.EveryFrame:		
	REP #$20
.checkX:
	LDA $00
	CMP $04
	BCC .checkXSub2
.checkXSub1:
	SBC $04
	CMP $0DC7|!Base2
	BCS .returnNoContact
	BRA .checkY
.checkXSub2:
	LDA $04
	SEC : SBC $00
	CMP $02
	BCS .returnNoContact
.checkY:
	LDA $08
	CMP $0A
	BCC .checkYSub2
.checkYSub1:
	SBC $0A
	CMP $0DC7|!Base2
	BCS .returnNoContact
.returnContact:
	SEP #$20
.Contact:			PHY
					LDA $187A|!Base2
					BEQ .No_Yoshi : %LoseYoshiOrHurt()
					BRA .Yoshi_Ran_away
.No_Yoshi:			JSL $00F5B7|!BankB
					;REP #$10
					;LDY #$1000 : DEY : BNE $FD
					;SEP #$10
.Yoshi_Ran_away:	PLY
					BRA .No_Contact
.checkYSub2:
    LDA $0A
    SEC : SBC $08
    CMP $0DC9|!Base2
    BCC .returnContact
.returnNoContact:
    SEP #$20
.No_Contact:		LDA $0E : STA $0300|!Base2,y
					LDA $D6 : STA $0301|!Base2,y
					
					DEX : BPL $03
					JMP .Write_End
					PHX
					
					TYA : LSR #2 : TAX
					LDA $D7 : STA $0460|!Base2,x
					
					LDA #$04 : STA $0F
					REP #$20
					LDA $0DCB|!Base2 : STA $0302|!Base2,y
					SEC : LDA $04 : SBC $1A : BPL +
					INC $0460|!Base2,x
+					CMP #$0100 : BPL .OverScreen
					CMP #$FFF0 : BMI .OverScreen
					SEC : LDA $0A : SBC $1C
					CMP #$00E0 : BPL .OverScreen
					CMP #$FFF0 : BMI .OverScreen
					BRA .OnScreen_X
					
.OverScreen:		LDX #$00 : STX $0F
					
.OnScreen_X:		CLC : LDA $0D : ADC $0DCF|!Base2 : STA $0D
					CLC : LDA $D5 : ADC $0DD1|!Base2 : STA $D5
					
					SEP #$21
					LDA $0E : SBC $0300|!Base2,y
					TAX	: BEQ $02 : LDX $06
					CLC : ADC $04 : STA $04
					TXA : ADC $05 : STA $05
					
					SEC
					LDA $D6 : SBC $0301|!Base2,y
					TAX	: BEQ $02 : LDX $07
					CLC : ADC $0A : STA $0A
					TXA : ADC $0B : STA $0B
					
					CLC : TYA : ADC $0F : TAY
					PLX
					
					JMP .Loops
					
.Write_End:			TYA : LSR #2 : TAX
					LDA $D7 : STA $0460|!Base2,x
					
					REP #$20
					LDA $0DCB|!Base2 : STA $0302|!Base2,y
					SEC : LDA $04 : SBC $1A : BPL +
					INC $0460|!Base2,x
+					CMP #$0100 : BPL ..OverScreen
					CMP #$FFF0 : BMI ..OverScreen
					SEC : LDA $0A : SBC $1C
					CMP #$00E0 : BPL ..OverScreen
					CMP #$FFF0 : BMI ..OverScreen
					BRA ..OnScreen_X
					
..OverScreen:		LDA #$F000 : STA $0300|!Base2,y
..OnScreen_X:		LDX $15E9|!Base2
					
					PLA : STA $1C
					PLA : STA $1A
					SEP #$20
					
					RTS
					