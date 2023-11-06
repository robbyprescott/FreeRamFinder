; Note that this simple code doesn't apply to LM levels 25-100

init:
LDX $13BF			;>Load index for translevel number (LM levels $025 to $100 excluded)
LDA $1EA2,x			;>Load current level status that the player has entered (excludes $025 to $100)
BPL Return
INC $19 ; your code
Return:
RTL