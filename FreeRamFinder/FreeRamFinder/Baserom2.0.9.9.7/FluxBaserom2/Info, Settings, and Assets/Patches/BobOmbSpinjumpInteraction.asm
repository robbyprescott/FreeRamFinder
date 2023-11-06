; Thanks to AmperSam

; https://www.smwcentral.net/?p=viewthread&t=105864

; Fixed interaction with explosion hitbox, e.g. for spin-jumps

org $0280A8 : bra $05  ; vanilla db $4A
org $0280B2 : bra $08  ; vanilla db $BD