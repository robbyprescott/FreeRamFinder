; All sprites jump when Mario jumps uberasm

!JumpSpeed = $C0

main:
	lda $9D
	ora $13D4|!addr
	bne .return
	lda $16
	ora $18
	bpl .return
	lda $77
	and #%00000100
	beq .return
	ldx #!sprite_slots-1
.loop
	lda !14C8,x
	cmp #$08
	bcc .continue
	lda !1588,x
	and #%10000100
	beq .continue
	lda #!JumpSpeed
	sta !AA,x
	lda !1588,x
	and #%01111011
	sta !1588,x
.continue
	dex
	bpl .loop
.return
	rtl
