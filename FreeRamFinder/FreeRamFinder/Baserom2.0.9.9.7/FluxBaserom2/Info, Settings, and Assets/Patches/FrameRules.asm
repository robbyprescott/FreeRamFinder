; Borrowed from RHR collection, thanks AmperSam

; check for interaction every single frame (as opposed to every other frame)
org $02A0B2 : db $00 ; fireball-sprite
org $01A7EF : db $00 ; mario-sprite
; org $029500 : db $00 ; cape-sprite, already taken care of in capespin consistency patch

; make Bob-Omb explosions interact with Mario and other sprites every frame
org $0280A8 : bra $05
org $0280B2 : bra $08
