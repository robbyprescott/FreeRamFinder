db $42

JMP Main : JMP Main : JMP Main
JMP return : JMP return : JMP return : JMP return
JMP Main : JMP Main : JMP Main

Main:
	LDY #$01
	LDA #$30
	STA $1693|!addr
return:
RTL

print "This block is solid for Mario, but acts like a 1F0 for sprites and fireballs. Fireballs won't bounce on it, and it can be used to immobilize enemies."