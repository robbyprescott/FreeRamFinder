lorom

org $03D7B1
autoclean JSL GetTilePos

org $03D7CE
TYA					; Load tile
BRA $00				; Padding

freedata

GetTilePos:
	TAX					; Restore
	LDA $0D9A			; In a Mode 7 room?
	BPL .RegularLevel	;
	LDY #$38FC			; Transparent tile (Reznor battle)
	LDA #$C05A			; Writes to VRAM 0x5800 + pos
RTL

.RegularLevel:
	LDY #$38F8			; Transparent block (Regular level)
	LDA #$C022			; Writes to VRAM 0x2000 + pos (note that LM adjusts that to 0x3000 in the stripe image routine)
RTL

