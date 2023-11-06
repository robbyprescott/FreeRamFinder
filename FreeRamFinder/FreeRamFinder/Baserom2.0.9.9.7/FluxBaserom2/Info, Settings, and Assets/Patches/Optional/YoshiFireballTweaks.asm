; Only middle fireball: 
; https://www.smwcentral.net/?p=memorymap&game=smw&region=rom&address=01F27C&context=

org $01F282 : db $00
org $01F288 : db $80,$04

; Speed. $01F2D9 (3 bytes): X speed to give the fireball. 
; By default it's $28,$24,$24 (middle, up, down fireball respectively).

org $01F2D9
db $28