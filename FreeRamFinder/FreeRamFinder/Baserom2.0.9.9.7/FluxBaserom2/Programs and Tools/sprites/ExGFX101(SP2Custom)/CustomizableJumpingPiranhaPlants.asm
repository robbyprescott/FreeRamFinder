; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; jumping piraniha plant plus															;
; by EternityLarva																		;
; edited by dogemaster																	;
;																						;
; extra_byte_1 = piranha direction and other properties									;
; format: J----RDD																		;
; J bit = jump anyway ignoring mario													;
; R bit = if set, piranha will be fully red												;
; DD bits =																				;
;  00 - up																				;
;  01 - left																			;
;  10 - down																			;
;  11 - right 																			;
;																						;
; extra_byte_2 = initial timer before jumping											;
; 00 - first jump timer - FF															;
;																						;
; extra_byte_3 = speed with which the piranha jumps										;
; value = 00 to 7F																		;
;																						;
; extra_bits = fireball spit flag														;
; value 2 or 3																			;
; if set the piranha will spit fireballs												;																;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!extended_sprite = $06  ;extended sprite number, "fireball_plus.asm"

!reverse_flag = $00     ;00 -> no patch
                        ;?? or ?????? -> reverse flag

tile:
db $AE,$AE,$C4,$C5  ;vertical tilemap, normally $AE,$AC,$C4,$C5
db $AC,$AC,$83,$83  ;horizontal tilemap, normally $CC,$E6,$EB,$FB

xpos:
db $00,$00,$08 ;up 
db $00,$10,$10 ;left
db $00,$00,$08 ;down
db $00,$F8,$F8 ;right

ypos:
db $00,$10,$10 ;up
db $00,$00,$08 ;left
db $00,$F8,$F8 ;down
db $00,$00,$08 ;right

prop:
db $08,$0A,$4A ;up
db $48,$4A,$CA ;left
db $88,$8A,$CA ;down
db $08,$0A,$8A ;right

speed2:
db $F0,$F0,$10,$10	;???

tabletable:
db $00,$03,$06,$09	;the most genius name given to a table

size:
db $02,$00,$00	;table for the size of the tiles to draw

coltable:	
db $0A,$08	;???

;init_x:
;dw $0008,$FFFF,$0008,$0001
;init_y:
;dw $FFFF,$0008,$0001,$0008

xspd:
db $10,$F0,$C0,$C0,$10,$F0,$40,$40	;xspeeds of the piranhas obviously
yspd:
db $C0,$C0,$10,$F0,$40,$40,$10,$F0	;yspeeds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

	LDA !extra_byte_2,x		;\ set initial jump timer
	STA !sprite_misc_1540,x	;/

	LDA !extra_byte_1,x		;\ make stuff branch epicly so that it can set up the correct variables for the correct piranha type
	AND #$03				;|
	BEQ init_up				;|
	CMP #$01				;|
	BEQ init_left			;|
	CMP #$02				;|
	BEQ init_down			;/

init_right:
	LDA !sprite_y_low,x		;\ setting up displacements correcctly and some 16-bit quickmaffs, same goes for the other inits
	CLC						;|
	ADC #$08				;|
	STA !sprite_y_low,x		;|
	LDA !sprite_y_high,x	;|
	ADC #$00				;|
	STA !sprite_y_high,x	;|
	LDA !sprite_x_low,x		;|
	SEC						;|
	SBC #$01				;|
	STA !sprite_x_low,x		;|
	LDA !sprite_x_high,x	;|
	SBC #$00				;|
	STA !sprite_x_high,x	;/
RTL 

init_down:
	LDA !sprite_y_low,x		; same here
	SEC
	SBC #$01
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	SBC #$00
	STA !sprite_y_high,x
	LDA !sprite_x_low,x
	CLC
	ADC #$08
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
RTL 

init_left:
	LDA !sprite_y_low,x		;and here too
	CLC
	ADC #$08
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	ADC #$00
	STA !sprite_y_high,x
	LDA !sprite_x_low,x
	CLC
	ADC #$01
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
RTL 

