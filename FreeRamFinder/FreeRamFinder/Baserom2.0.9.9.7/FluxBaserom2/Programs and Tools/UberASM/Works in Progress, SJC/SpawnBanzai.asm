; By spoons, minor mods SJC
; doesn't work when facing left
; SEC : SBC instead of CLC : ADC

!CustomSpriteNumber = $5D ; number from pixi list.txt
!Pose = $28
!Vertical = $1F ; normal 0F 
;!FreeRAM = $0E6E
;!pose_time = $0f             ;how many seconds to show the frame

; Shift below or above

xoffset_lo:
	db $F5,$0B
xoffset_hi:
	db $FF,$00 

main:
	; LDA $1407|!addr		;\
	; BNE .return			;/if the player is flying, don't do anything

	LDA $9D				;is the game frozen?
	ORA $13D4|!addr		;is the game paused?
	BNE .return			;in any of these cases, don't do anything
	
	LDA $18
	AND #$30 ; L or R
    BEQ .return
	
	LDA #$09
	STA $1DFC ; SFX

    ;LDA $149C
	;BNE .return
    lda #!Pose 
    sta $13E0|!addr               ;set the frame 
	
	;LDA #$0A fireball pose
    ;STA $149C ; pose 07 by default
	
	

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
.custom

	LDA.b #!CustomSpriteNumber
	STA !7FAB9E,x		;/set custom sprite #
	JSL $07F7D2|!bank	;reset tables
	JSL $0187A7|!bank	;set custom sprite stuff
	LDA #$08			;\
	STA !7FAB10,x		;/set as custom
	LDA #$08
	STA !14C8,x			;sprite is in normal state
	
    PHB : PHK : PLB
    LDA $76
    EOR #$01
    STA !C2,x	; make the sprite start out facing away from the player

	LDY $76				;which direction are we facing?
	LDA $94				;\
	CLC					;|
	ADC xoffset_lo,y	;|x lo
	STA !E4,x			;/
	LDA $95				;\
	ADC xoffset_hi,y	;|x hi
	STA !14E0,x			;/
	
	LDA $96				;\
	SEC					;| CLC or SEC
	SBC #!Vertical			;|y lo, ADC or SBC
	STA !D8,x			;/
	LDA $97				;\
	SBC #$00			;|y hi, ADC or SBC?
	STA !14D4,x			;/

    PLB
	RTL 