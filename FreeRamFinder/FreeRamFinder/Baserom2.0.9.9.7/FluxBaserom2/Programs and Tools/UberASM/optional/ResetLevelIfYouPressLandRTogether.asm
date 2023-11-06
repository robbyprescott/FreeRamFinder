;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 2022 - Nitrocell, mod by SJC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; You may need to avoid using this in level 24

!BothLandR = 1 ; if set to zero, can reset with just L or R, not both

main:
    LDA $9D
    ORA $13D4         ; Freeze checks
    BNE Return   
    LDA $17
    AND #$30          ; Press L and R
if !BothLandR = 1
    CMP #$30
endif
    BNE Return 
.teleport:
	LDA $13BF|!addr				;\
	CMP #$24				;| Load current level's number (aka translevel number)
	BCS .addDC				;/ and check if > 24. If so, DC needs to be added for $1nn
	TAX					;\
	REP #$20				;| Set A to 16-bit mode, needed for %teleport() and use X as backup value for A
	TXA					;/
	BRA .actualTeleport
.addDC:
	CLC					;\ Add $DC to current level number to convert it to LM's "Level Number" > 24
	ADC #$DC				;/
	TAX					;\
	REP #$20				;| Set A to 16-bit mode, needed for %teleport() and use X as backup value for A
	TXA					;/
	XBA					; Change position from lower byte to higher (00NN -> NN00) to add 01 that will be used as 1NN for level number.
	CLC					;\ Add $01 to lower byte ($0001)
	ADC #$0001				;/
	XBA					; Exchange these two bytes again (NN01 -> 01NN) (e.g. for level 105 => 0501 -> $0105 after xba)
.actualTeleport:
	PHA					;\
	STZ $88					;|
	SEP #$30				;|
	LDX $95					;|
	PHA					;|
	LDA $5B					;|
	LSR					;|
	PLA					;|
	BCC +					;| This is %teleport() routine borrowed
	LDX $97					;| from GPS for same purpose, to teleport
	+					;| (with minimal changes).
	PLA					;|
	STA $19B8|!addr,x			;|
	PLA					;|
	ORA #$04				;|
	STA $19D8|!addr,x			;|
	LDA #$06				;|
	STA $71					;/
	Return:
	RTL
	