init_up:
	LDA !sprite_y_low,x		;aaaaand here too
	CLC
	ADC #$01
	STA !sprite_y_low,x
	LDA !sprite_y_high,x
	ADC #$00
	STA !sprite_y_high,x
	LDA !sprite_x_low,x
	CLC
	ADC #$08
	STA !sprite_x_low,x
	LDA !sprite_x_high,x
	ADC #$00
	STA !sprite_x_high,x
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR JumpingPiranhaMain
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JumpingPiranhaMain:
	LDA $64					;i dont understand shit from here until the next comment
	PHA
	LDA #$10
	STA $64
	JSR gfx
	PLA
	STA $64
	LDA #$00
	%SubOffScreen()
	LDA $9D
	BNE return

	LDA #!reverse_flag
	BEQ p
	LDA !reverse_flag
	BNE q
p:
	JSL $01803A|!BankB
	BRA r
q:
	JSR reverse_contact
	JSL $019138|!BankB		;object interaction routine
r:
	LDA !extra_byte_1,x		
	AND #$01
	BNE +
	JSL $01801A|!BankB
	BRA ++
+
	JSL $018022|!BankB
++
	LDA !sprite_misc_c2,x	;c2 is the sprite state pointer
	JSL $0086DF|!BankB		;this'll direct it to the correct state

	dw State00				;jumping state
	dw State01				;not sure about this one
	dw State02				;fire spit state and falling state

return:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code for sprite state 00 (jumping state)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State00:

	STZ !sprite_speed_y,x	;\ stop the piranha as it first appears to be stopped before jumping
	STZ !sprite_speed_x,x	;/
	LDA !sprite_misc_1540,x ;\ let the jump timer expire 
	BNE +					;/

	%SubHorzPos()			;\ check mario's position and see if he is in the line of sight of the piranha
	LDA !extra_byte_1,x		;| if the highest bit if set then jump anyway ingnoring mario proximity and other bullshit
	BMI jump				;/
	LDA $0E					;\ just a proximity comparison
	CLC						;|
	ADC #$1B				;|
	CMP #$37				;|
	BCC +					;/
jump:
	LDA !extra_byte_1,x		;\ if extra_byte_1's value of the first 2 bits is smaller than 2, then branch and give the correct speed
	AND #$03				;| and vice versa
	CMP #$02				;|
	BCS ++					;|
	LDA !extra_byte_3,x		;|
	EOR #$FF				;|
	INC						;|
	BRA +++					;|
	++						;|
	LDA !extra_byte_3,x		;|
	+++						;|
	STA !sprite_speed_y,x	;|
	STA !sprite_speed_x,x	;/
	INC !sprite_misc_c2,x	; increase state pointer's value
	STZ !sprite_misc_1602,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code for sprite state 01(not sure about this one)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State01:

	LDA !extra_byte_1,x
	AND #$02
	BNE label21

	LDA !sprite_speed_y,x
	BEQ +
	BMI +
	CMP !extra_byte_3,x
	BCS ++
+
	CLC
	ADC #$02
	STA !sprite_speed_y,x
	STA !sprite_speed_x,x
++
	INC !sprite_misc_1570,x
	LDA !sprite_speed_y,x
	CMP #$F1
	BMI +
	LDA #$50
	STA !sprite_misc_1540,x
	INC !sprite_misc_c2,x
+
	RTS

label21:
	LDA #$FF
	SEC 
	SBC !extra_byte_3,x
	STA $03
	LDA !sprite_speed_y,x
	BPL +
	CMP $03
	BCC ++
+
	SEC
	SBC #$02
	STA !sprite_speed_y,x
	STA !sprite_speed_x,x

++

	INC !sprite_misc_1570,x
	LDA !sprite_speed_y,x
	CMP #$10
	BPL +
	LDA #$50
	STA !sprite_misc_1540,x
	INC !sprite_misc_c2,x
+
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; code for sprite state 02
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State02:

	INC !sprite_misc_151c,x
	LDA !sprite_misc_1540,x;
	BNE MaybeSpitFire

NoFire:

	INC !sprite_misc_1570,x
	LDA $14
	AND #$03
	BNE label22

	LDA !extra_byte_1,x
	AND #$02
	BNE +

	LDA !sprite_speed_y,x
	CMP #$08
	BPL ++
	INC		;
	BRA ++
+
	LDA !sprite_speed_y,x
	CMP #$F9
	BMI ++
	DEC		;
++
	STA !sprite_speed_y,x
	STA !sprite_speed_x,x

blockedsidetable:			;table for which piranha should check which side of itself
	db $04,$01,$08,$02
	
