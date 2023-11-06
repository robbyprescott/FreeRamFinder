; Setting to FF corresponds to 20 (in hex) frames. Sync with ExAn

;!FreeRAM = $1869    ; match this in trigger blocks

;main:
;LDA !FreeRAM
;BNE .OnOffCycle
;RTL

main:
LDA $14
AND #$FF		; #$00, #$01, #$03, #$07, #$0F, #$1F, #$3F, #$7F or #$FF
BNE Return
LDA #$18
STA $1DFC

Return:
RTL