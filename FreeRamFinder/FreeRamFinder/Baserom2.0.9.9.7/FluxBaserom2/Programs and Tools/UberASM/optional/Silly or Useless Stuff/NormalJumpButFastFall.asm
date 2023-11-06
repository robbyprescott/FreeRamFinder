main:
LDA $7D		; \ if positive y speed, return
BMI .skiplimit	; /
CMP #$30	; \ if speed is low enough, return
BCS .skiplimit	; /
LDA #$30	; \ limit to $D0 (or -$30)
STA $7D		; /
.skiplimit:
RTL