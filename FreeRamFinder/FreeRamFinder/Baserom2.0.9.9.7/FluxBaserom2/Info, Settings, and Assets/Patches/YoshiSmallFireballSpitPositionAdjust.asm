; When you're using the UberASM, makes fireball position more natural when on Yoshi

org $00FEA4 ; Y-position
db $12,$12 ; This is a lower position than vanilla $0C,$0C

; org $00FE9E ; X-position when facing left
; db $FF,$00 ; vanilla $FF,$00