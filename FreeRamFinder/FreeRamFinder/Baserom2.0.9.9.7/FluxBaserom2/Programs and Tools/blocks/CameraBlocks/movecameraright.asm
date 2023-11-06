db $37
JMP Main : JMP Main : JMP Main
JMP Return : JMP Return
JMP Return : JMP Return
JMP Main : JMP Main : JMP Main
JMP Return : JMP Return
Main:
	LDA #$02
	STA $13FE
Return:
RTL
print "Permanently moves the camera rightward (or at least until you use another block to stabilize it). Note that how MUCH the camera is moved to the right actually depends on how long Mario touches these blocks. So if you want the camera to be shifted to the FURTHEST right, one way to do this is to force Mario to quickly pass through a lot of these blocks. (You can also use an Uber I included that will automatically do this at level load.)"