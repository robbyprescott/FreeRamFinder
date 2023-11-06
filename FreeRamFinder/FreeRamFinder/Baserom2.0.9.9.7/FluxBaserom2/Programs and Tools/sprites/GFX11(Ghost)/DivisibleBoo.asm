; Divisible Boo by anonimzwx

; If the extra bit is set, the boo will not divide and will disappear if jumped on.

;===================================

;Point to the current frame
!FramePointer = !C2,x

;Point to the current frame on the animation
!AnFramePointer = !1504,x

;Point to the current animation
!AnPointer = !1510,x

;Time for the next frame change
!AnimationTimer = !1540,x

!GlobalFlipper = !1534,x

!LocalFlipper = !1570,x

!moveTimer = !1528,x

!starting = !1594,x

!startingTimer = !154C,x

!cooldownTimer = !1564,x

!maxStartingTime = #$60

!maxMoveTime = #$6A

; Cooldown to not interact with Mario after splitting to avoid some "janky" deaths
!marioInteractCooldown = #$08

;Tiles
!Frame1 = $AE ;You can change the tiles of boo here
!Frame2 = $AA

;===================================

PRINT "INIT ",pc

PHB
PHK
PLB
JSR SpriteInit
PLB
RTL

;===================================

SpriteInit:
LDA !marioInteractCooldown
STA !cooldownTimer

LDA !maxStartingTime
STA !startingTimer

LDA !maxMoveTime
STA !moveTimer 

LDA !7FAB10,x
AND #$04
BNE +
	STZ !AA,x
	STZ !B6,x
	STZ !starting
	STZ !startingTimer
	STZ !cooldownTimer
+

LDA #$01
STA !FramePointer
LDA #$02
STA !AnPointer
STZ !AnFramePointer
LDA #$04
STA !AnimationTimer

RTS

;===================================

PRINT "MAIN ",pc

PHB
PHK
PLB
JSR SpriteCode
PLB
RTL

;===================================
;Sprite Function
;===================================

SpriteCode:

	JSR Graphics ;graphic routine

	LDA !14C8,x			;\
	CMP #$08			; | If sprite dead,
	BNE Return			;/ Return.

	LDA $9D				;\
	BNE Return			;/ If locked, return.
	%SubOffScreen()
	
	JSR InteractionWithMario
	JSR states
	JSR GraphicManager ;manage the frames of the sprite and decide what frame show
	JSL $018022|!BankB
	JSL $01801A|!BankB
Return:
	RTS

	
states:

	LDA !starting
	BEQ +
	
	LDA !startingTimer
	BNE ++
	STZ !starting
++

	DEC !AA,x
	BPL ++
	STZ !AA,x
++
	LDA !B6,x
	BMI ++
	DEC !B6,x
	BPL +++
	STZ !B6,x
	RTS
++
	INC !B6,x
	BMI +++
	STZ !B6,x
+++
	RTS
+

	LDA !AnPointer
	BNE +
	JSR follow
	RTS
+
	CMP #$02
	BNE +
	JSR idle
	RTS
+
	RTS
	
idle:
	STZ !AA,x
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	
	LDA !GlobalFlipper
	BNE +
	
	REP #$20
	LDA $94
	CLC
	ADC #$0018
	CMP $00
	SEP #$20
	BCC .c0
	
	LDA #$01
	STA !GlobalFlipper
	RTS
	
.c0
	LDA $76
	CMP !GlobalFlipper
	BNE ++
	
	STZ !AnPointer
	STZ !FramePointer
	STZ !AnFramePointer
++
	RTS
+
	REP #$20
	LDA $94
	CLC
	ADC #$FFF8
	CMP $00
	SEP #$20
	BCS .c1
	
	LDA #$00
	STA !GlobalFlipper
	RTS
	
.c1
	LDA $76
	CMP !GlobalFlipper
	BNE +
	
	STZ !AnPointer
	STZ !FramePointer
	STZ !AnFramePointer
+
	RTS

follow:

	LDA !GlobalFlipper
	CMP $76
	BEQ +
	
	LDA #$02
	STA !AnPointer
	LDA #$01
	STA !FramePointer
	STZ !AnFramePointer
	STZ !B6,x
	STZ !AA,x
	
	RTS
+
	
	JSR sinMove
	JSR xmov
	JSR ymov
	RTS
	
ymov:
	
	REP #$20
	LDA $96
	CLC
	ADC #$0010
	CMP $02
	SEP #$20
	BCS +
	
	REP #$20
	LDA $96
	CLC
	ADC #$0030
	CMP $02
	SEP #$20
	BCC ++
	
	INC !AA,x
	BMI ++
	STZ !AA,x
	RTS
