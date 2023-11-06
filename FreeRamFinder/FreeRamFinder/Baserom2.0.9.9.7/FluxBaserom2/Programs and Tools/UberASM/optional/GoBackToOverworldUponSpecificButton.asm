; Teleport if press select while holding L or R

main:

STZ $1401 ; prevent screen scroll if enabled

LDA $17				;check if controller button is held
AND #$20			;L button
LDA $16				;check if controller button is newly pressed.
AND #$40			;Select button
BEQ Return			;
BRA Thing
RTL

LDA $17				;check if controller button is held
AND #$10			;R button
LDA $16				;check if controller button is newly pressed.
AND #$40			;Select button
BEQ Return			;
Thing:
        LDA #$01
        STA $1B96|!addr

        LDA #$06
        STA $13D9|!addr

        STZ $0109|!addr                
        STZ $0DD5|!addr              
        LDA #$0B                
        STA $0100|!addr 
        
Return:	
RTL
	