;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Non-Dynamic Podoboo Patch, by imamelia
;;
;; This patch changes the way the Podoboo uses graphics.  Instead of using the
;; tiles normally used by Yoshi, it instead uses GFX slot in SP4 and gets
;; them the same way any other sprite would.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
endif

; change the Podoboo's tilemap
org $019C35
db $C6,$C6,$D6,$D6,$C7,$C7,$D7,$D7,$D6,$D6,$C6,$C6,$D7,$D7,$C7,$C7 ; SP4, replacing lava splash (itself remappy to GFX p 1)
; original revised $43,$43,$53,$53,$44,$44,$54,$54,$53,$53,$43,$43,$54,$54,$44,$44
; vanilla 06 06 16 16 07 07 17 17 16 16 06 06 17 17 07 07

; change a JSR to a JMP, bypassing the dynamic GFX routine
org $01E19A
db $4C

; make the sprite use the second GFX page
org $07F431
db $35 ; default 34
