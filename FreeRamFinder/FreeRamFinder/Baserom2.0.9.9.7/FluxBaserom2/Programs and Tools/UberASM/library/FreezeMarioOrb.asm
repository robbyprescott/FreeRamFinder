; For use with custom goal sphere, etc.

!TriggerRAM = $0E6F

main:

    LDA !TriggerRAM
	BEQ Return
	LDA $0E2D ; unless
	BNE Return
	STZ $7B ; Mario won't move at all, or even fall,
	STZ $7D ; so you can place him anywhere on-screen
	
	;LDA #$FF ; Mario won't be hurt by sprites
    ;STA $1497|!addr
	
    LDA #$FF
    STA $0DAA
    STA $0DAC
    STZ $15 ; no controls
    STZ $17
	Return:
    RTL