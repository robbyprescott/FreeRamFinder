org $029F7A
db $88			; Fireball's place in SP2, replaces flopping cheep-cheep.

org $029F7E
db $84			; CE. See above.

org $029F8B
db $34			; Change SP2's properties to accomodate the Fireballs.

org $019C0F
db $04,$2B		; New Cheep-Cheep tiles, in SP3 (almost always GFX13, even with water settings).

org $01B119		; Since Yoshi's Fireballs normally use pallete A, the same of Cheep-Cheeps, disable palette updating (it's not necessary.).
NOP #3

; excerpted from other code by Major Flare