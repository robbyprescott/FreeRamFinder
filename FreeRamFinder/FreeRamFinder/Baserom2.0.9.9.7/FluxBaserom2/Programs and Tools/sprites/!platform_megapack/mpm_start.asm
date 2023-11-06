;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Starting point for the Mandew's Platform Megapack sprite.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
		PHB                     ; \
		PHK                     ;  | main sprite function, just calls local subroutine
		PLB                     ;  |
		JSR INIT_POINTERS		;  |
		PLB                     ;  |
		RTL                     ; /
		
print "MAIN ",pc
		PHB                     ; \
		PHK                     ;  | main sprite function, just calls local subroutine
		PLB                     ;  |
		JSR MAINCODE_POINTERS   ;  |
		PLB                     ;  |
		RTL                     ; /
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Init Pointers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INIT_POINTERS:
		LDA !extra_byte_1,x
		AND #$C0
		STA !1510,x
		BEQ +
		LDA !190F,x
		AND #$FE
		STA !190F,x
		+


		LDA !extra_byte_1,x
		AND #$3F
		STA !1504,x
		JSL $0086DF				; Pointer subroutine
	mpm_init_pointers:
	ss0:
		dw !ss0_init	; Boost platform
		dw !ss0_init	; Boost platform, infinite
	ss1:
		dw !ss1_init	; Grey falling platform, 2-tile big, falling down
		dw !ss1_init	; Grey falling platform, 4-tile big, falling down
		dw !ss1_initA	; Grey falling platform, 2-tile big, falling up
		dw !ss1_initA	; Grey falling platform, 4-tile big, falling up
		dw !ss1_init	; Grey falling platform, 2-tile big, falling right
		dw !ss1_init	; Grey falling platform, 4-tile big, falling right
		dw !ss1_init	; Grey falling platform, 2-tile big, falling left
		dw !ss1_init	; Grey falling platform, 4-tile big, falling left
	ss2:
		dw !ss2_init	; Brown left-drifting platform, 3-tile big, falling down
		dw !ss2_init	; Brown right-drifting platform, 3-tile big, falling down
	ss3:
		dw !ss3_init	; Vertical Wrapping Platform, 2-tile big, going down
		dw !ss3_init	; Vertical Wrapping Platform, 4-tile big, going down
		dw !ss3_init	; Vertical Wrapping Platform, 2-tile big, going up
		dw !ss3_init	; Vertical Wrapping Platform, 4-tile big, going up


		dw !ss1_init	; Grey falling platform, 1-tile big, falling down
		dw !ss1_initA	; Grey falling platform, 1-tile big, falling up
		dw !ss1_init	; Grey falling platform, 1-tile big, falling right
		dw !ss1_init	; Grey falling platform, 1-tile big, falling left

		dw !ss3_init	; Vertical Wrapping Platform, 1-tile big, going down
		dw !ss3_init	; Vertical Wrapping Platform, 1-tile big, going up


		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;	Main Pointers
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		
MAINCODE_POINTERS:
		LDA !1504,x
		JSL $0086DF				; Pointer subroutine
	mpm_main_pointers:
		dw !ss0_main	; Boost platform
		dw !ss0_mainA	; Boost platform, infinite
		
		dw !ss1_main	; Grey falling platform, 2-tile big, falling down
		dw !ss1_main	; Grey falling platform, 4-tile big, falling down
		dw !ss1_main	; Grey falling platform, 2-tile big, falling up
		dw !ss1_main	; Grey falling platform, 4-tile big, falling up
		dw !ss1_main	; Grey falling platform, 2-tile big, falling right
		dw !ss1_main	; Grey falling platform, 4-tile big, falling right
		dw !ss1_main	; Grey falling platform, 2-tile big, falling left
		dw !ss1_main	; Grey falling platform, 4-tile big, falling left
		
		dw !ss2_main	; Brown left-drifting platform, 3-tile big, falling down
		dw !ss2_main	; Brown right-drifting platform, 3-tile big, falling down
		
		dw !ss3_main	; Vertical Wrapping Platform, 2-tile big, going down
		dw !ss3_main	; Vertical Wrapping Platform, 4-tile big, going down
		dw !ss3_main	; Vertical Wrapping Platform, 2-tile big, going up
		dw !ss3_main	; Vertical Wrapping Platform, 4-tile big, going up

		dw !ss1_main	; Grey falling platform, 1-tile big, falling down
		dw !ss1_main	; Grey falling platform, 1-tile big, falling up
		dw !ss1_main	; Grey falling platform, 1-tile big, falling right
		dw !ss1_main	; Grey falling platform, 1-tile big, falling left
				
		dw !ss3_main	; Vertical Wrapping Platform, 1-tile big, going down
		dw !ss3_main	; Vertical Wrapping Platform, 1-tile big, going up


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Invalid
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ss_invalid:
		LDA #$01
		JSR Shared_GFX
		RTS