label22:
	PHY						; push Y cuz we messed with that 
	JSL $019138|!BankB		; interact with objects
	LDA !extra_byte_1,x		;\ use the first 2 bits of the extra byte as table index
	AND #$03				;|
	TAY						;/
	LDA !1588,x	;			;
	AND blockedsidetable,y	;\ if the sprite is touching ground
	BEQ .keepfalling		;| if no then keep falling and just let it be in the falling state
	STZ !C2,x				;| reset the sprite state to 0
	LDA #$40				;| and set the jumping timer again
	STA !1540,x				;| 
.keepfalling				;/
	PLY						; restore Y so no oopsies happen
	RTS

MaybeSpitFire:

	LDA !extra_bits,x	;
	AND #$04
	BEQ NoFire

	STZ !sprite_misc_1570,x

	LDA !sprite_misc_1540,x
	CMP #$40
	BNE NoFire
	LDA !15A0,x
	ORA !186C,x
	BEQ .skip 
	JSR NoFire
.skip

	STZ $04
	JSR fireball
	LDA #$01
	STA $04

fireball:
	LDA #$04
	STA $00
	STZ $01
	LDA !extra_byte_1,x
	AND #$03
	ASL
	ORA $04
	TAY
	LDA xspd,y
	STA $02
	LDA yspd,y
	STA $03
	LDA #!extended_sprite+!ExtendedOffset
	%SpawnExtended()
	LDA !extra_byte_1,x
	AND #$03
	STA !extended_behind,y
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Reverse Contact Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reverse_contact:
	
	JSR ProcessInteract
	BCC return_rev
	LDA $1490|!Base2
	BNE kill_sprite
	LDA $140D|!Base2
	ORA $187A|!Base2
	BEQ hurt
	LDA $7D
	CMP #$10
	BMI hurt
	REP #$20
	LDA $96
	PHA
	SEC
	SBC #$0010
	STA $96
	SEP #$20
	JSL $01AB99|!BankB
	REP #$20
	PLA
	STA $96
	SEP #$20
	JSL $01AA33|!BankB
	LDA #$02
	STA $1DF9|!Base2
	LDA #$10
	STA !sprite_misc_1558,x
return_rev:
	RTS
hurt:
	LDA !sprite_misc_1558,x
	BNE +
	JSL $00F5B7|!BankB
+
	RTS
kill_sprite:
	%Star()
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Process Interactt Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessInteract:
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #$000C
	CMP #$0018
	BCS return_clr2
	SEP #$20
	%SubVertPos()
	LDA $0F
	CLC
	ADC #$0C
	CMP #$18
	BCS return_clr
	SEC
	RTS
return_clr2:
	SEP #$20
return_clr:
	CLC
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphic routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gfx:
	%GetDrawInfo()

	PHY
	LDA !extra_byte_1,x
	AND #$03
	TAY
	LDA tabletable,y
	STA $03
	PLY

	LDA !extra_byte_1,x
	AND #$03
	ASL #2
	AND #$04
	STA $02

	LDA !sprite_misc_151c,x
	AND #$04
	LSR #2
	ORA $02
	STA $04

	LDA !sprite_misc_1570,x
	AND #$08
	LSR #3
	ORA $02
	STA $05
	
	PHY
	LDA !extra_byte_1,x
	AND #$04
	LSR #2
	TAY
	LDA coltable,y
	STA $06
	PLY

	PHX
	LDX #$02
-
	PHX
	TXA
	CLC
	ADC $03
	TAX
	LDA $00
	CLC
	ADC xpos,x
	STA $0300|!Base2,y
	PLX

	PHX
	TXA
	CLC
	ADC $03
	TAX
	LDA $01
	CLC
	ADC ypos,x
	STA $0301|!Base2,y
	PLX

	PHX
	TXA
	BEQ +
	LDA #$02
	ORA $04
	BRA ++
+
	ORA $05
++
	TAX
	LDA tile,x
	STA $0302|!Base2,y
	PLX

	PHX
	TXA
	CLC
	ADC $03
	TAX
	LDA prop,x
	PLX
	
	CPX #$00
	BEQ +
	AND #$F1
	ORA $06
+
	ORA $64
	STA $0303|!Base2,y

	PHX
	LDA size,x
	PHA
	TYA
	LSR #2
	TAX
	PLA
	STA $0460|!Base2,x
	PLX

	INY #4
	DEX
	BPL -
	PLX
	LDY #$FF
	LDA #$02
	JSL $01B7B3|!BankB
	RTS