;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Sprite Carrying Lakitu cloud by dtothefourth
;; Based on the cloud disassembly by mellonpizza
;;
; Options are set using the extension box in LM using 4 bytes
;
; SS XX YY MC
; 
; SS = Sprite number
; XX = X offset for position sprite
; YY = Y offset for position sprite
; M  = Movement type (set speeds below)
;		0 (or any invalid value) - Stationary
;		1 - Straight line
;		2 - Follow Mario
;		3 - Avoid Mario
;		4 - Back and forth 
;		5 - Up and down
;		6 - Programmable (uses the tables below)
;
; C  = Custom sprite settings, any non-zero will make it a
;	   custom sprite, and 4 (or anything with 4 bit) will set the
;	   extra bit on the sprite. 
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Time  = #$00 ; If 0, lasts forever. Otherwise poofs and drops the sprite when time runs out


!XSpeed = #$10 ; X Speed / Max Speed if moving
!YSpeed = #$10 ; X Speed / Max Speed if moving
!Rate   = #$03 ; How often to accelerate for movements 4/5 ANDed with frame counter (0,1,3,7,F,1F)

!DistX = #$0040 ; How close/far to get or stay away for follow and avoid movements
!DistY = #$0010 ; How close/far to get or stay away for follow and avoid movements

;Tiles used for drawing cloud
CloudTiles:
	db $66,$64,$62,$60

!State = #$01 ;State to start spawned sprite in. Usually 1 is fine but shells for example require 9

;Tables for programmable motion

;How many frames for each phase of movement, use $00 to end and loop back to the beginning
;The sample entries here move in a triangle in three phases
TimeInState:
db $40,$40,$40,$00

;X and Y speeds for each phase, you need one of these for each time entry except the final $00
XSpeed:
db $10,$00,$F0
YSpeed:
db $F0,$10,$00






print "INIT ",pc
	LDA.L TimeInState	;
	STA !163E,x

	LDA !Time
	STA !1626,x

	LDA #$00
	STA !C2,X
	STA !1510,X
	STA !151C,X

	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
		PHB
		PHK
		PLB
		JSR LakituCloud
		PLB
		RTL                       ; Return

DATA_01E76F:
	db $FC,$04,$FE,$02,$FB,$05,$FD,$03
	db $FA,$06,$FC,$04,$FB,$05,$FD,$03
DATA_01E77F:
	db $00,$FF,$03,$04,$FF,$FE,$04,$03
	db $FE,$FF,$03,$03,$FF,$00,$03,$03
	db $F8,$FC,$00,$04

DATA_01E793:
	db $0E,$0F,$10,$11,$12,$11,$10,$0F
	db $1A,$1B,$1C,$1D,$1E,$1D,$1C,$1B
	db $1A

DoSpawn:
	JSL $02A9DE|!BankB
	BMI EndSpawn

	TYA
	STA !160E,x


	LDA !extra_byte_4,x
	AND #$0F
	STA $0F
	BEQ +

	LDA !extra_byte_1,x
	PHX
	TYX
	STA !7FAB9E,x
	PLX
	BRA ++
	+
	LDA !extra_byte_1,x
	STA !9E,y
	++

	LDA !E4,x
	STA !E4,y
	LDA !14E0,x
	STA !14E0,y
	LDA !D8,x
	STA !D8,y	
	LDA !14D4,x
	STA !14D4,y	
	PHX
	TYX
	JSL $07F7D2|!BankB

	LDA $0F
	BEQ +

		AND #$04
		ORA #$08
		STA !7FAB10,x
		JSL $0187A7|!BankB

	+

	PLX

	LDA !State
	STA !14C8,y

	RTS
EndSpawn:
	STZ !14C8,x
	RTS

LakituCloud:
		LDA $9D				; \ Branch if sprites locked
		BEQ NoCloudGfx		; /
BraToJmpGfx:
		JMP LakituCloudGfx

NoCloudGfx:



		LDA !151C,x
		BNE +

		LDA !15A0,x
		BNE BraToJmpGfx

		JSR DoSpawn
		LDA !14C8,x
		BEQ BraToJmpGfx

		LDA #$01
		STA !151C,x

		+



		LDA $14				; \ Decrement every 4th frame
		AND #$03			; |
		BNE +				; /
		LDA !1626,x		; \ Don't decrement if 0
		BEQ +		
		DEC
		STA !1626,x		; \ Store value to timer if $18E0 reached 0
		BNE +				; |
		LDA #$1F			; |
		STA !1540,x			; |
		+				; /
		LDA !1540,x			; \ Go to correct place based on timer
		BEQ NoPuffAway			; |
		DEC A				; |
		BNE BraToJmpGfx			; |
		STZ !14C8,x			; /
		RTS                       ; Return

