; Remaps Rp Van Fish ZZZs to same spot as RETRY in SP1 (cleared up by DMA patch)
; You can't have diff. tiles on different GFX pages

org $028DDA : db $4E : org $028E44 : db $02                                       ; z
org $028DD9 : db $4F : org $028E44 : db $02                                       ; Z
org $028DD8 : db $5E : org $028E44 : db $02 
org $028DD7 : db $5F : org $028E44 : db $02                                       ; *pop*


; vanilla
;org $028DDA : db $E0 : org $028E44 : db $03                                       ; z
;org $028DD9 : db $E1 : org $028E44 : db $03                                       ; Z
;org $028DD8 : db $F0 : org $028E44 : db $03 
;org $028DD7 : db $F1 : org $028E44 : db $03                                       ; *pop*