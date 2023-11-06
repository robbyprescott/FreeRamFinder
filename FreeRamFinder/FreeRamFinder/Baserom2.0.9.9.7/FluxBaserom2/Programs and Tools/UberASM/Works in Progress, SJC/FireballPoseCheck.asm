!RAM = $14AF

main:
     LDA $13E0
     CMP #$16 ; 16, in air fireball pose
     BNE Next
     BRA DoThing
Next:
     CMP #$3F ; 3F, normal ground fireball pose
     BNE Return
DoThing:
	 LDA !RAM
	 BNE End
	 INC $13CC ; coin count
	 LDA #$01
     STA !RAM
	 BRA End
Return:
     STZ !RAM
End:
     RTL