++
	LDA !AA,x
	DEC A
	STA !AA,x
	BPL ++
	CMP #$F8
	BCS ++
	LDA #$F8
	STA !AA,x
++
	RTS
+
	REP #$20
	LDA $96
	CLC
	ADC #$FFF0
	CMP $02
	SEP #$20
	BCS ++
	
	DEC !AA,x
	BPL ++
	STZ !AA,x
	RTS
++

	LDA !AA,x
	INC A
	STA !AA,x
	BMI ++
	CMP #$08
	BCC ++
	LDA #$08
	STA !AA,x
++
	
	RTS
	
	
xmov:
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	
	LDA !GlobalFlipper
	BEQ +
	
	REP #$20
	LDA $94
	CLC
	ADC #$0018
	CMP $00
	SEP #$20
	BCS .c0
	
	DEC !B6,x
	BPL ++
	STZ !B6,x
	LDA #$02
	STA !AnPointer
	LDA #$01
	STA !FramePointer
	STZ !AnFramePointer
++
	RTS
	
.c0
	LDA !B6,x
	INC A
	STA !B6,x
	BMI ++
	CMP #$08
	BCC ++
	LDA #$08
	STA !B6,x
++
	RTS
+
	REP #$20
	LDA $94
	CLC
	ADC #$FFF8
	CMP $00
	SEP #$20
	BCC .c1
	
	INC !B6,x
	BMI ++
	STZ !B6,x
	LDA #$02
	STA !AnPointer
	LDA #$01
	STA !FramePointer
	STZ !AnFramePointer
++
	RTS
	
.c1
	LDA !B6,x
	DEC A
	STA !B6,x
	BPL ++
	CMP #$F8
	BCS ++
	LDA #$F8
	STA !B6,x
++
	RTS
	
sinMove:

	LDA !D8,x
	STA $02
	LDA !14D4,x
	STA $03
	
	LDA $14
	AND #$03
	BNE .next
	
	LDA !moveTimer
	BNE +
	LDA !maxMoveTime
	STA !moveTimer
	BRA ++	
+
	DEC A
	DEC A
	STA !moveTimer
++
	TAY
	
	REP #$20
	LDA $02
	CLC
	ADC .sin,y
	STA $02
	SEP #$20
	
	LDA $02
	STA !D8,x
	LDA $03
	STA !14D4,x
.next

	RTS
.sin 	dw $0000,$0000,$0000,$0000,$0001,$0000,$0000,$0001,$0000,$0001,$0000,$0001,$0001,$0001,$0001,$0001
		dw $0001,$0000,$0001,$0000,$0001,$0000,$0000,$0001,$0000,$0000,$0000,$0000,$0000,$0000,$FFFF,$0000
		dw $0000,$FFFF,$0000,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$0000,$FFFF,$0000,$FFFF,$0000
		dw $0000,$FFFF,$0000,$0000,$0000,$0000
		
summonBoo:

	JSL $02A9DE|!BankB
	BMI .EndSpawn

	LDA #$01
	STA !14C8,y
	
	LDA !7FAB9E,x
	PHX
	TYX
	STA !7FAB9E,x
	PLX
	
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
	LDA #$0C
	STA !7FAB10,x
	
	LDA $00
	STA !B6,x
	
	LDA #$10
	STA !AA,x
	
	LDA #$01
	STA !starting
	
	PLX
.EndSpawn
	RTS

;===================================
;Graphic Manager
;===================================	
GraphicManager:

	;if !AnimationTimer is Zero go to the next frame
	LDA !AnimationTimer
	BEQ ChangeFrame
	RTS

ChangeFrame:

	LDA !FramePointer
	CMP #$05
	BNE +

	STZ !14C8,x	
	RTS
	
+

	;Load the animation pointer X2
	LDA !AnPointer
	
	REP #$30
	AND #$00FF
	TAY
	
	
	LDA !AnFramePointer
	CLC
	ADC EndPositionAnim,y
	TAY
	SEP #$30
	
	LDA AnimationsFrames,y
	STA !FramePointer
	
	LDA AnimationsNFr,y
	STA !AnFramePointer
	
	LDA AnimationsTFr,y
	STA !AnimationTimer
	
	LDA !GlobalFlipper
	EOR AnimationsFlips,y
	STA !LocalFlipper
	
	RTS	


;===================================
;Animation
;===================================
EndPositionAnim:
	dw $0000,$0001,$0002

AnimationsFrames:
normalFrames:
	db $00
