; Use with Uber

db $42
JMP Main : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return	

!DisplayFreeRAM = $14AF ; match PlaylistFunction and PlaylistDisplay Uber

Main:
    LDA $7D			; \ double hit prevention
    BPL Return		; /
	
	REP #$10
	LDX #$132 : %change_map16()
	SEP #$10
	
	LDA #$01 ;
	STA !DisplayFreeRAM ; 
Return:
	RTL
	
	print "Turns on scrollable music playlist when hit. Works with MusicPlaylist.asm UberASM."