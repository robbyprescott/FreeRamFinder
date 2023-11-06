; This makes the "up-pipe" hitbox as wide as possible, but
; without Mario's body sticking out from the side during the entrance animation.

org $00F3E3
db $07   ; Vanilla 0A. Lower number, wider.

org $00F3F9
db $09   ; 05 is vanilla. Higher number, wider.