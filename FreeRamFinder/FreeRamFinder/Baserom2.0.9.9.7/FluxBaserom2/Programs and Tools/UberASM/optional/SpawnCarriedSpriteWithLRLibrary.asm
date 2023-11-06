; SJC added fix, per NewPointless and Koopster

;$00, $01 = sprite # to spawn with L and R respectively
;$02, $03 = set if corresponding sprite is custom
;C = skip cape check, c = run cape check

main:
	BCS +
	
	LDA $1407|!addr		;\
	BNE .return			;/if the player is flying, don't do anything
	
	+
	LDA $1470|!addr		;\
	ORA $148F|!addr		;/is the player carrying something already?
	ORA $187A|!addr		;is the player riding yoshi?
	ORA $9D				;is the game frozen?
	ORA $13D4|!addr		;is the game paused?
	BNE .return			;in any of these cases, don't do anything
	
	LDA $15				;\
	AND #$40			;|if X or Y aren't being held down, we're better off not spawning anything
	BEQ .return			;/
	
	LDA $18
	BIT #$20			;we'll prioritize L in this code, so check it first
	BNE .pressedL
	AND #$10			;now check if R is being pressed
	BEQ .return			;if neither is, return
	
	LDY #$00			;our index is 0 for an L press
	BRA +
.pressedL
	LDY #$01			;or 1 for an R press
	+
	
;sprite slot finder
	LDX #!sprite_slots-2
-	LDA !14C8,x
	BEQ .found
	DEX
	BPL -
	;nope
	
.return
	RTL

.found
	LDA $02|!dp,y
	BNE .custom
	
;spawn a regular sprite
	LDA $00|!dp,y		;\
	STA !9E,x			;/set sprite #
	BRA +
	
.custom
	LDA $00|!dp,y		;\
	STA !7FAB9E,x		;/set custom sprite #
	JSL $07F7D2|!bank	;reset tables
	JSL $0187A7|!bank	;set custom sprite stuff
	LDA #$08			;\
	STA !7FAB10,x		;/set as custom
	BRA ++
	
	+
	JSL $07F7D2|!bank	;reset tables
	++
	LDA #$09
	STA !14C8,x			;sprite is in carried state
	
;set positions
	PHB : PHK : PLB		;we'll need to set the dbr cause we're in a library and y is stupid
	
	LDY $76				;which direction are we facing?
	LDA $94				;\
	CLC					;|
	ADC .xoffset_lo,y	;|x lo
	STA !E4,x			;/
	LDA $95				;\
	ADC .xoffset_hi,y	;|x hi
	STA !14E0,x			;/
	
	LDA $96				;\
	CLC					;|
	ADC #$0F			;|y lo
	STA !D8,x			;/
	LDA $97				;\
	ADC #$00			;|y hi
	STA !14D4,x			;/
	
	PLB
	RTL 
	
.xoffset_lo:
	db $F7,$09 ; formerly $F5,$0B, SJC
.xoffset_hi:
	db $FF,$00 