; By SJC

!HowDark = $02 ; the lower the value, the darker. $0F is vanilla
!Trigger = $14AF ; on/off
!RestoreNormal = $0F

main:
LDA $9D                    ; Necessary to prevent pixelation on teleport or respawn, etc.
ORA $13D4|!addr             
;LDA $13E0
;CMP #$3E                
BEQ End                 

LDA !Trigger 
BEQ Default
LDA #!HowDark	
STA $0DAE
BRA End

Default:
LDA #!RestoreNormal		; 
STA $0DAE       ; Restore brightness.
End:
RTL