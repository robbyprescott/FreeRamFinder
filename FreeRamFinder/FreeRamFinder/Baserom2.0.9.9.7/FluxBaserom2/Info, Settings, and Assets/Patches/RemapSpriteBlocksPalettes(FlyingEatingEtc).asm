; Along with the turblock bridge tile edit,
; this basically allowed me to harmonize the colors of things in (block) palette row 6
; with the different palette of their corresponding sprite versions, now moved from 8 to A




; Flying block used tile: $01AE76 (default 2A). BCC CODE_01AE7B, to STA.W OAM_Tile,Y (OAM_Tile = 302). 303 is OAM_Prop

; $07F481. See Sprite166EVals

;;; Flying ? Block, left
org $01AE76 : db $2A : org $07F481 : db $24                                       ; ? block
org $01AE7A : db $2E : org $07F481 : db $24 ; palette 8                                       ; Hit


;;; Flying ? Block, back and forth
org $01AE76 : db $2A : org $07F482 : db $24                                       ; ? block
org $01AE7A : db $2E : org $07F482 : db $24                                       ; Hit

;;; Creating/eating block

org $07F4AF
db $34  ;   palette B is 36. 34 is palette A. vanilla $30, 00110000 

; org $039293 : db $2E
; org $0392A0 : db $02


;;; Directional coins
org $01C653 : db $E8 : org $07F443 : db $34                                       ; Frame 1, default $30 for all
org $01C66D : db $EA : org $07F443 : db $34                                       ; Frame 2
org $01C66E : db $FA : org $07F443 : db $34                                       ; Frame 3
org $01C66F : db $EA : org $07F443 : db $34                                       ; Frame 4