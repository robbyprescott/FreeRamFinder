; You'll need to make sure you un-comment out the ORA value
; and match it to the ConditionalMap16 flag in LM

!ExitType = $02 ; see options below

; $01 is normal exit
; $02 is secret exit 1
; $03 is secret exit 1
; $04 is secret exit 1

main:
LDA $0DD5
CMP #!ExitType ; secret exit check
BCS Return
LDA $7FC060
;ORA #%00000010 ; 2 in hex, 1 in Conditional
STA $7FC060
Return:
RTL