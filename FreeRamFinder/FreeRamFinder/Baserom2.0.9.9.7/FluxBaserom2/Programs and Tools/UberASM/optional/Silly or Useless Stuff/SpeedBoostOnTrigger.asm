; By JamesD28, minor edits by SJC
; Note that swim speed won't be affected unless !EvenMoreSpeed enabled

!Trigger = $14AF ; on/off
!EvenMoreSpeed = 0 ; set to 1 to increase even more, kinda ridiculous

main:
LDA $9D
ORA $13D4|!addr 
BNE end

LDA !Trigger ; $0F31 for time-low
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
CMP #$38
BCS +
INC $7B
if !EvenMoreSpeed
INC $7B
endif
RTL
left:
LDA $7B
CMP #-$38
BCC +
DEC $7B
if !EvenMoreSpeed
DEC $7B
endif
RTL
+
LDA #$70
STA $13E4|!addr
end:
RTL