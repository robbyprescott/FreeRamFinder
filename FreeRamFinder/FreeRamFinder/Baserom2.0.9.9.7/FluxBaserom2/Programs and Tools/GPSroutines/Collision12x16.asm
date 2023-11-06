;Output:
;Carry is set if player's X pos is 6 or less pixels away
;from center of block.
	REP #$20
	LDA $9A
	AND #$FFF0
	SEC
	SBC $94
	BPL +
	EOR #$FFFF		;\flip if negative
	INC				;/(absolute distance)
+
	CMP #$0006
	SEP #$20
	BPL +
	SEC
	RTL
+
	CLC
	RTL