; This code will reload the current room.
; SJC: added two fixes

main:
        LDA $010B|!addr
    	STA $0C
    	LDA $010C|!addr
	    ORA #$04
    	STA $0D
    	JSL LRReset
		RTL