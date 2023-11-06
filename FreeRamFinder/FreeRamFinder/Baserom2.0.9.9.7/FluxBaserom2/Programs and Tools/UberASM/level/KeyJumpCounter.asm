; All this does is check if Y and B pressed on same frame,
; while standing on something solid.

load:
lda #$01
STA $0E06
RTL

main:
;REP #$20
;LDA $010B
;CMP #$00A4 ; only allow key jump counter in level A4
;BNE Next
;SEP #$20

LDA $72 ; when Mario on ground
BNE NoKey
LDA $16 
AND #$40 ; Y or X check 
BEQ NoKey 
LDA $16
AND #$80 ; B check
BEQ NoKey
INC $13CC
NoKey:
;SEP #$20
RTL

;Next:
;SEP #$20
;RTL