;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Interactable Yoshi fireball with blocks.
;; By LX5
;;
;; This patch gives to Yoshi's fireballs the ability to interact with Layer 1 blocks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!use_map16_only = 1

if read1($00FFD5) == $23
	sa1rom
	!SA1 = 1
	!base1 = $3000
	!base2 = $6000
	!base3 = $000000
else
	lorom
	!SA1 = 0
	!base1 = $0000
	!base2 = $0000
	!base3 = $800000
endif

!EXLEVEL = 0
if (((read1($0FF0B4)-'0')*100)+((read1($0FF0B4+2)-'0')*10)+(read1($0FF0B4+3)-'0')) > 253
	!EXLEVEL = 1
endif

!a = autoclean

org $029F68|!base3		;Hijack some Yoshi fireball code which doesn't runs when game is paused.
!a	JML	block_fire

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Macros, add more if needed.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

macro generate_smw_tile(value)
	LDA.b	#<value>
	STA	$9C
	JSL	$00BEB0|!base3
endmacro

macro generate_smoke()
	JSR	DrawSmoke
endmacro

macro return()
	JMP	block_fire_return
endmacro

macro shatter_block(type)
	PHB
	LDA	#$02
	PHA
	PLB
	LDA.b	#<type>
	JSL	$028663|!base3
	PLB
endmacro

macro kill_fire()
	STZ	$170B|!base2,x
endmacro

macro generate_smoke_on_fire()
	JSR	DrawSmoke2
endmacro

macro generate_sound(sfx,port)
	LDA.b	#<sfx>
	STA.w	<port>|!base2
endmacro

macro give_coins(num)
	LDA.b	#<num>
	JSL	$05B329|!base3
endmacro

macro change_map16()
	JSR ChangeMap16
endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode

block_fire:
	PHK
	PEA.w	.code_02B560-1		;Recover JSR $B560
	PEA.w	$B889-1
	JML	$02B560|!base3
.code_02B560
	PHK
	PEA.w	.code_02A0AC-1		;Recover JSR $A0AC
	PEA.w	$B889-1
	JML	$02A0AC|!base3
.code_02A0AC
	LDA	$1715|!base2,x
	CLC
	ADC	#$08			;Get fireball's Y low position + $08
	STA	$98
	LDA	$1729|!base2,x
	ADC	#$00			;Get fireball's Y high position
	STA	$99			;Save it also on $99
	LDA	$171F|!base2,x
	CLC
	ADC	#$08			;Get fireball's X low position + $08
	STA	$9A
	LDA	$1733|!base2,x
	ADC	#$00			;Get fireball's X high position
	STA	$9B			;Save it also on $9B
	PHX
	JSR	GetMap16		;Get Map16 number on given coordinates
	XBA
	TYA
	XBA
	REP	#$30
if !use_map16_only == 0
	PHY
-	AND	#$3FFF
	ASL
	TAY
	LDA	$06F624|!base3
	STA	$0A
	LDA	$06F626|!base3
	STA	$0C
	LDA	[$0A],y
	CMP.w	#$0200
	BCS	-
	PLY
endif
	LDX.w	#interact_table_end-interact_table-$03
.loop
	CMP.l	interact_table,x	;check table to search valid map16 numbers
	BEQ	.found
	DEX	#3
	BPL	.loop
	SEP	#$30
	PLX
.return
	JML	$029F6E|!base3		;return to Yoshi's code
.found
	LDA.l	interact_table+$02,x	;Get index to the behaviors table
	AND.w 	#$00FF
	ASL	A
	TAX
	LDA.l	Effects,x
	DEC
	SEP	#$10
	PLX
	PHA
	SEP	#$20
	RTS

Effects:
incsrc yoshi_fireballEffects.asm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Shared routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawSmoke:
	LDY	#$03
-
	LDA	$17C0|!base2,y
	BEQ	+
	DEY
	BPL	-
	RTS
+
	LDA	#$01
	STA	$17C0|!base2,y
	LDA	#$1C
	STA	$17CC|!base2,y
	LDA	$98
	STA	$17C4|!base2,y
	LDA	$9A
	STA	$17C8|!base2,y
	RTS

DrawSmoke2:
	LDY	#$03
-
	LDA	$17C0|!base2,y
	BEQ	+
	DEY
	BPL	-
	RTS
+
	LDA	#$01
	STA	$17C0|!base2,y
	LDA	#$1C
	STA	$17CC|!base2,y
	LDA	$1715|!base2,x
	STA	$17C4|!base2,y
	LDA	$171F|!base2,x
	STA	$17C8|!base2,y
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Important routine, do not touch.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GetBlock - SA-1 Hybrid version
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; this routine will get Map16 value
; If position is invalid range, will return 0xFFFF.
;
; input:
; $98-$99 block position Y
; $9A-$9B block position X
; $1933   layer
;
; output:
; A Map16 lowbyte (or all 16bits in 16bit mode)
; Y Map16 highbyte
;
; by Akaginite
;
; It used to return FF but it also fucked with N and Z lol, that's fixed now
; Slightly modified by Tattletale
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetMap16:
	PHX
	PHP
	REP #$10
	PHB
	LDY $98
	STY $0E
	LDY $9A
	STY $0C
	SEP #$30
	LDA $5B
	LDX $1933|!base2
	BEQ Layer1
	LSR A
