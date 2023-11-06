; This is an easy way to enable these things, although you
; you can do the same in Lunar Magic itself, by going into the layer 3 settings,
; enabling forced tile priority and CGADSUB, and being in level mode 0E.

; However, this has other uses too.

init:
	LDA #$04
	STA $212C
	STA $212E
	LDA #$13
	STA $212D
	STA $212F
	LDA #$24
	STA $40
	RTL
	
   ;LDX #$04
   ;LDY #$13

   ;STX $212C
   ;STX $212E

   ;STY $212D
   ;STY $212F