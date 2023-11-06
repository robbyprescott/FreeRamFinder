;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flying Cloud 
;; by Abdu
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Extra Bit:
;; clear horizontal, set vertical
;; 
;; Extra Byte 1: (Only used when Extra Byte 1 is 1)
;; For Horizontal Movement:
;; 00 Fly towards the player when spawned.
;; 01 Fly towards the left.
;; 02 Fly towards the left then right.
;; 03 Fly towards the right.
;; 04 Fly towards the right then left.
;; 05 Fly back and forth first it flies towards the player then goes back to the opposite direction.
;; weird stuff will happen if you have any other values

;; For Vertical Movement:
;; 00 Will Fly up if the player is on the left of the sprite when the sprite is spawned, and will fly down the player is on the right when the sprite is spawned. 
;; 01 Fly up.
;; 02 Fly up then down.
;; 03 Fly down.
;; 04 Fly down then up.
;; 05 if the player is on the left of the sprite when the sprite is spawned, the sprite will go up then down if the player is on the right when spawned it will go down then up.
;; weird stuff will happen if you have any other values

;; Extra Byte 2
;; if clear wave movement, set no wave movement.

;; The following will be added in a future update. 
;; Extra Byte 3 format:
;; ---- --VH
;; H: if set will wrap the cloud horizontally. 01
;; V: if set will wrap the cloud vertically. 02

;=======Misc sprite tables defines=======
!MovementType           = !extra_bits   ;
!FlyType                = !1510         ; check Extra Byte 1 settings.
!Wave                   = !1534
!Timer                  = !1540
!WingAnimation          = !1570
!SpriteDir				= !157C
; !Wrapping               = !extra_byte_3
;========================================

;=======Changeable values defines========
;; When the sprite has wings
!Tile					= $29 ; GFX Tile.
!XAccelerationWings     = $01
!MaxXSpeedWings         = $10

;; Y speed for horizontal movement (when Extra Byte 2 = 00).
!HorzYAcceleration      = $01   ; Y Acceleration while the sprite is moving horizontally 
!HorzMaxYSpeed          = $0C   ; Max Y speed while the sprite is moving horizontally 

!XSpeedFreq             = $03   ;\ Frequency for updating X speed and Y speed, must be (powers of 2)-1, $00, $01, $03, etc.
!HorzYSpeedFreq         = $01   ;/

; X speed for vertical movement (when extra bit is set).
!VertXAccelerationWings = $01
!VertMaxXSpeedWings     = $0C

!YAcceleration          = $01   ; Y Acceleration while the sprite is moving horizontally 
!MaxYSpeed              = $10   ; Max Y speed while the sprite is moving horizontally

!VertXSpeedFreq         = $01   ;\ Frequency for updating X speed and Y speed, must be (powers of 2)-1, $00, $01, $03, etc.
!YSpeedFreq             = $03   ;/
!StayAtMaxSpeed         = $20
!ExtraBit 				= $04
;========================================
; bruh how tf are the "tabs" spaces. heckin love vscode.

print "INIT ",pc
	LDA !extra_byte_1,x     ;\ Store the fly type
	STA !FlyType,x          ;/
	BEQ +                   ;\ if its 0 then that means it will face the player when spawned
	CMP #$05                ;| same applies with 5
	BEQ  +                  ;/
	LDY #$01                ; Set Y = 1 which means face left
	CMP #$03                ; since we already check for 0 that means anything less than 3 means that we should face left
	BCC ++                  
	DEY                     ; Decrement so now Y = 0 which means face right
	BRA ++					; 
	+
	%SubHorzPos()
	++
	TYA
	STA !SpriteDir,x
RTL

print "MAIN ",pc
	PHB : PHK : PLB
	JSR FlyingCloud
	PLB
RTL

FlyingCloud:
	JSR Graphics
	LDA !14C8,x			        ;\ check if dead or game has stopped
	CMP #$08			        ;|
	BNE .Ret
	LDA $9D				        ;|
	BNE .Ret			        ;/ Return if thats the case
	JSR Movement
	JSL $01B44F|!BankB			; make it solid
	INC !WingAnimation,x
	LDA #$00
    %SubOffScreen()
	.Ret
RTS


Movement:
	LDA !MovementType,x
	AND #!ExtraBit
	LSR
	TAX
	JMP (.Ptrs,x)
	.Ptrs

	dw Horizontal
	dw Vertical
	.end
RTS

MaxXSpeedWings:		db !MaxXSpeedWings, -!MaxXSpeedWings
XAcceWings:			db !XAccelerationWings, -!XAccelerationWings

