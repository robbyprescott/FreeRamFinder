;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
; Programmable Block Bridge by dtothefourth
; Based on RealLink's disassembly
;
; Adds fully customizable dynamic phases
; And the ability to turn them on and off by touch or switches 
; And custom sizes 3-15 blocks
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


			!TouchEnable  = 1	; If 1, will not animate until being touched
			!TouchDisable = 0	; If 1, will not animate once touched
			!TouchReset   = 1   ; If 1, will stop/start again after jumping off of

			!OffDisable =    0  ; If 1, will not animate if On/Off is Off
			!OffDisableRev = 0  ; If 1, will not animate if On/Off is On

			!BluePDisable    = 0  ; If 1, will not animate if blue switch is active
			!BluePDisableRev = 0  ; If 1, will not animate if blue switch is inactive

			!SilverPDisable    = 0  ; If 1, will not animate if silver switch is active
			!SilverPDisableRev = 0  ; If 1, will not animate if silver switch is inactive

			;Phases - Turn block can be given many different phases with different directions
			;Each phase is split into A and B sides which means you can independently control each half of the block bridge if you want
			;You can add as many phases as you want by adding more numbers to each table below

			;How long the block bridge is 1 = 3 tiles, 2 = 5 tiles, 3 = 7 tiles, 4 = 9 tiles etc - end with $FF to indicate the last phase
			;Not recommended above 7 (15 blocks)
			Size:
			db $02,$02,$FF

			;Spacing between blocks for each phase in pixels, 0E is good for diagonal and 10 otherwise but other values will work 
			LengthA:
			db $10,$10
			LengthB:
			db $10,$10

			;X Direction for each phase, FF = left, 00 = none, 01 = right
			XDirA:
			db $FF,$00
			XDirB:
			db $01,$00

			;Y Direction for each phase, FF = up, 00 = none, 01 = down
			YDirA:
			db $00,$FF
			YDirB:
			db $00,$01

			TurnBlkBridgeSpeed:               db $01,$FF	;Folding speed - This can be changed, but be careful with big values
			BlkBridgeTiming:                  db $40,$40	;Timer - This can be changed to any value

			!TurnblockGFX		= #$40	;Tile to use (40 = Turnblock)
			!TurnblockProp		= #$34  ;Graphics properties (303)
			!BridgeRate			= #$01  ;Use to slow down expand rate, 0 = fullspeed, 1,3,7,F,1F etc to only expand over multiple frames


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
LDA #$00
STA !1510,x
STA !151C,x
STA !1626,x
STA !160E,x
STA !C2,x
LDA.L Size
STA !1534,x

RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR TurnBlkBridge       ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TurnBlkBridge:    
				  LDA #$00
				  if !TouchReset
				  STA !1510,x
				  endif

				  %SubOffScreen()	   	;Off screen processing
CODE_01B6DD:      JSR CODE_01B710         	;GFX Routine
				  
				  if !OffDisable
				  LDA $14AF|!Base2
				  BNE Return01B702
				  endif
				  if !OffDisableRev
				  LDA $14AF|!Base2
				  BEQ Return01B702
				  endif

				  if !BluePDisable
				  LDA $14AD|!Base2
				  BNE Return01B702
				  endif
				  if !BluePDisableRev
				  LDA $14AD|!Base2
				  BEQ Return01B702
				  endif

				  if !SilverPDisable
				  LDA $14AE|!Base2
				  BNE Return01B702
				  endif
				  if !SilverPDisableRev
				  LDA $14AE|!Base2
				  BEQ Return01B702
				  endif

				  if !TouchEnable
				  LDA !1510,x
				  BEQ Return01B702
				  endif
				  if !TouchDisable
				  LDA !1510,x
				  BNE Return01B702
				  endif


				  				  LDA !160E,x
								  TAY
								  STA $01

				  				  LDA !C2,x
								  AND #$01
								  STA $00

								  BEQ ++

								  LDA !151C,x             	;\Length reached?
			                      BNE +           	;/

								  LDA !1626,x             	;\Length reached?
								  BEQ CODE_01B703

								  BRA +


								  ++
CODE_01B6E9:                      LDA !151C,x             	;\Length reached?
CODE_01B6EC:                      CMP LengthA,Y   	; |go set time
CODE_01B6EF:                      BNE +           	;/

								  LDA !1626,x             	;\Length reached?
								  CMP LengthB,Y   	; |go set time
								  BEQ CODE_01B703

								  +
