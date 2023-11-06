; This makes both normal Lakitu and pipe-dwelling one simply disappear in a puff of smoke when killed,
; instead of falling out of the pipe, freeing up two 16x16 tiles at the bottom-right of GFX02

org $07F28A  ; normal Lakitu, sprite 1E
db $91 ; vanilla 11 

org $07F2B7 ; pipe Lakitu, sprite 4B
db $90 ; vanilla 10