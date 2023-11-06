; Disables the possibility of turnaround

main:
LDA $1407 
BEQ Return
LDA #$40    ; disables X but not Y (but allows hold). 
TSB $0DAC
Return:
RTL