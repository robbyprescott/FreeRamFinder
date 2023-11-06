; https://www.smwcentral.net/?p=section&a=details&id=26723

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Any Sprite Generator, by Koopster
;
;This generator will spawn a specified sprite in a specified interval in one of the positions
;specified in the position tables below.
;The default values make this work like a wave motion Eerie generator.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;interval to generate sprites
;	valid values: $00 (every frame!), $01, $03, $07, $0F, $1F, $3F, $7F (every 80th frame).

	!Interval = $3F

;sprite number and information
;	set the extra bit to 2 or 3 for a custom sprite, just like in Lunar Magic.
;	up to four extra bytes are also supported for custom sprites.

	!SpriteNumber = $39
	!SpriteExtraBit = 0
	
	!SpriteExtraByte1 = $00
	!SpriteExtraByte2 = $00
	!SpriteExtraByte3 = $00
	!SpriteExtraByte4 = $00

;possible x positions (relative to the screen) where a sprite could spawn, and corresponding x speed
;	each speed is tied to a position, so those two tables must have the same size.

XPos:
	dw $FFF0,$00FF
XSpeed:
	db $10,$F0

;possible y positions (relative to the screen) where a sprite could spawn, and corresponding y speed
;	each speed is tied to to a position, so those two tables must have the same size.

YPos:
	dw $0020,$0030,$0040,$0050,$0060,$0070,$0080
YSpeed:
	db $10,$00,$10,$00,$F0,$00,$F0
TableEnd:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;generator code, do not edit unless you know asm etc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
print "MAIN ",pc
	PHB : PHK : PLB
	JSR RunGen
	PLB
	RTL

RunGen:
	LDA $14
	AND #!Interval
	ORA $9D
	ORA $13D4|!addr
	BNE Return
	
	LDX #!SprSize-1
-	LDA !14C8,x
	BEQ FoundSlot
	DEX
	BPL -

Return:
	RTS

FoundSlot:
	LDA #!SpriteNumber
if !SpriteExtraBit < 2
		STA !9E,x
else
		STA !7FAB9E,x
		JSL $0187A7|!bank
endif
	JSL $07F7D2|!bank
	LDA #!SpriteExtraBit<<2
	STA !7FAB10,x
	LDA #$01
	STA !14C8,x
	
if !SpriteExtraBit >= 2
		LDA #!SpriteExtraByte1
		STA !extra_byte_1,x
		LDA #!SpriteExtraByte2
		STA !extra_byte_2,x
		LDA #!SpriteExtraByte3
		STA !extra_byte_3,x
		LDA #!SpriteExtraByte4
		STA !extra_byte_4,x
endif
	
	LDA.b #YPos-XSpeed-1
	%Random()
	TAY
	LDA XSpeed,y
	STA !B6,x
	TYA
	ASL
	TAY
	LDA $1A
	CLC
	ADC XPos,y
	STA !E4,x
	LDA $1B
	ADC XPos+1,y
	STA !14E0,x
	
	LDA.b #TableEnd-YSpeed-1
	%Random()
	TAY
	LDA YSpeed,y
	STA !AA,x
	TYA
	ASL
	TAY
	LDA $1C
	CLC
	ADC YPos,y
	STA !D8,x
	LDA $1D
	ADC YPos+1,y
	STA !14D4,x
	
	RTS 