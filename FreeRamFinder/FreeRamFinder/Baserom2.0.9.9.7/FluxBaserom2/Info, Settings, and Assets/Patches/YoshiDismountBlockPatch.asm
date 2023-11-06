if read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!14C8 = $3242
	!154C = $32DC
	!1602 = $33CE
else
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!14C8 = $14C8
	!154C = $154C
	!1602 = $1602
endif

ORG $01ED44
autoclean JML Yoshi		; Small hijack to disable Yoshi mounting if $154C,x is set. Prevents the player being able to shift Yoshi through the block with
						; quick mount-dismounts.

freecode

Yoshi:

LDA $7D		;
BMI NoMount		; Restore original code.
LDA !154C,x		;
BNE NoMount		; Don't mount if $154C,x is set.
JML $01ED48|!bank

NoMount:
JML $01ED70|!bank