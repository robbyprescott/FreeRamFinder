; By Binaik
; SJC, added layer 3 priority at bottom

; Make sure status bar is disabled

;Note that this routine uses the A, X and Y registers
;along with $00-$02

;display 1 byte count up to 3 digits
;usage:
;LDA <Counter FreeRAM>
;JSL ThreeDigitCounter

!FreeRAMKillVanillaFunction = $0DEC

!header_byte_1 = #$50
!header_byte_2 = #$5B ; Location. original 52
!header_byte_3 = #$00
!header_byte_4 = #$05

;YXPCCCTT, NOT THE SPRITE STUFF
!tile_prop  = #$38
				
!stripe_table = $7F837D

init:
    LDA #$01 
	STA !FreeRAMKillVanillaFunction
	RTL

main:
	LDY #$00
.hundreds_loop
	CMP #$64
	BCC .do_tens
	SBC #$64
	INY
	BRA .hundreds_loop
.do_tens
	LDX #$00
.tens_loop
	CMP #$0A
	BCC .store
	SBC #$0A
	INX
	BRA .tens_loop
.store
	STY $00
	STX $01
	STA $02
	
	REP #$30
	LDA $7F837B
	TAX
	LDY #$0000
	SEP #$20
	LDA !header_byte_1
	STA !stripe_table,x
	INX
	LDA !header_byte_2
	STA !stripe_table,x
	INX
	LDA !header_byte_3
	STA !stripe_table,x
	INX
	LDA !header_byte_4
	STA !stripe_table,x
	INX
	LDA $00
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA $01
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA $02
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA #$FF
	STA !stripe_table,x
	REP #$20
	TXA 
	STA $7F837B
	SEP #$30
	STZ $24
	
	lda #$09            ;\ Set layer 3 absolute priority.
    sta $3E             ;/
    stz $22             ;\
    stz $23             ;| Reset layer 3 position.
    stz $24             ;|
    stz $25             ;/
	
	RTL
