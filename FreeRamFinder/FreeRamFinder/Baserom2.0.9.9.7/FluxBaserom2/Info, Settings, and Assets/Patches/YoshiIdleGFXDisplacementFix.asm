; This fixes a pixel GFX displacement between Yoshi's head and body
; while idling
; Also needs GFX adjustment


org $01EE17
db $09   ;      facing right, 0A vanilla


org $01EE24
db $F7     ;    facing left, vanilla F6