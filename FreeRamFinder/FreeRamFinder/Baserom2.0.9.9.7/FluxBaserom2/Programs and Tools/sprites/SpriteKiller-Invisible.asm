;;
;
; Sprite killer box
;
; This invisible sprite will kill any sprite is comes in contact with.
;
; Version 1.1 by Darolac
;
; -Added the option to kill sprites on the same line of the sprite.
; -Converted to PIXI
; -Optimized the code.
;;
!Line = 0 	; if this is anything other than 0, this sprite will kill other sprites on the same line.
!Vert = #$0010	; vertical proximity to the sprite that will make the sprite dissapear. Only used when !Line is set.

print	"MAIN ", pc           
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR KillSpr_Start		;  |
                    PLB                     ;  |
print	"INIT ", pc	
                    RTL                     ; /
					
;;;;;;;;;;;;;;

Skip:
	RTS

KillSpr_Start:
		LDA !14C8,x
		EOR #$08
		ORA $9D	; Lock Flag
		BNE Skip	
		%SubOffScreen()
		BCS Skip
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if !Line = 0
		JSL	$03B69F	; Get Sprite Clipping A.
else
		LDA !D8,x	; Store sprite position on scratch RAM
		ADC #$08
		STA $00
		LDA !14D4,x
		ADC #$00
		STA $01
endif	

	
		LDX #!SprSize
	---
		DEX
		BPL +
		LDX $15E9|!Base2
		RTS
		+

		CPX $15E9|!Base2
		BEQ ---
		
		LDA !14C8,x
		CMP #$08
		BCC ---
	
if !Line = 0	
		JSL $03B6E5 ; Get Sprite Clipping B.
		
		JSL $03B72B	; Check for contact.
		BCC --- 	; No Contact, go back.
else
		LDA !14D4,x
		XBA
		LDA !D8,x
		REP #$20
		SEC
		SBC $00
		BPL +
		EOR #$FFFF
		INC
		+
		CMP !Vert
		SEP #$20
		BCS ---
		
		JSL $03B6E5
endif
		LDA $02 ; $02 - Clipping width
		LSR
		CLC
		ADC $00 ; $00 - Clipping X displacement low
		STA $00

		LDA #$00
		ADC $08 ; $08 - Clipping X displacement, high
		XBA
		LDA $00

		REP #$20
		SEC
		SBC.w #$0008
		PHA
		SEC
		SBC $1A
		CMP.w #$0100
		PLA
		SEP #$20
		BCS .offscreen
		STA $0C

		LDA $03 ; $03 - Clipping height
		LSR
		CLC
		ADC $01 ; $01 - Clipping Y displacement low
		STA $01

		LDA #$00
		ADC $09 ; $09 - Clipping Y displacement, high
		XBA
		LDA $01

		REP #$20
		SEC
		SBC.w #$0008
		PHA
		SEC
		SBC $1C
		CMP.w #$0100
		PLA
		SEP #$20
		BCS .offscreen
		
		LDY $1863|!Base2	; Get smoke sprite index.

		STA $17C4|!Base2,y	; Y position
		
		LDA #$01
		STA $17C0|!Base2,y	; Smoke sprite type (smoke)
		LDA $0C
		STA $17C8|!Base2,y	; Smoke X position
		LDA #20
		STA $17CC|!Base2,y	; Timer
		
		LDA #$25
		STA $1DFC|!Base2	; Sound effect (Yoshi stomps)

.offscreen
		STZ !14C8,x
		
+++
		LDX $15E9|!Base2
		RTS