Layer1:	
	STA $0A
	LSR A
	BCC Horz
	LDA $9B
	LDY $99
	STY $9B
	STA $99
Horz:
if !EXLEVEL
	REP #$20
	LDA $98
	CMP $13D7|!base2
	SEP #$20
else
	LDA #$99
	CMP #$02
endif
	BCC NoEnd
	PLB
	PLP
	PLX
	LDA #$FF
	RTS
	
NoEnd:
	LDA $9B
	STA $0B
	ASL A
	ADC $0B
	TAY
	REP #$20
	LDA $98
	AND.w #$FFF0
	STA $08
	AND.w #$00F0
	ASL #2			; 0000 00YY YY00 0000
	XBA			; YY00 0000 0000 00YY
	STA $06
	TXA
	SEP #$20
	ASL A
	TAX
	
	LDA $0D
	LSR A
	LDA $0F
	AND #$01		; 0000 000y
	ROL A			; 0000 00yx
	ASL #2			; 0000 yx00
	ORA #$20		; 0010 yx00
	CPX #$00
	BEQ NoAdd
	ORA #$10		; 001l yx00
NoAdd:	
	TSB $06			; $06 : 001l yxYY
	LDA $9A			; X LowByte
	AND #$F0		; XXXX 0000
	LSR #3			; 000X XXX0
	TSB $07			; $07 : YY0X XXX0
	LSR A
	TSB $08

	LDA $1925|!base2
	ASL A
	REP #$31
	ADC $00BEA8|!base3,x
	TAX
	TYA
if !SA1
    ADC.l $00,x
    TAX
    LDA $08
    ADC.l $00,x
else
    ADC $00,x
    TAX
    LDA $08
    ADC $00,x
endif
	TAX
	SEP #$20
if !SA1
	LDA $410000,x
	XBA
	LDA $400000,x
else
	LDA $7F0000,x
	XBA
	LDA $7E0000,x
endif
	SEP #$30
	XBA
	TAY
	XBA

	PLB
	PLP
	PLX
	RTS

ChangeMap16:
LDA $0F : PHA
PHP
PHY
PHX
LDY $98
STY $0E
LDY $9A
STY $0C
SEP #$30
LDA $5B
LDX $1933|!base2
BEQ .Layer1
LSR A
.Layer1
STA $0A
LSR A
BCC .Horz
LDA $9B
LDY $99
STY $9B
STA $99
.Horz
if !EXLEVEL
BCS .vertical
REP #$20
LDA $98
CMP $13D7|!base2
SEP #$20
BRA .check
.vertical
endif
LDA $99
CMP #$02
.check
BCS .End
LDA $9B
CMP $5D
BCC .NoEnd
.End
REP #$10
PLX
PLY
PLP
JMP .returnasdf

.NoEnd
STA $0B
ASL A
ADC $0B
TAY
REP #$20
LDA $98
AND.w #$FFF0
STA $08
AND.w #$00F0
ASL #2 ; 0000 00YY YY00 0000
XBA ; YY00 0000 0000 00YY
STA $06
TXA
SEP #$20
ASL A
TAX

LDA $0D
LSR A
LDA $0F
AND #$01 ; 0000 000y
ROL A ; 0000 00yx
ASL #2 ; 0000 yx00
ORA.l .LayerData,x ; 001l yx00
TSB $06 ; $06 : 001l yxYY
LDA $9A ; X LowByte
AND #$F0 ; XXXX 0000
LSR #3 ; 000X XXX0
TSB $07 ; $07 : YY0X XXX0
LSR A
TSB $08

LDA $1925|!base2
ASL A
REP #$31
ADC $00BEA8,x
TAX
TYA
if !SA1
ADC $000000,x
TAX
LDA $08
ADC $000000,x
else
ADC $00,x
TAX
LDA $08
ADC $00,x
endif
TAX
PLA
ASL A
TAY
LSR A
SEP #$20
if !SA1
STA $400000,x
XBA
STA $410000,x
else
STA $7E0000,x
XBA
STA $7F0000,x
endif
LSR $0A
LDA $1933|!base2
REP #$20
BCS .Vert
BNE .HorzL2
.HorzL1
LDA $1A ;\
SBC #$007F ; |$08 : Layer1X - 0x80
STA $08 ;/
LDA $1C ; $0A : Layer1Y
BRA .Common
.HorzL2
LDA $1E ;\ $08 : Layer2X
STA $08 ;/
LDA $20 ;\ $0A : Layer2Y - 0x80
SBC #$007F ;/
BRA .Common

.Vert
BNE .VertL2
LDA $1A ;\ $08 : Layer1X
STA $08 ;/
LDA $1C ;\ $0A : Layer1Y - 0x80
SBC #$0080 ;/
BRA .Common
.VertL2
LDA $1E ;\
SBC #$0080 ; |$08 : Layer2X - 0x80
STA $08 ;/
LDA $20 ; $0A : Layer2Y
.Common
STA $0A
PHB
PHK
; PER $0006
PEA .return-1
PEA $804C
JML $00C0FB
.return
PLB
PLY
PLP
.returnasdf
PLA : STA $0F
RTS

.LayerData db $20,$00,$30

print "This patch uses: ",freespaceuse," bytes."