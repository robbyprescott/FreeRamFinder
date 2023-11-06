; NOTE that 

;https://floating.muncher.se/bot/alllog2/smwdisc.txt

!Where = $0F0E ; where coin counter normal is. Default

lorom
header

org $008CBF ; this puts back the remaining zero at end of coin counter, for points to use
db $00,$38 ; otherwise $FC,$38

org $008EE0
LDA !Where,x ; vanilla LDA.W $0F29,X

org $008EE7
STA !Where,x ; vanilla STA.W $0F29,X

org $008F0E
LDA !Where,x ; vanilla LDA.W $0F29,X

org $008F15
STA !Where,x ; vanilla STA.W $0F29,X

org $009014
db $9E : dw !Where-$14 ; vanilla 9E 15 0F      STZ.W $0F15,X

org $009034
db $FE : dw !Where-$14 ; vanilla FE 15 0F   INC.W $0F15