CODE_01B6F1:                      LDA !1540,X             	;Timer
CODE_01B6F4:                      ORA $9D     	;Sprites Locked
CODE_01B6F6:                      BNE Return01B702          	;not zero? Return

								  LDA $13
								  AND !BridgeRate
								  BNE Return01B702


								  LDA $00
								  BNE ++

								  LDY $01
			                      LDA !151C,x
								  CMP LengthA,Y
			                      BEQ +
								  BRA +++

								  ++
								  LDY $01
			                      LDA !151C,x
			                      BEQ +

								  +++
								  LDY $00
CODE_01B6FB:                      CLC                       	; |Add
CODE_01B6FC:                      ADC TurnBlkBridgeSpeed,Y 	; |speed to
CODE_01B6FF:                      STA !151C,X             	;/length

								  +

								  LDA $00
								  BNE ++

								  LDY $01
								  LDA !1626,x 
								  CMP LengthB,Y
								  BEQ +
								  BRA +++

								  ++
								  LDY $01
								  LDA !1626,x 
								  BEQ +

								  +++
								  LDY $00
								  CLC                       	; |Add
								  ADC TurnBlkBridgeSpeed,Y 	; |speed to
								  STA !1626,X             	;/length

								  +

Return01B702:                     RTS                       	; Return 

CODE_01B703:					  LDY $00
					              LDA BlkBridgeTiming,Y   	;\Set timer
CODE_01B706:                      STA !1540,X             	;/
	
								  LDA !C2,X
								  EOR #$01
								  STA !C2,X
								  BNE +

								  LDA !160E,X
								  INC
								  STA !160E,X
								  TAY
								  LDA Size,Y
								  CMP #$FF
								  BNE +

								  LDA #$00
								  STA !160E,X

								  +

								  LDA !160E,X
								  TAY
								  LDA Size,Y
								  STA !1534,X

Return01B70F:                     RTS                       	; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GFX Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CODE_01B710:                      %GetDrawInfo()    

								  LDA !1534,X
								  ASL #3
								  STA $05
								  TYA
								  CLC
								  ADC $05
								  TAY

			                      LDA !151C,X    
								  STA $05
								  STA $06
			                      LDA !1626,X    
								  STA $07
								  STA $08

								  LDA !1534,X
								  DEC
								  STA $04
								  STA $0B
         
								  PHX

								  LDA !160E,X
								  TAX


								  LDA !TurnblockGFX
								  STA $0302|!Base2,Y

								  LDA !TurnblockProp
								  STA $0303|!Base2,Y

								  LDA $00
								  STA $0300|!Base2,Y

								  LDA $01
								  STA $0301|!Base2,Y

								  LDA #$01
								  STA $09

								  print "interact ",pc

								  LDA XDirA,X
								  BNE +

								  LDA YDirA,X
								  BPL +


								  LDA XDirB,x
								  BEQ +++

								  LDA YDirB,x
								  CMP #$01
								  BNE +++

								  LDA #$02
								  STA $09
								  BRA ++

								  +++
								  STZ $09


								  BRA ++

								  +

								  LDA XDirB,X
								  BNE ++

								  LDA YDirB,X
								  BPL ++

								  LDA XDirA,x
								  BEQ +++

								  LDA YDirA,x
								  CMP #$01
								  BNE +++

								  LDA #$02
								  STA $09
								  BRA ++

								  +++
								  STZ $09

								  ++
								  
								  PLX
								  PHX
								  JSR Interact

								  LDA !160E,X
								  TAX

								  DEY #4

								- LDA !TurnblockGFX
								  STA $0302|!Base2,Y

								  LDA !TurnblockProp
								  STA $0303|!Base2,Y

								  LDA #$01
								  STA $09

								  LDA XDirA,X
								  BEQ ++
								  BMI +

								  LDA $00
								  CLC
								  ADC $06
								  STA $0300|!Base2,Y
								  BRA +++

								  +
								  LDA $00
								  SEC
								  SBC $06
								  STA $0300|!Base2,Y
								  BRA +++

								  ++

								  LDA YDirA,X
								  BMI ++++

								  LDA $04
								  BNE ++++++

								  LDA #$02
								  STA $09
								  BRA +++++

								  ++++++

								  STZ $09

								  BRA +++++
								  ++++

								  LDA $04
								  BEQ +++++

								  STZ $09

								  +++++

								  LDA $00
								  STA $0300|!Base2,Y

								  +++


								  LDA YDirA,X
								  BEQ ++
								  BMI +

								  LDA $01
								  CLC
								  ADC $06
								  STA $0301|!Base2,Y
								  BRA +++

								  +
								  LDA $01
								  SEC
								  SBC $06
								  STA $0301|!Base2,Y
								  BRA +++

								  ++

								  LDA $01
								  STA $0301|!Base2,Y

								  +++


								  PLX
								  PHX
								  LDA !151C,x
								  BEQ +++

								  JSR Interact

								  +++

								  LDA !160E,X
								  TAX

								  DEY #4

								  LDA !TurnblockGFX
								  STA $0302|!Base2,Y

								  LDA !TurnblockProp
								  STA $0303|!Base2,Y

								  LDA #$01
								  STA $09

								  LDA XDirB,X
								  BEQ ++
								  BMI +

								  LDA $00
								  CLC
								  ADC $08
								  STA $0300|!Base2,Y
								  BRA +++

								  +
								  LDA $00
								  SEC
								  SBC $08
								  STA $0300|!Base2,Y
								  BRA +++

								  ++

								  LDA YDirB,X
								  BMI ++++

								  LDA $04
								  BNE ++++++

								  LDA #$02
								  STA $09
								  BRA +++++

								  ++++++

								  STZ $09

								  BRA +++++
								  ++++

								  LDA $04
								  BEQ +++++

								  STZ $09

								  +++++


								  LDA $00
								  STA $0300|!Base2,Y

								  +++


								  LDA YDirB,X
								  BEQ ++
								  BMI +

								  LDA $01
								  CLC
								  ADC $08
								  STA $0301|!Base2,Y
								  BRA +++

								  +
								  LDA $01
								  SEC
								  SBC $08
								  STA $0301|!Base2,Y
								  BRA +++

								  ++

								  LDA $01
								  STA $0301|!Base2,Y

								  +++

								  PLX								  								  
								  PHX
								  
								  LDA !1534,x
								  BEQ +++

								  JSR Interact

								  +++

								  LDA !160E,X
								  TAX

								  DEY #4

								  LDA $06
								  CLC
								  ADC $05
								  STA $06

								  LDA $08
								  CLC
								  ADC $07
								  STA $08

								  DEC $04
								  BMI +
								  JMP -
								  +

								  PLX
								  LDA !1534,X	; Tile to draw - 1
								  ASL
								  LDY #$02	; 16x16 sprite
								  JSL $01B7B3
								  RTS
