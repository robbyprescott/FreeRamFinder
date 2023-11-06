; This moves temporary (non-Map16) net tiles when door animation is active, 
; to second block GFX page (GFX18), freeing up some space in GFX17 / FG2

; To move to 2nd GFX page, just add one, so 9C = 9D


org $00C29E
	db $ED,$9D,$EE,$1D,$EE,$1D,$EE,$1D,$EE,$1D,$ED,$DD	
	db $EF,$1D,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$EF,$5D
	db $EF,$1D,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$EF,$5D
	db $EF,$1D,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$EF,$5D
	db $EF,$1D,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$EF,$5D
	db $ED,$1D,$EE,$9D,$EE,$9D,$EE,$9D,$EE,$9D,$ED,$5D
	

; Original:
	
	;org $00C29E
	;db $99,$9C,$8B,$1C,$8B,$1C,$8B,$1C,$8B,$1C,$99,$DC	; $00C29E - Empty
	;db $9B,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$9B,$5C
	;db $9B,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$9B,$5C
	;db $9B,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$9B,$5C
	;db $9B,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$9B,$5C
	;db $99,$1C,$8B,$9C,$8B,$9C,$8B,$9C,$8B,$9C,$99,$5C


;To simply make blue + pinkdoor outline not change at all, do this:

;8B (empty) = AB
;99 (empty) = BA
;9B (empty) = AA
 
;org $00C29E
	;db $BA,$9C,$AB,$1C,$AB,$1C,$AB,$1C,$AB,$1C,$BA,$DC	; $00C29E - Empty
	;db $AA,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$AA,$5C
	;db $AA,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$AA,$5C
	;db $AA,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$AA,$5C
	;db $AA,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$F8,$1C,$AA,$5C
	;db $BA,$1C,$AB,$9C,$AB,$9C,$AB,$9C,$AB,$9C,$BA,$5C
	