HorzMaxYSpeed:		db -!HorzMaxYSpeed, !HorzMaxYSpeed 
HorzYAcce:			db -!HorzYAcceleration, !HorzYAcceleration 

Horizontal:
	LDX $15E9|!Base2
	LDA !extra_byte_2,x
	BNE +

	LDA $14
	AND #!HorzYSpeedFreq
	BNE +
	LDA !Wave,x
	AND #$01
	TAY
	LDA !AA,x
	CLC : ADC HorzYAcce,y
	CMP HorzMaxYSpeed,y
	STA !AA,x
	BNE +
	INC !Wave,x
	+
	JSL $01801A|!BankB

	LDY !SpriteDir,x
	LDA !FlyType,x          ;\
	BEQ .noTurn             ;|
	CMP #$01                ;| I could have done a setup to do this better but its 4AM and I aint feeling it rn 
	BEQ .noTurn             ;|
	CMP #$03                ;|
	BEQ .noTurn             ;/

	LDA $14					;\ Update speed depending on frequency
	AND #!XSpeedFreq		;|
	BNE .skip				;/
	LDA !Timer,x			;\ Timer set so skip
	BNE .skip				;/
	
	LDA !B6,x
	CLC : ADC XAcceWings,y
	STA !B6,x
	CMP MaxXSpeedWings,y
	BNE .skip
	
	.switchDir
	TYA : EOR #$01 : STA !SpriteDir,x	; Flip facing direction.
	LDA #!StayAtMaxSpeed 			;\ Set timer for how long to stay at max speed.
	STA !Timer,x					;/
	BRA .skip

	.noTurn
	LDA MaxXSpeedWings,y	;\ Use constant speed if the sprite isn't gonna turn around.
	STA !B6,x				;/
	
	.skip
	JSL $018022|!BankB
	LDA $1491|!Base2
	STA !1528,x                     ; prevent the player from sliding
 	
RTS

VertMaxXSpeedWings: db !VertMaxXSpeedWings, -!VertMaxXSpeedWings
VertXAcceWings:     db !VertXAccelerationWings, -!VertXAccelerationWings

MaxYSpeed:          db -!MaxYSpeed, !MaxYSpeed 
YAcce:              db -!YAcceleration, !YAcceleration 

Vertical:
	LDX $15E9|!Base2

	LDY !SpriteDir,x
	LDA !FlyType,x          ;\
	BEQ .noTurn             ;|
	CMP #$01                ;| I could have done a setup to do this better but its 4AM and I aint feeling it rn 
	BEQ .noTurn             ;|
	CMP #$03                ;|
	BEQ .noTurn             ;/

	LDA $14
	AND #!YSpeedFreq
	BNE .skip
	LDA !Timer,x
	BNE .skip
	
	LDA !AA,x
	CLC : ADC XAcceWings,y
	STA !AA,x
	CMP MaxXSpeedWings,y
	BNE .skip
	.switchDir
	TYA : EOR #$01 : STA !SpriteDir,x
	LDA #!StayAtMaxSpeed 
	STA !Timer,x
	BRA .skip

	.noTurn
	LDA MaxXSpeedWings,y
	STA !AA,x
	.skip
	JSL $01801A|!BankB
	STZ $1491|!Base2
	LDA $1491|!Base2
	STA !1528,x

	LDA !extra_byte_2,x
	BNE ++

	LDA $14
	AND #!VertXSpeedFreq
	BNE +
	LDA !Wave,x
	AND #$01
	TAY
	LDA !B6,x
	CLC : ADC VertXAcceWings,y
	CMP VertMaxXSpeedWings,y
	STA !B6,x
	BNE +
	INC !Wave,x
	+
	JSL $018022|!BankB
	LDA $1491|!Base2
	STA !1528,x
++
RTS

Graphics:
	PEA ($01)|(done>>16<<8)	;\
	PLB						;|
	PHK						;| Draw Wings.
	PEA done-1				;|
	PEA $80CA-1				;|
	JML $019E95|!BankB		;/
	done:
	PLB
	%GetDrawInfo()
	LDA $00                     ;\ Store Tile X position
	STA $0300|!Base2,y          ;/

	LDA $01                     ;\ Store Tile Y position
	STA $0301|!Base2,y          ;/

	LDA #!Tile    				;\ Store Tile number
	STA $0302|!Base2,y          ;/
	
	LDA !15F6,x                 ;\ Store Tile properties
	ORA $64                     ;|
	STA $0303|!Base2,y          ;/
	
	LDA #$00 				    ; A = (number of tiles drawn - 1)
	LDY #$02 				    ; 16x16 tiles
	JSL $01B7B3|!BankB
RTS