print "interact ",pc
Interact:
	LDA !D8,x
	PHA
	LDA !14D4,x
	PHA
	LDA !E4,x
	PHA
	LDA !14E0,x
	PHA

	LDA $7D
	PHA

	REP #$20

	LDA $96
	PHA

	LDA $00
	PHA
	LDA $02
	PHA
	LDA $04
	PHA
	LDA $06
	PHA
	LDA $08
	PHA
	SEP #$20

	LDA $0300|!Base2,Y
	SEC
	SBC $00
	BMI +

	CLC
	ADC !E4,x
	STA !E4,x
	LDA !14E0,x
	ADC #$00
	STA !14E0,x
	BRA ++
	+
	CLC
	ADC !E4,x
	STA !E4,x
	LDA !14E0,x
	SBC #$00
	STA !14E0,x
	++

	LDA $0301|!Base2,Y
	SEC
	SBC $01
	BMI +

	CLC
	ADC !D8,x
	STA !D8,x
	LDA !14D4,x
	ADC #$00
	STA !14D4,x
	BRA ++
	+
	CLC
	ADC !D8,x
	STA !D8,x
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
	++


	LDA $1471|!addr
	PHA

	PHY
	JSL $01B44F
	PLY

	STZ $0F
	BCC +
	LDA #$01
	STA $0F
	+

	PLA
	STA $0A

	REP #$20
	PLA
	STA $08
	PLA
	STA $06
	PLA
	STA $04
	PLA
	STA $02
	PLA
	STA $00

	PLA
	STA $0C


	SEP #$20

	PLA
	STA $0B


	LDA $1DF9|!addr
	CMP #$01
	BNE +
	STZ $1DF9|!addr

	LDA $09
	CMP #$02
	BEQ ++++

	+


	LDA $0A
	BNE +

	LDA $09
	CMP #$01
	BEQ +

	+++
	LDA #$00
	STA $1471|!addr

	REP #$20
	LDA $0C
	STA $96
	SEP #$20

	LDA $0B
	STA $7D

	LDA $0F
	BEQ +

	;;;;;If Mario to the right, increase X? Getting glued to right side
	LDA !14E0,x
	XBA
	LDA !E4,x

	REP #$20
	CMP $94
	BPL +
	INC $94
	++

	+
	SEP #$20

	++++

	if !TouchEnable || !TouchDisable
	BCC +
	LDA $1471|!addr
	BEQ +
	LDA #$01
	STA !1510,x
	+
	endif

	

	PLA
	STA !14E0,x
	PLA
	STA !E4,x
	PLA
	STA !14D4,x
	PLA
	STA !D8,x
	

	RTS