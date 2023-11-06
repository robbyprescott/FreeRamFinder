; You can use this to darken everything under layer 3 water, like in SMAS

; If you use this, the only other layer 3 setting you need to enable
; is priority. This enables translucence by default, and you don't need level mode 0E

init:
	LDA #$17
	STA $0D9D
	STA $212C
	STA $212E
	LDA #$13
	STA $0D9E
	STA $212D
	STA $212F
	LDA #$64
	STA $40
RTL