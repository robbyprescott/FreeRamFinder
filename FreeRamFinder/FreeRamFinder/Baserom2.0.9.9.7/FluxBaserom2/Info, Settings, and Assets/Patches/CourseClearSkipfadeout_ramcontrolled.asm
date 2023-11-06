; By spoons
; When set, this will skip the COURSE CLEAR stuff (including fadeout), to not kill your layer 3

; ram-controlled version of:
; org $00AF2D
; BRA + : NOP #6 : + ; 00AF2D
; RTS  ; 00AF35


!freeRAM = $0EC4 ; 

if read1($00FFD5) == $23		; check if the rom is sa-1
	if read1($00FFD7) == $0D ; full 6/8 mb sa-1 rom
		fullsa1rom
	else
		sa1rom
	endif
	!bank = $000000
else
	lorom
	!bank = $800000
endif

org $00AF2D
    autoclean JML hijack

org $00AF35
    autoclean JML hijack2


freecode
skip_fadeout:
rts:
    assert read1($00AFA2) == $60 ; rts
    JML $00AFA2|!bank

hijack:
    LDA !freeRAM
    BNE skip_fadeout   ; SJC: simply changed this from BEQ to make fadeout default

	LDA.b #$09					;$00AF2D	|
	STA $3E						;$00AF2F	|
	JSL $05CBFF|!bank		    ;$00AF31	| Handle the end level walk.
    BRA hijack2_fade

hijack2:
    LDA !freeRAM
    BNE skip_fadeout   ; SJC: simply changed this from BEQ to make fadeout default

.fade
	LDA $13						;$00AF35	|\ 
	AND.b #$03					;$00AF37	|| Fade every four frames.
    JML $00AF39|!bank
	; BNE Return00AFA2			;$00AF39	|/

