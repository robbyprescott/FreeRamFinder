; Re-tooled JamesD28 Uber, SJC
; Note that will also increase your walking/speed on the ground while in water, 
; unless you add a ground check ($72)

!Value = $16

main:
LDA $9D
ORA $13D4|!addr
BNE end

LDA $75 ; water
BEQ end

LDA $15
BIT #$40
BEQ end
BIT #$03
BEQ end
BIT #$04
BEQ +
LDA $72
BEQ end
LDA $15
+
BIT #$01
BEQ left
LDA $7B
CMP #!Value
BCS +
INC $7B
INC $7B
RTL
left:
LDA $7B
CMP #-!Value
BCC +
DEC $7B
DEC $7B
RTL
+
LDA #$70
STA $13E4|!addr
end:
RTL