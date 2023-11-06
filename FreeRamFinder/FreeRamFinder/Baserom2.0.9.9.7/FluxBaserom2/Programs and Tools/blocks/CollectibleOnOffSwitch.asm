db $42

JMP Main : JMP Main : JMP Main
JMP Return : JMP Return : JMP Return : JMP Return
JMP Main : JMP Main : JMP Main

Main:
LDA $14AF|!addr	; change on/off status
EOR #$01
STA $14AF|!addr
LDA #$0B		; sfx
STA $1DF9|!addr
%glitter()
%erase_block()
Return:
RTL

print "A collectible one-use ON/OFF switch."