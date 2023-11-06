!FreeRAM = $60

main:
    LDA !FreeRAM
	BNE End     ; can't choose other option unless
	LDA $16
	AND #$2C    ; 4 (down) + 8 (up) + select (20)
	BEQ Unlock
	LDA #$2A
	STA $1DFC   ; "wrong" sound
    LDA #$2C 
    TRB $16
Unlock:	
	LDA $17	
    AND #$30	; L and R together		
    CMP #$30
    BNE End
	LDA #$01
    STA !FreeRAM
    LDA #$10
	STA $1DF9
End:
    RTL