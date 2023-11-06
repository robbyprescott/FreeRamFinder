!Speed = $E0 ; $80-$FF, with $80 being the fastest 

main:
	LDA $15       ; this checks 
    EOR $17       ; if only B
    BPL OrSpin    ; is held
	LDA $140D
	CMP #$01      ; Check if already spinning
	BEQ End       ; If not,
	LDA #$35      ; Regular jump sound
	STA $1DFC
	BRA Ascent
OrSpin:
    LDA $17
	AND #$80
	BEQ Almost 
	LDA #$04
	STA $1DFC     ; Spin jump sound
    LDA #$01      ; constant spin state
    STA $140D 	
Ascent:
	LDA #!Speed
	STA $7D
	BRA End
Almost:
    STZ $140D   ; If you don't include, will continue to spin even when you let go of A
    
	;LDA $16
	;AND #$80
	;BEQ End
    ;LDA $140D     ; Check if still spin
	;CMP #$01
    ;BNE End	
    ;LDA $16
	;AND #$80      ; Check if B press
	;BEQ End
	;STZ $140D
	;BNE End
	;LDA #$02
	;STA $19
    ;STZ $140D
	;BRA Ascent
End:	
	RTL