hideFrames:
	db $01
dieFrames:
	db $02,$03,$04,$05

AnimationsNFr:
normalNext:
	db $00
hideNext:
	db $00
dieNext:
	db $01,$02,$03,$00

AnimationsTFr:
normalTimes:
	db $04
hideTimes:
	db $04
dieTimes:
	db $04,$04,$04,$04

AnimationsFlips:
normalFlip:
	db $00
hideFlip:
	db $00
dieFlip:
	db $00,$00,$00,$00


;===================================
;Interaction
;===================================
InteractionWithMario:
	LDA !cooldownTimer
	BNE ++

	LDA !FramePointer
	TAY
	LDA TotalHitboxes,y
	BPL +
++	RTS
+
	LDA !LocalFlipper
	TAY
	LDA !FramePointer
	CLC
	ADC FlipAdder,y
	REP #$30
	AND #$00FF
	CLC
	ASL
	TAY ;load the frame pointer on X
	
	LDA StartPositionHitboxes,y
	STA $08
	
	LDA EndPositionHitboxes,y
	STA $0A
	
	LDA #$000C ;load y disp of mario on $04
	STA $04
	
	LDA $19
	AND #$00FF
	BEQ +
	LDA #$0004 ;if mario is big the y disp is 4
	STA $04
+
	LDA $96
	CLC
	ADC $04
	STA $04 ;$04 is position + ydisp
	BPL +
	LDA #$0000 ;if $04 is negative then change it to 0
+
	STA $04 
	
	LDA $04
	CLC
	ADC #$0014
	STA $06 ;$06 = bottom
	LDA $19
	AND #$00FF
	BEQ +
	LDA $06
	CLC
	ADC #$0008
	STA $06 ;if mario is big then add 8 to bottom 
+	
	LDA $187A|!addr
	AND #$00FF
	BEQ +
	LDA $06
	CLC
	ADC #$0010 ;if mario is riding yoshi then add 16 to bottom
	STA $06
+
	LDA $06
	BPL +
	SEP #$20
	RTS
+

	SEP #$20
	
	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	
	LDA !D8,x
	STA $02
	LDA !14D4,x
	STA $03
	
	REP #$30
	
	LDY $08
	
.loop

	LDA $00
	CLC
	ADC FramesHitboxXDisp,y
	STA $0E
	CLC
	ADC FramesHitboxWidth,y
	BMI .next ;if x + xdisp + width < xMario || x + xdisp + width < 0 then goto next
	CMP $94
	BCC .next
	
	LDA $0E
	BPL +
	STZ $000E|!dp
+
	
	LDA $94
	CLC
	ADC #$0010
	CMP $0E
	BCC .next ;if xMario + widthMario < x+xdisp then goto next
	
	LDA $02
	CLC
	ADC FramesHitboxYDisp,y
	STA $0E
	CLC
	ADC FramesHitboxHeigth,y
	BMI .next
	CMP $04
	BCC .next ;if y + ydisp + height < yMario + ydispMario || y + ydisp + height < 0 then goto next

	LDA $0E
	BPL +
	STZ $000E|!dp
+	
	LDA $06
	CMP $0E
	BCC .next ;if yMario + ydispMario + heigthMario < y + ydisp then gotonext
	
	PHY
	LDA FramesHitboxAction,y
	STA $0E
	SEP #$30
	TXY
	LDX #$00
	JSR ($000E|!dp,x)
	REP #$30
	PLY
	BRA .ret
.next
	DEY
	DEY
	BMI .ret
	CPY $0A
	BCS .loop
.ret	
	SEP #$30
RTS

hurt:
	TYX
	LDA $187A|!addr
	BNE .loseYoshi
	JSL $00F5B7|!BankB
	RTS
.loseYoshi
	JSR LOSEYOSHI
	RTS
	
vel: db $18,$E8
LOSEYOSHI:	
	LDA $187A|!addr
	BEQ NOYOSHI
	PHX
	LDX $18E2|!addr
	DEX
	LDA #$10
	STA !163E,x
	LDA #$03
	STA $1DFA|!addr
	LDA #$13
	STA $1DFC|!addr
	LDA #$02
	STA !C2,x
	STZ $187A|!addr
	STZ $0DC1|!addr
	LDA #$C0
	STA $7D
	STZ $7B
	LDY !157C,x
	PHX
	TYX
	LDA vel,x
	PLX
	STA !B6,x
	STZ !1594,x
	STZ !151C,x
	STZ $18AE|!addr
	LDA #$30
	STA $1497|!addr
	PLX
NOYOSHI:
	RTS