NoPuffAway:

		LDA !160E,x
		TAY 

		LDA !14C8,y
		CMP #$01
		BEQ +
		CMP #$08
		BEQ +
		CMP #$09
		BEQ +

		LDA #$1F
		STA !1540,x

		BRA BraToJmpGfx

		+

LakituExists:

		LDA !extra_byte_4,x
		AND #$F0
		LSR #4
		CMP #$01
		BNE +

		LDA !XSpeed
		STA !B6,x
		LDA !YSpeed
		STA !AA,x
		JMP ++

		+
		CMP #$02
		BEQ +++
		JMP +
		+++

		%SubHorzPos()

		REP #$20
		LDA $0E
		BPL +++
		EOR #$FFFF
		INC
		+++
		CMP !DistX
		SEP #$20
		BCS NotCloseX

		LDA #$00
		STA !B6,x

		BRA +++

		NotCloseX:

		CPY #$00
		BNE +++

		LDA !B6,x
		CMP !XSpeed
		BEQ ++++
		INC
		STA !B6,x
		BRA ++++

		+++

		LDA !XSpeed
		EOR #$FF
		INC
		CMP !B6,x
		BEQ ++++
		LDA !B6,x
		DEC
		STA !B6,x


		++++


		%SubVertPos()

		STA $0D
		LDA $0F
		STA $0E
		LDA $0D
		STA $0F

		REP #$20
		LDA $0E
		BPL +++
		EOR #$FFFF
		INC
		+++
		CMP !DistY
		SEP #$20
		BCS NotCloseY

		LDA #$00
		STA !AA,x
		BRA +++

		NotCloseY:

		CPY #$00
		BNE +++

		LDA !AA,x
		CMP !YSpeed
		BEQ ++++
		INC
		STA !AA,x
		BRA ++++

		+++

		LDA !YSpeed
		EOR #$FF
		INC
		CMP !AA,x
		BEQ ++++
		LDA !AA,x
		DEC
		STA !AA,x


		++++
		JMP ++

		+
		CMP #$03
		BNE +

		%SubHorzPos()
		CPY #$01
		BNE +++

		LDA !B6,x
		CMP !XSpeed
		BEQ ++++
		INC
		STA !B6,x
		BRA ++++

		+++

		LDA !XSpeed
		EOR #$FF
		INC
		CMP !B6,x
		BEQ ++++
		LDA !B6,x
		DEC
		STA !B6,x


		++++


		%SubVertPos()
		CPY #$01
		BNE +++

		LDA !AA,x
		CMP !YSpeed
		BEQ ++++
		INC
		STA !AA,x
		BRA ++++

		+++

		LDA !YSpeed
		EOR #$FF
		INC
		CMP !AA,x
		BEQ ++++
		LDA !AA,x
		DEC
		STA !AA,x

		++++
		JMP ++

		+
		CMP #$04
		BNE +

		LDA $14
		AND !Rate
		BNE ++

		LDA !C2,x
		BNE ++++

		LDA !B6,x
		INC
		STA !B6,x
		CMP !XSpeed
		BNE ++
		LDA #$01
		STA !C2,x
		BRA ++
		++++
		LDA !B6,x
		DEC
		STA !B6,x
		EOR #$FF
		INC
		CMP !XSpeed
		BNE ++
		LDA #$00
		STA !C2,x
		BRA ++


		+
		CMP #$05
		BNE +

		LDA $14
		AND !Rate
		BNE ++

		LDA !C2,x
		BNE ++++

		LDA !AA,x
		INC
		STA !AA,x
		CMP !YSpeed
		BNE ++
		LDA #$01
		STA !C2,x
		BRA ++
		++++
		LDA !AA,x
		DEC
		STA !AA,x
		EOR #$FF
		INC
		CMP !YSpeed
		BNE ++
		LDA #$00
		STA !C2,x
		BRA ++



		+
		CMP #$06
		BNE ++

		LDA !163E,x
		BNE NoStateChange	;


		INC !1510,x	; increment the sprite state
		-
		LDA !1510,x	;
		TAY		;
		LDA TimeInState,y	;
		BNE +
		STZ !1510,x
		BRA -
		+
		STA !163E,x


		NoStateChange:	;
		LDA !1510,x	;
		TAY		;

		LDA XSpeed,y	;
		STA !B6,x		; if we're moving horizontally, store the speed value to the X speed table

		LDA YSpeed,y	;
		STA !AA,x	; if we're moving vertically, store the speed value to the Y speed table



		++

		JSL $01801A
		JSL $018022

		STZ $01
		LDA !extra_byte_2,x
		STA $00
		BPL +
		LDA #$FF
		STA $01
		+

		STZ $03
		LDA !extra_byte_3,x
		STA $02
		BPL +
		LDA #$FF
		STA $03
		+

		LDA !160E,x
		TAY

		LDA !14E0,x         ; |
		XBA
		LDA !E4,x           ; \ Set lakitu's position

		REP #$20
		CLC
		ADC $00
		SEP #$20

		STA !E4,y         ; |
		XBA
		STA !14E0,y         ; |
	
		
		LDA !14D4,x         ; |
		XBA
		LDA !D8,x           ; \ Set lakitu's position

		REP #$20
		CLC
		ADC $02
		SEP #$20

		STA !D8,y         ; |
		XBA
		STA !14D4,y         ; |

