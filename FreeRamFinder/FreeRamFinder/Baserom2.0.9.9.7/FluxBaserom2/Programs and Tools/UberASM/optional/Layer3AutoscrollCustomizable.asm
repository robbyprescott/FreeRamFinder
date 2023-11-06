; Will scroll left unless trigger set, then will scroll right.

!ScrollingSpeed = $02 ; $02 is medium speed. $01 is pretty slow.
!Trigger = $14AF

main:
     ;LDA $71	
     ;CMP #$09 ; Death check, but already done
     ;BEQ End
	 LDA $9D  ; Pause/freeze check
     ORA $13D4                          
     BNE End
	 
     LDA $14
     AND #$01
     BNE End
     LDA !Trigger
     BNE Switch ; Starts left. Change to BEQ for right.
     LDA $22 ; Layer 3 x-Position 
     CLC ;  
     ADC #!ScrollingSpeed
     STA $22 
     LDA $23 ; Layer 3 x-Position (high byte)
     ADC #$00 
     STA $23 
     BRA End
Switch:
     LDA $22 ; Layer 3 x-Position 
     SEC  
     SBC #!ScrollingSpeed 
     STA $22 
     LDA $23 
     SBC #$00 
     STA $23 
End:
     RTL 