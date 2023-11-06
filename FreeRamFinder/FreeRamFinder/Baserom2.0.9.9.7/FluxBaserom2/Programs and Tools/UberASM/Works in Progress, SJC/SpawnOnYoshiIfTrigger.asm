!Trigger = $14AF ; Watch out if trigger solid block. Spawning on Yoshi
                 ; will clip you into a trigger block hit from below

main:
     LDA !Trigger 
	 BEQ Return
     ;LDA $187A 
	 ;BNE Return ; Prevents multiple spawning jank by checking if already on Yoshi?
     LDA #$0A    ; green
     STA $13C7   ; Yoshi color
	 PHY	
     JSL $00FC7A
     PLY
	 LDA #$1F
	 STA $1DFC
	 STZ !Trigger ; need to make sure that immediately reverts after, so it's not constantly spawning you
	 Return:
	 RTL