;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Conditional Bullet Bill Shooter, by Koopster
;
;A very simple recreation of the original shooter that only shoots when a flag is set (or clear).
;
;EXTRA BYTE 1: will determine the type of bullets to shoot:
;	00 = shoot right and left
;	02 = shoot up and down
;	04 = shoot up-right exclusively
;	05 = shoot down-right exclusively
;	06 = shoot down-left exclusively
;	07 = shoot up-left exclusively
;	10 = shoot right exclusively
;	11 = shoot left exclusively
;	12 = shoot up exclusively
;	13 = shoot down exclusively
;	+80 = horizontal proximity check off
;EXTRA BYTE 2: overwrites the value of !DefaultTimer if set.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;flag to use. by default, uses the on/off status ($14AF).

	!Flag = $14AF|!addr

;time between shots. if extra byte 2 is set, this value will be overwritten.

	!DefaultTimer = $60

;sprite number and extra bit. change this if you're using a disassembly bullet sprite.

	!SpriteNumber = $1C
	!SpriteExtraBit = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;shooter code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB : PHK : PLB
	JSR Run
	PLB
	RTL

Run:
	STZ $00				;\
	LDA !Flag			;|
	BEQ +				;|transform any non-binary flags into either just 0 or 1
	INC $00				;|
	+					;/
	
	LDY #$00			;\
	LDA $1783|!addr,x	;|
	AND #$40			;|extra bit clear, flag clear = shoot
	BEQ +				;|extra bit clear, flag set = do not shoot
	INY					;|extra bit set, flag clear = do not shoot
+	TYA					;|extra bit set, flag set = shoot
	EOR $00				;|
	BNE Return			;/
	
	LDY #!DefaultTimer	;\
	LDA !7FAC08,x		;|
	BNE +				;|use default or extra bit timer
	TYA					;|
+	PHA					;/
	
	LDA !7FAC00,x		;\
	AND #$80			;|
	SEC					;|
	BEQ +				;|check proximity check flag
	CLC					;|
	+					;/
	
	PLA
	%ShooterMain()
	BCC Shoot

Return:
	RTS

Shoot:
	TYX
	LDA #!SpriteNumber
if !SpriteExtraBit < 2
		STA !9E,x
else
		STA !7FAB9E,x
		JSL $0187A7|!bank
endif
	JSL $07F7D2|!bank
	LDA #$08
	STA !14C8,x
	LDA #!SpriteExtraBit<<2
	STA !7FAB10,x

	LDA #$10			;\
	STA !1540,x			;/set low priority timer
	
	TXY					;\
	LDX $15E9|!addr		;/bullet's slot to y, shooter's slot back to x
	
	LDA $178B|!addr,x	;\
	STA.w !D8,y			;|
	LDA $1793|!addr,x	;|
	STA !14D4,y			;|
	LDA $179B|!addr,x	;|set all positions
	STA.w !E4,y			;|
	LDA $17A3|!addr,x	;|
	STA !14E0,y			;/
	
	LDA !7FAC00,x		;load shooter's extra byte in the accumulator
	AND #$1F			;mask out bits we don't want
	
	TYX					;bullet's slot temporarily back to x
	
	CMP #$04			;\
	BCS SingleDir		;/branch for shooters that exclusively shoot in one direction
	
	CMP #$02
	BCS Vertical
	
;horizontal shooter
	%SubHorzPos()		;\
	LDA SmokeXOffset,y	;|
	STA $00				;|
	STZ $01				;|set smoke offset and direction of bullet
	TYA					;|
	STA !C2,x			;|
	BRA EndDir			;/

Vertical:
	%SubVertPos()		;\
	TYA					;|
	EOR #$01			;|
	INC #2				;|
	STA !C2,x			;|
	TAY					;|set smoke offset and direction of bullet
	STZ	$00				;|
	LDA SmokeYOffset,y	;|
	STA $01				;|
	BRA EndDir			;/

SingleDir:
	AND #$07
	STA !C2,x
	TAY
	LDA SmokeXOffset,y
	STA $00
	LDA SmokeYOffset,y
	STA $01
	
EndDir:
	LDA #$1B			;\
	STA $02				;|
	LDA #$01			;|spawn smoke
	%SpawnSmoke()		;/
	
	LDX $15E9|!addr		;restore shooter's slot
	
	LDA #$09			;\
	STA $1DFC|!addr		;/make sound
	
	RTS

SmokeXOffset:
	db $0C,$F4,$00,$00,$0C,$0C,$F4,$F4
SmokeYOffset:
	db $00,$00,$F4,$0C,$F4,$0C,$0C,$F4 