macro nexttile()
	?loop:
	LDA $0201|!addr,y
	CMP #$F0
	BEQ ?end
	INY #$4
	CPY #$00
	BNE ?loop
	RTS
	?end:
endmacro

LakituCloudGfx:
		%GetDrawInfo()
		LDA !186C,x			; \ If offscreen vertically, no drawing.
		BEQ +
		-
		RTS
		+

			
		LDA !15C4,x         		; \ Skip if offscreen horizontally
		BNE -

		LDA !E4,x
		STA $04

		LDA !14E0,x
		STA $05


		REP #$20
		LDA $04
		SEC
		SBC $1A
		SEC
		SBC #$0004
		STA $04
		ADC #$0010
		STA $06
		SEP #$20

		
		LDA $00				; \ GFX x and y to scratch ram
		STA $14B0|!Base2		; |
		LDA $01  	           	; |
		STA $14B2|!Base2          	; /
		LDA $14             		; \ Frame index to $02
		LSR                 		; |
		LSR                 		; |
		AND #$0C            		; |
		STA $02             		; /
		LDA #$03            		; \ Tiles to draw
		STA $03             		; /

		LDY #$30


		-                   		;
		%nexttile()	

		LDA $03             		; \ Set index of drawn tile
		CLC                 		; |
		ADC $02             		; |
		TAX                 		; |
		LDA DATA_01E76F,x   		; |
		CLC                 		; |
		ADC $14B0|!Base2    		; |
		STA $0200|!Base2,y         	; /
		STA $0F
		LDA DATA_01E77F,x   		; \ Ypos
		CLC                 		; |
		ADC $14B2|!Base2    		; |
		STA $0201|!Base2,y        	; /

		LDX $15E9|!Base2	        ; X = Sprite index
		LDA #$60            		; \ Cloud tile
		STA $0202|!Base2,y         	; /
		
		LDA !1540,x         		; \ Cloud tile when dissapearing
		BEQ +               		; |
		LSR #3              		; |
		TAX                 		; |
		LDA CloudTiles,x    		; |
		STA $0202|!Base2,y         	; |
		+                   		; /

		LDA $64             		; \ Property
		STA $0203|!Base2,y         	; /


		print "do ",pc

		LDA $05
		BPL ++

		
		LDA $0F
		BPL +++++

		---
		LDA #$01
		STA $0F

		BRA +++
		++

		BEQ ++++

		--
		LDA #$F0
		STA $0201|!Base2,y
		BRA Next2

		++++

		LDA $04
		CMP #$E0
		BCC +++++

		LDA $0F
		BPL --
		BRA ++

		+++++



		LDA $0F
		CMP #$F0
		BCS ---

		++

		STZ $0F

		+++

		PHY
		TYA
		LSR #2
		TAY
		LDA $0F
		ORA #$02
		STA $0420|!addr,y
		PLY

Next2:

		INY #4              		; > Increase OAM index
		DEC $03             		; \ Loop until all tiles drawn
		LDA $03
		BMI +
		JMP -               		; /
		+

		

		



Return01E984:               ;
		LDX $15E9|!Base2           	; X = Sprite index
		LDA #$03
		%SubOffScreen()

		RTS                 ; Return

