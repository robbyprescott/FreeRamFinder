; This simple template can be used in gamemode,
; to run your code in all levels EXCEPT the ones you specify.

; Put your code where it says "Your code goes over there".
; Add the level numbers after Exclude, prefaced by dw and separated by a comma, 
; such as dw $0105, dw $0117, etc.

; Change main label(s) if needed.


Exclude: 
dw $0105, dw $0117, dw $013B ; example level numbers

; Don't insert any other labels (or tables) right at this spot

main:
LDY.b #(main-2)-Exclude
REP #$20
LDA $010B|!addr
.loop
CMP.w Exclude,y
BEQ Return
DEY #2
BPL .loop
SEP #$20

INC $19 ; <- Your code goes over there

Return:
SEP #$20
RTL