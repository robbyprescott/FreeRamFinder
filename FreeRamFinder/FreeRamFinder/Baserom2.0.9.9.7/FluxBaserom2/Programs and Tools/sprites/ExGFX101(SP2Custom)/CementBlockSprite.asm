; SJC: Minor edits, e.g. to fix vertical level issues. (Thanks to Kevin.)
; For use with ExGFX101

; ---------------------------------------------------------------------- ;
; Carryable cement block sprite - To be spawned from the included block. ;
; ---------------------------------------------------------------------- ;

!Tile = $E8 ; default C2

print "MAIN ",pc

PHB
PHK
PLB
JSR BlockMain
JSR Graphics
PLB
RTL

; --------------------

Return2:
RTS

BlockMain:
LDA #$00
%SubOffScreen()
LDA $71
CMP #$05
BEQ +
CMP #$06
BNE ++
+
CLC
PHP
JMP NoChange
++
LDA $9D
ORA $13D4|!addr
BNE Return2
LDA !1504,x
BEQ +
DEC !1504,x
+
LDA !14C8,x
CMP #$0B
BEQ Carried
LDA !154C,x
BNE NoContact
JSL $01A7DC|!bank
BCC NoContact

LDA $1470|!addr
ORA $148F|!addr
ORA $187A|!addr
BNE NoContact

LDA $15
ORA $17
AND #$40
BEQ NoContact

Carried:
LDA #$0B
STA !14C8,x
LDA #$01
STA $1470|!addr
STA $148F|!addr
LDA #$10
STA !154C,x

NoContact:
JSL $018032|!bank
LDA !14C8,x
CMP #$02
BEQ ChangeBlock
CMP #$0B
BEQ CheckTimer
LDA #$09
STA !14C8,x

LDA !1588,x
AND #$03
SEC
BNE ChangeBlock

CheckTimer:
LDA !1504,x
CMP #$01
BNE Return2
CLC

ChangeBlock:
PHP
LDA !14E0,x
XBA
LDA !E4,x
REP #$20
BIT #$0008
BEQ +
CLC
ADC #$0010
+
STA $9A
SEP #$20
LDA !1528,x
BEQ +
REP #$20
LDA $9A
CLC
ADC $26
STA $9A
SEP #$20
+
LDA !14D4,x
XBA
LDA !D8,x
REP #$20
BIT #$0008
BEQ +
CLC
ADC #$0010
+
STA $98
SEP #$20
LDA !1528,x
BEQ +
REP #$20
LDA $98
CLC
ADC $28
STA $98
SEP #$20
LDA !1528,x
+
STA $1933|!addr

%GetMap16()
CPY #$00
BNE NoChange
CMP #$25
BNE NoChange

lda $5B : lsr : bcc + ; added by SJC
	lda $99 : xba
	lda $9B : sta $99
	xba : sta $9B
+
LDA !151C,x
XBA
LDA !1510,x
REP #$20
%ChangeMap16()
SEP #$20
STZ $1470|!addr
STZ $148F|!addr
LDA #$01
STA $1DF9|!addr
NoChange:
LDA #$04
STA !14C8,x
PLP
BCS Return
STZ $00
STZ $01
LDA #$1B
STA $02
LDA #$01
%SpawnSmoke()

Return:
RTS

; --------------------

Graphics:

%GetDrawInfo()
STZ $02
LDA !1504,x
BEQ +
CMP #$40
BCS +
LDA $9D
ORA $13D4|!addr
BNE +
LDA #$02
%Random()
SEC
SBC #$01
STA $02
+
LDA $00
CLC
ADC $02
STA $0300|!addr,y
LDA $01
STA $0301|!addr,y
LDA #!Tile
STA $0302|!addr,y
LDA #$02
ORA $64
STA $0303|!addr,y
LDA #$00
LDY #$02
JSL $01B7B3|!bank
RTS