;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Edible block list. You can have up to 255 blocks in here.
;;
;; Each entry in the below tables has five values associated with it:
;; 1) The Map16 tile number to make edible.

;; 2) How the sprite can be eaten. Format: e----ybt
;;     y = touched by adult Yoshi, b = Baby Yoshi, t = Yoshi's tongue
;;     e = Tile left behind. 0 for empty, 1 for bush.
;; 3) What berry routine to run, from EatenBlockRoutines.asm.
;;     Defaults: 00 = none (just give coin), 01 = red, 02 = pink, 03 = green
;;     Note: these don't run for baby Yoshi!
;; 4) The sprite tile to spawn.
;; 5) The YXPPCCCT for the sprite.
;; The first value is in the first table, the rest are in the second.
;;
;; You can also add custom routines to different tiles if you know a bit of coding.
;;  See EatenBlockRoutines.asm for details.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EdibleBlockList:
    ;   1
	dw $0045                     ; Normal red berry, no green BG.
    dw $0046                     ; Pink berry.
    dw $0047                     ; Green berry.
    dw $0440                     ; Red berry, WITH green BG.
    dw $0441                     ; Pink berry.
    dw $0442                     ; Green berry. 
	dw $0299                     ; Koopa, viz. swooper
	dw $02A9                     ; Spiny
	dw $03D1                     ; powerups: mushroom
	dw $03D2                     ; flower
	dw $03D3                     ; feather
	dw $03D4                     ; star
	dw $03D6                     ; 1-up
	;480 (formerly 6A8) is orb
    ;dw $0132                    ; 4) Example: make the used block edible.
    ; ...


EdibleBlockSettings:
    ; 2 e----ybt  3   4   5
	db %00000111,$01,$80,$02     ; Red berry.
    db %00000111,$02,$80,$04     ; Pink berry.
    db %00000111,$03,$80,$06     ; Green berry.
    db %10000111,$01,$80,$02     ; Red berry leaves green. 
    db %10000111,$02,$80,$04     ; Pink berry.
    db %10000111,$03,$80,$06     ; Green berry.
	db %00000111,$00,$C8,$08     ; Red block koopa
	db %00000111,$00,$84,$09     ; Spiny, $09 is second GFX page. Uses GFX02 in SP4
	db %00000111,$04,$24,$08     ; mushroom
	db %00000111,$05,$26,$0A     ; flower
	db %00000111,$06,$0E,$24     ; feather 
	db %00000111,$07,$48,$20     ; star
	db %00000111,$08,$24,$0A     ; 1-up mushroom
	;db %00000111,$00,$C2,$0A     ; orb

    ;db %00000111,$00,$2E,$00    ; Example: make the used block edible.
    ; ...









