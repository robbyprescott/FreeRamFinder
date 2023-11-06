;Palette table:
;Each palette byte corresponds to custom power state.
;Check readme for more details on those tables and how to set custom colors.
;moved to standalone file because I think it looks meh in main asm.

Color88_RGBValue1:
db $14,$21,$0C,$35,$5C

Color88_RGBValue2:
db $A5,$61,$83,$21,$64

Color89_RGBValue1:
db $4E,$79,$1C,$72,$6D

Color89_RGBValue2:
db $75,$6A,$E7,$87,$8D

Color8A_RGBValue1:
db $29,$20,$00,$7F,$40

Color8A_RGBValue2:
db $4B,$54,$08,$34,$A7

Color8B_RGBValue1:
db $35,$1C,$04,$7F,$69

Color8B_RGBValue2:
db $AF,$5A,$2E,$95,$4E

Color8C_RGBValue1:
db $56,$55,$00,$7F,$72

Color8C_RGBValue2:
db $B6,$DD,$1D,$F8,$10

Color8D_RGBValue1:
db $35,$64,$14,$6A,$54

Color8D_RGBValue2:
db $AE,$62,$A5,$21,$E

;stolen from Wario Dash sprite i'm good at stealing code
ChangePalette:
PHB
PHK
PLB
JSR .Grr
PLB
RTL

.Grr
-
BIT $4212 : BVS -

-

BIT $4212 : BVC -

LDY #$88
STY $2121

LDA Color88_RGBValue2,x		;SNES RGB Color Low byte
STA $2122			;

LDA Color88_RGBValue1,x		;SNES RGB Color High byte (I know I got them in wrong order, but it was easier for me to go from right to left)
STA $2122			;

LDA Color89_RGBValue2,x		;and etc.
STA $2122			;

LDA Color89_RGBValue1,x
STA $2122

-
BIT $4212 : BVC -


LDY #$8A
STY $2121

LDA Color8A_RGBValue2,x
STA $2122

LDA Color8A_RGBValue1,x
STA $2122


LDA Color8B_RGBValue2,x
STA $2122

LDA Color8B_RGBValue1,x
STA $2122

-
BIT $4212 : BVC -

LDY #$8C
STY $2121

LDA Color8C_RGBValue2,x
STA $2122

LDA Color8C_RGBValue1,x
STA $2122


LDA Color8D_RGBValue2,x
STA $2122

LDA Color8D_RGBValue1,x
STA $2122
RTS