; by Binavik

; UberASM for disabling held sprites' interaction with other sprites.
; Useful if you don't want to patch this globally: https://www.smwcentral.net/?p=section&a=details&id=23017

;2 bytes
!freeRAM = $0E86|!addr

init:
	LDA #$FF
	STA !freeRAM
	RTL
	
main:
	LDA !freeRAM
	BPL .checkHolding
	LDX #$0C
.loop
	LDA $14C8|!addr,x
	CMP #$0B
	BEQ .found
	DEX
	BPL .loop
	RTL
.found
	STX !freeRAM
	LDA $1686|!addr,x
	STA !freeRAM+1
.checkHolding
	LDX !freeRAM
	LDA $14C8|!addr,x
	CMP #$0B
	BEQ .disableInteract
	LDA !freeRAM+1
	STA $1686|!addr,x
	LDA #$FF
	STA !freeRAM
	RTL
.disableInteract
	LDA $1686|!addr,x
	ORA #%00001000
	STA $1686|!addr,x
.return
	RTL