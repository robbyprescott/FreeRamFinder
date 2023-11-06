db $42
JMP Scroll : JMP Scroll : JMP Scroll : JMP Return : JMP Return : JMP Return : JMP Return
JMP Scroll : JMP Scroll : JMP Scroll

Scroll:
LDA #$01
STA $1411

Return:
RTL

print "Enables horizontal camera movement."