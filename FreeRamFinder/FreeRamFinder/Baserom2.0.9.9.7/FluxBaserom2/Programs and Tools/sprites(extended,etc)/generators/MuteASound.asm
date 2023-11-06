; This will prevent the specified sound effect from playing in any level you have 
; this sprite generator in. (Currently set to kill the midway sound.) 
; See here for values: https://www.smwcentral.net/?p=viewthread&t=6665 

Print "INIT ",pc
Print "MAIN ",pc

LDA $1DF9
CMP #$05 ;  midway sound
BNE +
STZ $1DF9 ; kill sound
+
RTL