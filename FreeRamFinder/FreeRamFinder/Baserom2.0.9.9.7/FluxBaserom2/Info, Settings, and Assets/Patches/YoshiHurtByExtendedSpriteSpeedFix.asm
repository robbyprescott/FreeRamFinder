; When Mario is hit by an extended sprite (like a hammer, fireball, chuck’s baseball, 
; volcano lotus fire), Yoshi will normally run very slow. This fixes that.


org $02A4B3
	db $18,$E8   ; vanilla value $10,$F0