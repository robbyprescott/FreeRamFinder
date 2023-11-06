; When used with the example level, which includes a layer 3 file + ExAnimation settings,
; will display your inputs in the corner (or wherever you want).

; Only checks for holds. Presses are too fast to visually register anyways
; Use with Layer3VisualToggleOnTrigger.asm to be able to toggle on and off.

!ExAnimCustTriggerRAM = $7FC0FD ; Then the 0th bit of $7FC0FD would be trigger 8, then bits 1-7 are triggers 9,A,B,C,D,E,F

main:
	LDA $15 ; held
	AND #$01
	BEQ NotHeldRight
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0001
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next2
NotHeldRight:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0001^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next2:
	LDA $15 ; held
	AND #$02
	BEQ NotHeldLeft
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0002
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next3
NotHeldLeft:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0002^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next3:
	LDA $15 ; held
	AND #$04
	BEQ NotHeldDown
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0004
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next4
NotHeldDown:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0004^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next4:
	LDA $15 ; held
	AND #$08
	BEQ NotHeldUp
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0008
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next5
NotHeldUp:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0008^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next5:	
    LDA $15
	EOR $17
	AND #$40 ; Y
	BEQ NotHeldY
    REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0010
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next6
NotHeldY:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0010^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next6:	
    LDA $15
	EOR $17
	AND #$80 ; B
	BEQ NotHeldB
    REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0020
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next7
NotHeldB:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0020^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next7:
	LDA $17 ; held
	AND #$40
	BEQ NotHeldX
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0040
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Next8
NotHeldX:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0040^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Next8:
	LDA $17 ; held
	AND #$80
	BEQ NotHeldA
	REP #$20
    LDA !ExAnimCustTriggerRAM
    ORA #$0080
    STA !ExAnimCustTriggerRAM
    SEP #$20
	BRA Final
NotHeldA:
	REP #$20
    LDA !ExAnimCustTriggerRAM
	AND #$0080^$FFFF
	STA !ExAnimCustTriggerRAM
    SEP #$20
Final:
    RTL
	
	; $17 and $10, R shoulder
	; $17 and $20, L shoulder
	
	; 01=Right (1B), 02=Left (color F), 04=Down (1A), 08=Up (A)
    ; Y (color B), B (1F); X (1E), A (E) 