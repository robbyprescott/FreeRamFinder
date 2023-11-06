main:

LDA $75		; Is Mario in water ?
BEQ .return	; Cuz' if not, return.
;LDA $77		; \ Is Mario touching the ground ?
;AND #$04	; /
;BEQ .return	; Cuz' if he is, return.
LDA #$80
TRB $16  ; Disables A or B presses
TRB $18  ; controller 2  
.return
RTL