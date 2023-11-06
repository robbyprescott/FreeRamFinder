load:
    lda #$01
	sta $0E06
	rtl
	
main:
    LDA $14AF
	BEQ Return
    LDA $72 ; when Mario on ground
	BNE Return
	STZ $0DBF ; zero coin count
	Return:
	RTL