solid_routine:

		LDA !1510,x
		AND #$40
		BEQ +

		LDA !C2,x
		PHA
		LDA !1528,x
		PHA
		
		STZ !C2,x

		JSR Solid

		LDA !C2,x
		BEQ ++++

		LDA $15
		BPL ++++




		LDA !AA,x
		BEQ ++
		BMI ++

		LDA $1491|!addr
		BPL +++

		LDA $1491|!addr
		REP #$20
		ORA #$FF00
		CLC
		ADC $96
		STA $96
		SEP #$20
		BRA ++

		+++

		LDA $1491|!addr
		REP #$20
		AND #$00FF
		CLC
		ADC $96
		STA $96
		SEP #$20

		++

		LDA #$F6
		STA $7D




		REP #$20
		INC $96
		SEP #$20

		++++


		PLA
		STA !1528,x
		PLA
		STA !C2,x
		
		RTS

		+


		LDA !C2,x
		PHA
		LDA !1528,x
		PHA

		JSR Solid

		PLA
		STA !1528,x
		PLA
		STA !C2,x
		RTS
		




Solid:
	;JSL $01A7DC|!BankB
    
	JSL $03B664 ;get player hitbox
	JSL $03B69F ;get sprite's hitbox
 
	LDA !AA,x
	BEQ +
	BMI +

	LDA #$18
	STA $07
	BRA ++

	+
	LDA #$14
	STA $07
	++

	JSL $03B72B ;compare hitboxes	
	BCC CODE_01B4B2             ;$01B45A    |/
    LDA !D8,X                   ;$01B45C    |\ 
    SEC                         ;$01B45E    ||
    SBC $1C                     ;$01B45F    || Branch if the sprite isn't at least 1.8 blocks below Mario (i.e. he's not on top).0
    STA $00                     ;$01B461    || Oddly, this uses on-screen position,
    LDA $80                     ;$01B463    ||  hence the glitchiness if you touch a solid sprite offscreen.
    CLC                         ;$01B465    ||  It's probably meant to save bytes on cross-screen interaction.
    ADC.b #$18                  ;$01B466    ||
    CMP $00                     ;$01B468    ||
    BPL CODE_01B4B4             ;$01B46A    |/
    LDA $7D                     ;$01B46C    |\ 
    BMI CODE_01B4B2             ;$01B46E    || Return carry clear if Mario is moving up or is being pushed down by an object.
    LDA $77                     ;$01B470    || Else, he is standing on the top of the block.
    AND.b #$08                  ;$01B472    ||
    BNE CODE_01B4B2             ;$01B474    |/
    LDA.b #$10                  ;$01B476    |\\ Y speed to give Mario when sitting on top of the block.
    STA $7D                     ;$01B478    |/
    LDA.b #$01                  ;$01B47A    |\ Set Mario as standing on a solid sprite.
    STA.w $1471|!addr           ;$01B47C    |/
    LDA.b #$1F                  ;$01B47F    |\ 
    LDY.w $187A|!addr           ;$01B481    ||
    BEQ CODE_01B488             ;$01B484    ||
    LDA.b #$2F                  ;$01B486    ||
