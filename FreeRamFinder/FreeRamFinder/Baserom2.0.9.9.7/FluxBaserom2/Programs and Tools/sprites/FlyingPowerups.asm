;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Flying Items, by Koopster.
;heavily aided by the flying item disassembly by imamelia, and as always, assisted by the boys in
;#asm!
;
;this is a version of the flying 1-up and red coin that is an item instead. you can set the item via
;extra byte 1 as specified below.
;
;EXTRA BYTE 1: item id
;	$00 = mushroom
;	$01 = flower
;	$02 = star
;	$03 = feather
;	$04 = 1-up
;
;if the extra bit is set, it will fly to the left rather than to the right.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main header
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB : PHK : PLB
	JSR Run
	PLB : RTL

Run:
	LDA #$00
	%SubOffScreen()
	JSR Graphics
	
	LDA !14C8,x		;\
	EOR #$08		;|
	ORA $9D			;|
	BEQ NotDead		;/blah also my returns are always out of bounds
	RTS

NotDead:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;animation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INC !1570,x			;increase wings animation once per frame
	
	LDA !extra_byte_1,x
	CMP #$01
	BEQ FlowerAnimation		;flower
	CMP #$02
	BNE NoAnimation			;not flower or star
	
	;star animation
	LDA $13
	LSR
	AND #$03
	STA !1602,x		;the star's frame counter will update every 2 frames from $00 to $03
	BRA NoAnimation

FlowerAnimation:
	LDA $13
	LSR #3
	AND #$01
	STA !1602,x		;the flower's will swap every 8 frames between $00 and $01

NoAnimation:		;other sprites will always have it at zero.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;movement
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;x speed
	LDY #$0C			;load right speed
	LDA !7FAB10,x
	AND #$04
	BEQ +
	LDY #$F2			;load left speed if extra bit is set
+	STY !B6,x
	JSL $018022|!BankB	;update xpos while we're here
	
	;as for y speed,
	LDA $13		;\
	AND #$01	;|only accelerate every other frame
	BNE NoAcc	;/
	
	;accelerate
	LDA !151C,x		;y direction. even = down, odd = up
	AND #$01
	TAY
	LDA !AA,x
	CLC
	ADC YAcc,y		;accelerate
	STA !AA,x
	CMP MaxYSpeed,y
	BNE NoAcc
	INC !151C,x		;swap y direction
	
NoAcc:
	;smw's shenaningans I absolutely had to keep to be accurate (tm)
	LDA !AA,x			;\need to reload it thanks to frame branch
	PHA					;/preserve y speed
	SEC					;\
	SBC #$02			;/subtract it by 2
	STA !AA,x
	JSL $01801A|!BankB	;update ypos here
	PLA					;\
	STA !AA,x			;/then store it back
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;interaction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	LDA !extra_byte_1,x
	CMP #$05		;\
	BCS Return		;/don't let the game crash if this isn't in the format we want
	CLC
	ADC #$74
	STA !9E,x		;set our act like setting

	JSL $01A7DC|!BankB	;Mario interaction
	BCC Return			;no touch good bye
	
	LDA !9E,x
	
	;jump to subroutine to handle powerups (A = powerup sprite number)
	PEA ($01)|(ReturnPowerup>>16<<8)
	PLB
	PHK
	PEA ReturnPowerup-1
	PEA $80CA-1
	JML $01C538|!BankB
ReturnPowerup:
	PLB
	
	LDX $15E9|!Base2
+	STZ !14C8,x			;erase sprite
	
Return:
	RTS		;where are we going???

YAcc:
	db $FF,$01
MaxYSpeed:
	db $F0,$10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tilemap:
	db $24,$26,$48,$0E,$24
Properties:
	db $08,$0A,$00,$04,$0A
ExtraProp:
	db $00,$40			;flower flip
	db $00,$04,$08,$04	;star palette oscilation

Graphics:
	;draw wings via subroutine
	PEA ($01)|(ReturnWings>>16<<8)
	PLB
	PHK
	PEA ReturnWings-1
	PEA $80CA-1
	JML $019E95|!BankB
ReturnWings:
	PLB
	
	;draw item
	%GetDrawInfo()
	
	LDA $00
	STA $0300|!Base2,y	;xpos
	
	LDA $01
	DEC					;displace by -1
	STA $0301|!Base2,y	;ypos
	
	LDX $15E9|!Base2
	LDA !extra_byte_1,x	;index by extra byte
	TAX
	LDA Tilemap,x
	STA $0302|!Base2,y	;tilemap
	
	;handle star and flower oscilations
	LDY $15E9|!Base2
	LDA !1602,y			;get current frame
	TAY					;on y
	CPX #$01
	BEQ NoStar
	CPX #$02
	BNE NoStar
	INY					;\
	INY					;/offset table index twice for star values
NoStar:
	LDA ExtraProp,y		;thankfully, for sprites that aren't flower, this loads $00
	ORA Properties,x	;get palette
	ORA $64
	LDX $15E9|!Base2	;restore sprite index
	LDY !15EA,x			;restore oam index
	STA $0303|!Base2,y	;properties
	
	LDY #$02			;16x16
	LDA #$00			;1 tile
	JSL $01B7B3|!BankB	;finish oam
	
	RTS 