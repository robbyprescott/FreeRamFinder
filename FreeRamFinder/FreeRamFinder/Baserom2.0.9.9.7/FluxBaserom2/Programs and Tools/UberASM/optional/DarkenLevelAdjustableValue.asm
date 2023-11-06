!HowDark = $08 ; the lower the value, the darker. $0F is vanilla

main:
LDA $9D                    ; Necessary to prevent pixelation on teleport or respawn, etc.
ORA $13D4|!addr                           
BEQ End                 
LDA #!HowDark	
STA $0DAE
End:
RTL