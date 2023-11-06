print "You have a limited number of jumps you can do off of this block before it poofs."

db $42
JMP Return : JMP MarioAbove : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return
JMP MarioAbove : JMP Return : JMP Return

MarioAbove:
	 LDA $16		;\
	 ORA $18		; | Check for jump, or you could just LDA $72
	 BPL Return
     LDA #$10
	 STA $1DF9
     REP #$10				;   16-bit XY
     LDX $03					; \ 
     INX						; / Load next Map16 number
     %change_map16()			;   Change the block
     SEP #$10				;   8-bit XY	
Return:
	 RTL