;===================================
;Actions
;===================================
high:
	TYX
	LDA $7D
	BMI +
	
	JSL $01AA33|!BankB
	JSL $01AB99|!BankB
	JSR points
	LDA #$04
	STA !AnPointer
	STA !AnimationTimer
	LDA #$02
	STA !FramePointer
	STZ !AnFramePointer
	STZ !B6,x
	STZ !AA,x
	
	LDA !7FAB10,x
	AND #$04
	BNE ++
	
	LDA #$20
	STA $00
	JSR summonBoo
	LDA #$E0
	STA $00
	JSR summonBoo
	
++
	RTS
+
	JSR hurt
	RTS
points:
	PHY		;
	LDA $1697|!addr	; consecutive enemies stomped
	CLC		;
	ADC !1626,x	; plus number of enemies this sprite has killed (...huh?)
	INC $1697|!addr	; increment the counter
	TAY		; -> Y
	INY		; increment
	CPY #$08		; if the result is 8+...
	BCS NoSound	; don't play a sound effect
	TYX		;
	LDA $037FFF,x	; star sounds (X is never 0 here; they start at $038000)
	STA $1DF9|!addr	;
	LDX $15E9|!addr	;
	NoSound:		;
	TYA		;
	CMP #$08		; if the number is 8+...
	BCC GivePoints	;
	LDA #$08		; just use 8 when giving points
	GivePoints:	;
	JSL $02ACE5|!BankB	;
	PLY		;
	RTS		;

;===================================
;Graphic Routine
;===================================
FlipAdder: db $00,$06
Graphics:
	REP #$10
	LDY #$0000
	SEP #$10

	%GetDrawInfo()
rpghacker_fix_macro_labels_already:
	PHX
	LDA !LocalFlipper
	PHA
	LDA !FramePointer
	PLX
	CLC
	ADC FlipAdder,x
	REP #$30

	AND #$00FF
	ASL
	TAX
	
	LDA EndPositionFrames,x
	STA $0D
	
	LDA StartPositionFrames,x
	TAX
	SEP #$20

.loop
	LDA FramesXDisp,x 
	CLC
	ADC $00
	STA $0300|!addr,y ;load the tile X position

	LDA FramesYDisp,x
	CLC
	ADC $01
	STA $0301|!addr,y ;load the tile Y position

	LDA FramesPropertie,x
	ORA $64
	STA $0303|!addr,y ;load the tile Propertie

	LDA FramesTile,x
	STA $0302|!addr,y ;load the tile

	INY
	INY
	INY
	INY ;next slot

	DEX
	BMI +
	CPX $0D
	BCS .loop ;if Y < 0 exit to loop
+
	SEP #$10
	PLX
	
	LDA !FramePointer
	TAY
	LDA FramesTotalTiles,y ;load the total of tiles on $0E
	LDY #$02 ;load the size
	JSL $01B7B3|!BankB ;call the oam routine
	RTS
	
;===================================
;Frames
;===================================
FramesTotalTiles:

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

StartPositionFrames:
	dw $0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008,$0009,$000A,$000B

EndPositionFrames:
	dw $0000,$0001,$0002,$0003,$0004,$0005,$0006,$0007,$0008,$0009,$000A,$000B

TotalHitboxes:
	db $01,$01,$FF,$FF,$FF,$FF,$01,$01,$FF,$FF,$FF,$FF

StartPositionHitboxes:
	dw $0002,$0006,$0008,$000A,$000C,$000E,$0012,$0016,$0018,$001A,$001C,$001E

EndPositionHitboxes:
	dw $0000,$0004,$0008,$000A,$000C,$000E,$0010,$0014,$0018,$001A,$001C,$001E

FramesXDisp:
f1XDisp:
	db $00
f2XDisp:
	db $00
die1XDisp:
	db $00
die2XDisp:
	db $00
die3XDisp:
	db $00
die4XDisp:
	db $00
f1FlipXXDisp:
	db $00
f2FlipXXDisp:
	db $00
die1FlipXXDisp:
	db $00
die2FlipXXDisp:
	db $00
die3FlipXXDisp:
	db $00
die4FlipXXDisp:
	db $00


FramesYDisp:
f1yDisp:
	db $00
f2yDisp:
	db $00
die1yDisp:
	db $00
die2yDisp:
	db $00
die3yDisp:
	db $00
die4yDisp:
	db $00
f1FlipXyDisp:
	db $00
f2FlipXyDisp:
	db $00
die1FlipXyDisp:
	db $00
die2FlipXyDisp:
	db $00
die3FlipXyDisp:
	db $00
