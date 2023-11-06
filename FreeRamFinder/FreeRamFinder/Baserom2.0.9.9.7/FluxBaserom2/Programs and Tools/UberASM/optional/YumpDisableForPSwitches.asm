; By Francium, only tiny modification by SJC. Example INC $19.

!freeram = $0EE1

main:
	LDA !freeram|!addr
	BNE .Return
	LDA $14AD|!addr
	CMP #$B0 : BNE +
	BRA ++
+
	LDA $14AE|!addr
	CMP #$B0 : BNE .Return
++
	LDA $16 : ORA $18
	BEQ .Return
	LDA #$80 : TRB $16 : TRB $18 ; you can change to whatever. E.g. INC $19 is powerup. 
.Return
	LDA #$01 : STA !freeram|!addr
	LDA $14AD|!addr
	CMP #$B0 : BEQ +
	LDA $14AE|!addr
	CMP #$B0 : BEQ +
	STZ !freeram|!addr
+
	RTL