CODE_01B488:                    ;           ||
    STA $01                     ;$01B488    || Set Y position on top, accounting for Yoshi.
    LDA !D8,X                   ;$01B48A    ||
    SEC                         ;$01B48C    ||
    SBC $01                     ;$01B48D    ||
    STA $96                     ;$01B48F    ||
    LDA.w !14D4,X               ;$01B491    ||
    SBC.b #$00                  ;$01B494    ||
    STA $97                     ;$01B496    |/
    LDA $77                     ;$01B498    |\ 
    AND.b #$03                  ;$01B49A    ||
    BNE CODE_01B4B0             ;$01B49C    ||
    LDY.b #$00                  ;$01B49E    ||
    LDA.w !1528,X               ;$01B4A0    ||
    BPL CODE_01B4A6             ;$01B4A3    ||
    DEY                         ;$01B4A5    || If not blocked on the left/right,
CODE_01B4A6:                    ;           ||  slide Mario with the sprite.
    CLC                         ;$01B4A6    ||
    ADC $94                     ;$01B4A7    ||
    STA $94                     ;$01B4A9    ||
    TYA                         ;$01B4AB    ||
    ADC $95                     ;$01B4AC    ||
    STA $95                     ;$01B4AE    |/
CODE_01B4B0:                    ;           |
    SEC                         ;$01B4B0    |
    RTS                         ;$01B4B1    |

CODE_01B4B2:
    CLC                         ;$01B4B2    |
    RTS                         ;$01B4B3    |



CODE_01B4B4:                    ;```````````| Not on top of the sprite; check inside it.
	LDA.w $190F,X               ;$01B4B4    |\ 
    LSR                         ;$01B4B7    || Return carry clear if passable from below.
    BCS CODE_01B4B2             ;$01B4B8    |/
    LDA.b #$00                  ;$01B4BA    |\ 
    LDY $73                     ;$01B4BC    ||
    BNE CODE_01B4C4             ;$01B4BE    ||
    LDY $19                     ;$01B4C0    ||
    BNE CODE_01B4C6             ;$01B4C2    ||
CODE_01B4C4:                    ;           || Branch if Mario is vertically inside the sprite,
    LDA.b #$08                  ;$01B4C4    ||  accounting for powerup, ducking, and Yoshi.
CODE_01B4C6:                    ;           ||
    LDY.w $187A|!addr           ;$01B4C6    || Pushes Mario out of the sprite if so, and
    BEQ CODE_01B4CD             ;$01B4C9    ||  returns carry clear.
    ADC.b #$08                  ;$01B4CB    ||
CODE_01B4CD:                    ;           ||
    CLC                         ;$01B4CD    ||
    ADC $80                     ;$01B4CE    ||
    CMP $00                     ;$01B4D0    ||
    BCC CODE_01B505             ;$01B4D2    |/
    LDA $7D                     ;$01B4D4    |\ Return carry clear if Mario is moving downwards (not jumping up and hitting the bottom of it).
    BPL CODE_01B4F7             ;$01B4D6    |/
    LDA.b #$10                  ;$01B4D8    |\\ Y speed to give Mario after hitting the sprite's bottom.
    STA $7D                     ;$01B4DA    |/

CODE_01B4E2:                    ;           ||

    LDA !C2,X                   ;$01B4E7    ||\ 
    BNE CODE_01B4F2             ;$01B4E9    |||
    INC !C2,X                   ;$01B4EB    ||| Set the bounce timer for the sprite if it hasn't already been hit.

CODE_01B4F2:                    ;           |

CODE_01B4F7:                    ;           |
    CLC                         ;$01B4F7    |
    RTS                         ;$01B4F8    |

CODE_01B505: 
    RTS                         ;$01B535    |