die4FlipXyDisp:
	db $00


FramesPropertie:
f1Properties:
	db $33
f2Properties:
	db $33
die1Properties:
	db $32
die2Properties:
	db $32
die3Properties:
	db $32
die4Properties:
	db $32
f1FlipXProperties:
	db $73
f2FlipXProperties:
	db $73
die1FlipXProperties:
	db $72
die2FlipXProperties:
	db $72
die3FlipXProperties:
	db $72
die4FlipXProperties:
	db $72


FramesTile:
f1Tiles:
	db !Frame1
f2Tiles:
	db !Frame2
die1Tiles:
	db $60
die2Tiles:
	db $62
die3Tiles:
	db $64
die4Tiles:
	db $66
f1FlipXTiles:
	db !Frame1
f2FlipXTiles:
	db !Frame2
die1FlipXTiles:
	db $60
die2FlipXTiles:
	db $62
die3FlipXTiles:
	db $64
die4FlipXTiles:
	db $66


FramesHitboxXDisp:
f1HitboxXDisp:
	dw $0002,$0002
f2HitboxXDisp:
	dw $0002,$0002
die1HitboxXDisp:
	dw $FFFF
die2HitboxXDisp:
	dw $FFFF
die3HitboxXDisp:
	dw $FFFF
die4HitboxXDisp:
	dw $FFFF
f1FlipXHitboxXDisp:
	dw $0002,$0002
f2FlipXHitboxXDisp:
	dw $0002,$0002
die1FlipXHitboxXDisp:
	dw $FFFF
die2FlipXHitboxXDisp:
	dw $FFFF
die3FlipXHitboxXDisp:
	dw $FFFF
die4FlipXHitboxXDisp:
	dw $FFFF


FramesHitboxYDisp:
f1HitboxyDisp:
	dw $0004,$0002
f2HitboxyDisp:
	dw $0004,$0002
die1HitboxyDisp:
	dw $FFFF
die2HitboxyDisp:
	dw $FFFF
die3HitboxyDisp:
	dw $FFFF
die4HitboxyDisp:
	dw $FFFF
f1FlipXHitboxyDisp:
	dw $0004,$0002
f2FlipXHitboxyDisp:
	dw $0004,$0002
die1FlipXHitboxyDisp:
	dw $FFFF
die2FlipXHitboxyDisp:
	dw $FFFF
die3FlipXHitboxyDisp:
	dw $FFFF
die4FlipXHitboxyDisp:
	dw $FFFF


FramesHitboxWidth:
f1HitboxWith:
	dw $000C,$000C
f2HitboxWith:
	dw $000C,$000C
die1HitboxWith:
	dw $FFFF
die2HitboxWith:
	dw $FFFF
die3HitboxWith:
	dw $FFFF
die4HitboxWith:
	dw $FFFF
f1FlipXHitboxWith:
	dw $000C,$000C
f2FlipXHitboxWith:
	dw $000C,$000C
die1FlipXHitboxWith:
	dw $FFFF
die2FlipXHitboxWith:
	dw $FFFF
die3FlipXHitboxWith:
	dw $FFFF
die4FlipXHitboxWith:
	dw $FFFF


FramesHitboxHeigth:
f1HitboxHeigth:
	dw $000A,$0002
f2HitboxHeigth:
	dw $000A,$0002
die1HitboxHeigth:
	dw $FFFF
die2HitboxHeigth:
	dw $FFFF
die3HitboxHeigth:
	dw $FFFF
die4HitboxHeigth:
	dw $FFFF
f1FlipXHitboxHeigth:
	dw $000A,$0002
f2FlipXHitboxHeigth:
	dw $000A,$0002
die1FlipXHitboxHeigth:
	dw $FFFF
die2FlipXHitboxHeigth:
	dw $FFFF
die3FlipXHitboxHeigth:
	dw $FFFF
die4FlipXHitboxHeigth:
	dw $FFFF


FramesHitboxAction:
f1HitboxAction:
	dw hurt,high
f2HitboxAction:
	dw hurt,high
die1HitboxAction:
	dw $FFFF
die2HitboxAction:
	dw $FFFF
die3HitboxAction:
	dw $FFFF
die4HitboxAction:
	dw $FFFF
f1FlipXHitboxAction:
	dw hurt,high
f2FlipXHitboxAction:
	dw hurt,high
die1FlipXHitboxAction:
	dw $FFFF
die2FlipXHitboxAction:
	dw $FFFF
die3FlipXHitboxAction:
	dw $FFFF
die4FlipXHitboxAction:
	dw $FFFF;