; by SJandCharlieTheCat
; Example on/off switch to OFF when L or R held (reverts back when let go)
; You can replace !RAM, etc., with another address
; to make it trigger for other code

!RAM = $14AF

main:
	LDA $17 ; held
	AND #$30
	BEQ NotHeld
	LDA #$01
	STA !RAM
	RTL
	
NotHeld:
	STZ !RAM	
	RTL