; This levelasm will make sprites be translucent against other layers.
; Use it with the sprite mist generator to have translucent mist.

init:
	lda #%00110000
	sta $40
	sta $2131
	lda #%00000111
	sta $212D
	sta $212F
	rtl
