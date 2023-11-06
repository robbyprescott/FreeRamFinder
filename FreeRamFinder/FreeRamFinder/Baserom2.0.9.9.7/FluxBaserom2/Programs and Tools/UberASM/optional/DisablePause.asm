; If you want to disable pause but you've also disabled the retry prompt,
; this gives you another way to exit the level.

!AllowExitWithLRSelect = 1

main:
lda #$FF : sta $13D3 ; disable pause
if !AllowExitWithLRSelect
LDA $17				;check if controller button is held
AND #$30			;L button
CMP #$30
BNE Return
LDA $16				;check if controller button is newly pressed.
AND #$20			; 20 Select button
CMP #$20
BNE Return			;
    ;lda.b #$01
	;sta $0DD5|!addr
	lda #$01
	sta $1DE9|!addr
	sta $13CE|!addr
	lda #$0B
	sta $0100|!addr
endif
Return:
RTL