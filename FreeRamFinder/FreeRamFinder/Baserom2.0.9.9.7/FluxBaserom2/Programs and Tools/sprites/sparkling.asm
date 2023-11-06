;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sparkling block effect
;  by TheBiob
; Description:
;  This invisible sprite will make a sparkle effect appear at it's location.
;  It will destroy itself once the block changes
;   If the extra bit is set you can place the sprite on air (25) as well
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!freeram_block = $7FC600 ; 24 bytes freeram

if !SA1
!freeram_block = $418AFF ; this is used if you're using SA-1
endif

print "MAIN ",hex(main)
print "INIT ",hex(init)

main:
	PHB : PHK : PLB
	LDA #$00
	%SubOffScreen()
	PLB
	JSR SpriteToBlock
	TXA : ASL : TAX
	%GetMap16()
	TYA : XBA
	REP #$30
	CMP #$0025
	SEP #$30
	BNE .kill
	LDX $15E9|!Base2
	LDA $13
	AND #$0F
	BNE .return
	PEA.w $0180C9|!BankB
	JML $01B14E|!BankB
.kill2
	SEP #$30
;	LDA #$01
;	STA $0EF9|!Base2
.kill
	LDX $15E9|!Base2
	STZ !14C8,x
.return
	RTL

init:
	JSR SpriteToBlock
	TXA : ASL : TAX
	%GetMap16()
	TYA : XBA
	REP #$20
	CMP #$0025
	BNE .store
	TAY : PHX
	LDA $15E9|!Base2
	AND #$00FF
	TAX
	LDA !7FAB10,x
	PLX
	AND #$0004
	BEQ main_kill2
	TYA
.store
	STA !freeram_block,x
	SEP #$30
	LDX $15E9|!Base2
	RTL

SpriteToBlock:
	LDA !D8,x
	STA $98
	LDA !14D4,x
	STA $99
	LDA !E4,x
	STA $9A
	LDA !14E0,x
	STA $9B
	RTS