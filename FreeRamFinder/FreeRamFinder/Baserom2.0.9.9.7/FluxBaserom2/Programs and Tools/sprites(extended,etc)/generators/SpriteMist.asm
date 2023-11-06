
; Needs ExGFX31 in SP2, and the translucent mist UberASM. Uses palette color F3.

; This generator will draw the vanilla mist using sprite tiles
; The advantage is that you're free to use layer 3 for something else
; The disadvantage is that it uses a huge amount of tiles (around 80), so you'll
; have to design around using fewer sprites.

; 1 byte of freeram
!x_pos = $0F62|!addr

; How fast the mist moves horizontally
; Negative = move left, positive = move right
!speed = -$01

; Y position of the mist
!y_pos = $14

; YXPPCCCT properties and tile numbers
; By default they replace the msg box and coin tiles in SP2 (see included ExGFX), feel free to change them
!props = $3E ; 00111110, final palette row. Must be in last 3 rows to be translucent?
!t1    = $C0
!t2    = $C1
!t3    = $C2

print "INIT",pc
print "MAIN",pc
	phb
	phk
	plb
	jsr DefragOAM
	jsr DrawMist
	plb
	rtl

; Rearrange OAM tables to have all tiles in consecutive positions starting from $0200.
DefragOAM:
	rep #$10
	ldy #$0000			; Y: index in the original OAM tables.
	ldx #$0000			; X: index in the rearranged tables.
.loop
	lda $0201|!addr,y	;\
	cmp #$F0			;| If the tile is offscreen, go to the next one.
	beq .next			;/
	rep #$20			;\
	lda $0200|!addr,y	;|
	sta $0200|!addr,x	;| Otherwise, copy the tile to the new inex...
	lda $0202|!addr,y	;|
	sta $0202|!addr,x	;/
	lda #$F0F0			;\ ...and move the old index offscreen.
	sta $0200|!addr,y	;/
	phx					;\
	phy					;|
	tya					;|
	lsr #2				;|
	tay					;|
	txa					;|
	lsr #2				;| Also copy the tile size to the new index.
	tax					;|
	sep #$20			;|
	lda $0420|!addr,y	;|
	sta $0420|!addr,x	;|
	ply					;|
	plx					;/
	inx #4				;> Increase the reallocation index.
.next
	iny #4				;> Go to the next tile.
	cpy #$0200			;\ If not at the end of OAM, continue.
	bcc .loop			;/
.end
	stx $00
	sep #$10
	rts

; Draw all sprite tiles in the empty area after reallocation.
DrawMist:
	lda $9D
	bne .draw
	lda $14
	and #$01
	bne .draw
    lda !x_pos : clc : adc.b #!speed : sta !x_pos
.draw
	rep #$10
	ldx $00
	stz $00
	ldy.w #.y_disp-.x_disp-1
..loop
	stz $01
	lda !x_pos
	clc
	adc .x_disp,y
	sta $0200|!addr,x
	cmp #$F0
	bcc +
	inc $01
+	lda #!y_pos
	clc
	adc .y_disp,y
	sta $0201|!addr,x
	lda .tile,y
	sta $0202|!addr,x
	lda #!props
	ora .props,y
	sta $0203|!addr,x
	phx
	rep #$20
	txa
	lsr #2
	tax
	sep #$20
	lda $01					;\
	beq ..not_off_screen	;|
..off_screen				;|
	lda #$03				;|
	sta $0420|!addr,x		;|
	plx						;|
	rep #$20				;|
	lda $0200|!addr,x		;| If there's a tile partially offscreen (horizontally),
	sta $0204|!addr,x		;| draw an identical tile on the other side,
	lda $0202|!addr,x		;| so it looks like it wraps around.
	sta $0206|!addr,x		;|
	inx #4					;|
	phx						;|
	txa						;|
	lsr #2					;|
	tax						;|
	sep #$20				;/
..not_off_screen
	lda #$02
..next
	sta $0420|!addr,x
	plx
	inx #4
	cpx #$0200			;\ If we filled all OAM, stop drawing.
	bcs .return			;/
	dey
	bpl ..loop
.return
	sep #$10
	rts

.x_disp:
	db $00,$C0,$D0,$E0,$F0
	db $00,$10,$20,$50,$60,$70,$D8,$E8,$F8
	db $00,$10,$70,$80,$90,$A0,$B0,$C0,$D0,$E0,$F0
	db $F8,$90,$A0,$B0,$C0,$D0,$E0,$F0
	db $00,$10,$20,$30,$E8,$F0
	db $00,$70,$80,$90,$C0,$D0,$E0,$F0
	db $20,$30,$40,$50,$60,$70
	db $00,$40,$50,$60,$70,$80,$90,$A0,$E0,$F0
	db $78,$80,$90,$A0,$B0,$C0
	db $60,$70,$80

.y_disp:
	db $00,$00,$00,$00,$00
	db $10,$10,$10,$10,$10,$10,$10,$10,$10
	db $30,$30,$30,$30,$30,$30,$30,$30,$30,$30,$30
	db $40,$40,$40,$40,$40,$40,$40,$40
	db $50,$50,$50,$50,$50,$50
	db $60,$60,$60,$60,$60,$60,$60,$60
	db $80,$80,$80,$80,$80,$80
	db $90,$90,$90,$90,$90,$90,$90,$90,$90,$90
	db $A0,$A0,$A0,$A0,$A0,$A0
	db $B0,$B0,$B0

.tile:
	db !t1,!t1,!t2,!t2,!t2
	db !t2,!t2,!t1,!t1,!t2,!t1,!t1,!t2,!t2
	db !t2,!t1,!t1,!t2,!t2,!t2,!t2,!t2,!t2,!t2,!t2
	db !t3,!t1,!t2,!t2,!t2,!t2,!t2,!t2
	db !t2,!t2,!t2,!t1,!t3,!t2
	db !t1,!t1,!t2,!t1,!t1,!t2,!t2,!t2
	db !t1,!t2,!t2,!t2,!t2,!t1
	db !t1,!t1,!t2,!t2,!t2,!t2,!t2,!t1,!t1,!t2
	db !t3,!t2,!t2,!t2,!t2,!t1
	db !t1,!t2,!t1

.props:
	db $40,$00,$00,$00,$00
	db $00,$00,$40,$00,$00,$40,$00,$00,$00
	db $00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$40,$40,$00
	db $40,$00,$00,$40,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$40
	db $40,$00,$00,$00,$00,$00,$00,$40,$00,$00
	db $40,$00,$00,$00,$00,$40
	db $00,$00,$40
