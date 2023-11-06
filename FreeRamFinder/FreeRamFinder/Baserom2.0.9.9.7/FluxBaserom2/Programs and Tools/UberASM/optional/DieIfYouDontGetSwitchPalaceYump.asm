; Note that you may need to also find some way of 
; resetting the specific switch flag, too

; !Color = $xxxx

;$1F27: Green
;$1F28: Yellow
;$1F29: Blue
;$1F2A: Red

init:
LDA #$01
STA $0E27
RTL

main:
;LDA $0E29 ; FreeRAM set when no yump (when $0E27 already set)
;BEQ Return
;STZ !Color
;Return:
RTL