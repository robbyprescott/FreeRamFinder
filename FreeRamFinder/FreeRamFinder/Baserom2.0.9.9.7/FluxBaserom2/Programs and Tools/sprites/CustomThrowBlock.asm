;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Custom Throw Block - by dtothefourth
;
; A custom version of the throw block sprite
; with a lot of extra options.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!RightSpeed = #$2E ;Base speed when moving right
!LeftSpeed  = #$D2 ;Base speed when moving left

!Vanish		= 1    ;If 1, poofs into smoke after an amount of time
!VanishTime = #$FF ;How many frames before vanishing

!StartDir   = 0	   ;0 - stationary, 2 - kicked left, 3 - kicked right

!NoUpthrowBreak = 1 ;If 1, block will not break while in upthrow state, only when fully kicked
!ThrowMomentum  = 1 ;If 1, block will gain additional speed based on Mario's speed when thrown
!SpinJump		= 1 ;If 1, can spin jump off of like a regular one
!SpinBreak		= 0 ;If 1, breaks after spin jumping
!Bounce			= 0 ;If 1, can bounce off of it with a normal jump and stop it like a shell
!BounceBreak    = 0 ;If 1, breaks after bouncing


!BreakSpawn = 0     ; 1 to spawn a sprite when it breaks
!Sprite     = #$0F	; Sprite to spawn
!State      = #$01  ; Generally 1,8,9 (9 for carryable stuff like keys, 1 for stuff that needs to run its init routine)
!Custom     = 0		; 1 to spawn a custom sprite
!Extra      = 0		; 1 to set extra bit on sprite

!Tile = #$40	;Tile to display for graphics


!PalRate = #$07 ;How often to flash palette, vanilla is 0. Used as an AND with frame counter so use 0,1,3,7,F,1F,3F,7F
!NumPals = #$04 ;How many palettes to cycle through, add that many entries to the table below
Palettes:		;Which palettes to cycle through (Sprite palettes, use 0-7)
db $02,$03,$04,$05

;Vanilla palette settings for reference
;!PalRate = #$00 ;How often to flash palette, vanilla is 0. Used as an AND with frame counter so use 0,1,3,7,F,1F,3F,7F
;!NumPals = #$08 ;How many palettes to cycle through, add that many entries to the table below
;Palettes:		 ;Which palettes to cycle through (Sprite palettes, use 0-7)
;db $00,$01,$02,$03,$04,$05,$06,$07

!OffDisable =    0  ; If 1, will stop if On/Off is Off
!OffDisableRev = 0  ; If 1, will stop if On/Off is On

!BluePDisable    = 0  ; If 1, will stop if blue switch is active
!BluePDisableRev = 0  ; If 1, will stop if blue switch is inactive

!SilverPDisable    = 0  ; If 1, will stop if silver switch is active
!SilverPDisableRev = 0  ; If 1, will stop if silver switch is inactive

!KickSound   = #$03
!KickBank    = $1DF9|!Base2

!SpinSound   = #$02
!SpinBank    = $1DF9|!Base2

!BounceSound = #$13
!BounceBank  = $1DF9|!Base2

!ShatterSound = #$07
!ShatterBank = $1DFC|!Base2

BounceTiles: ;Tiles that bounce the block up like triangles do, end with $FFFF
dw $01B4,$01B5,$FFFF
!BounceSpeed = #$B8 ; Y speed when bouncing off of a tile

print "INIT ",pc
LDA #$00
STA !160E,x
STA !1534,x
LDA #$FF			
CMP !1570,x			
BEQ NoTimer	
LDA !VanishTime

STA !1570,x			
LDA #$09			
STA !14C8,x			
NoTimer:
STZ !1510,x
LDA !151C,x
CMP #$0B
BNE +
STA !14C8,x

LDA $96
STA !D8,x
LDA $97
STA !14D4,x

LDA $76
BNE ++

LDA $94
SEC
SBC #$0C
STA !E4,x
LDA $95
SBC #$00
STA !14E0,x
BRA +

++
LDA $94
CLC
ADC #$0C
STA !E4,x
LDA $95
ADC #$00
STA !14E0,x


+

if !StartDir != 0

	LDA #!StartDir
	STA !1510,X
	LDA #$0A
	STA !14C8,X

	if !StartDir = 2
		LDA !LeftSpeed		
		STA !B6,x
		STA !160E,x
	endif
	if !StartDir = 3
		LDA !RightSpeed		
		STA !B6,x
		STA !160E,x
	endif

endif

RTL


print "MAIN ",pc
PHB                     
PHK                     	
PLB                     	
JSR Main
PLB 			
RTL


Main:
JSR Graphics			
LDA #$00
%SubOffScreen()

if !OffDisable
LDA $14AF|!Base2
BNE Return0
endif
if !OffDisableRev
LDA $14AF|!Base2
BEQ Return01
endif

if !BluePDisable
LDA $14AD|!Base2
BNE Return01
endif
if !BluePDisableRev
LDA $14AD|!Base2
BEQ Return01
endif

if !SilverPDisable
LDA $14AE|!Base2
BNE Return01
endif
if !SilverPDisableRev
LDA $14AE|!Base2
BEQ Return01
endif

LDA $9D
BEQ +

Return0:
STZ !B6,x
RTS
+

LDA !14C8,x		
CMP #$0A
BNE ++

LDA !1510,x
BNE +

LDA !B6,x
BMI +++
JMP Right
+++
JMP Left

++
CMP #$02			
BNE +			    
JMP Vanish
+

LDA !14C8,x			
CMP #$0B			
BNE +
LDA #$00
STA !1510,x
BRA Carried			
+
LDA !1510,x 		
BEQ +
JMP Moving			

+
JSL $01A7DC			
BCC Share			

LDA $1470|!addr
ORA $148F|!addr
BNE Kick

LDA $15        		
AND #$40        	
BEQ Kick	      	

LDA !14C8,x			
BEQ Share			

LDY #$0B			
CheckCarry:			
LDA !14C8,y			
CMP #$0B			
BEQ Share			
DEY				
BPL CheckCarry		

LDA #$0B			
STA !14C8,x			
BRA CarrySet

Kick:

LDA $15
AND #$08
BNE +

LDA $72
BNE +++

LDA $15
AND #$04
BNE CarrySet

+++

;LDA $7B				
;BEQ CarrySet

LDA !KickSound
STA !KickBank

LDA #$10
STA !154C,x

+
LDA #$01			
STA !1510,x			
Carried: 
LDA $76				
STA !1528,x			

BRA CarrySet

Share:
LDA #$01			
STA !1528,x			
CarrySet:
LDA !1570,X         
if !Vanish
BEQ Vanish
LDA $14
BIT #$01
BNE +
LDA !1570,x
DEC
STA !1570,x
+			
else
CMP #$05
BNE +
LDA #$FF
STA !1570,x
+
endif

LDA $14
AND !PalRate
BNE Return  	       
ChangePAL:
LDA !1534,X
INC
CMP !NumPals
BNE +
LDA #$00
+
STA !1534,X
TAY
LDA Palettes,Y
ASL
STA $00
LDA !15F6,X		     	
AND #$F1               
ORA $00
STA !15F6,X		     	
Return:

LDA !1588,x			
AND #$84
BEQ +++
LDA !AA,x
BPL +++
LSR
ORA #$80
STA !AA,x
+++


RTS

Vanish:
LDY #$03		
SmokeLoop:	
LDA $17C0|!Base2,y
BEQ DrawSmoke	
DEY				
BPL SmokeLoop			
RTS

DrawSmoke:
LDA #$01			
STA $17C0|!Base2,y	
LDA #$1C     		
STA $17CC|!Base2,y	
LDA !D8,x			
STA $17C4|!Base2,y	
LDA !E4,x			
STA $17C8|!Base2,y	
STZ !14C8,x			
STZ !C2,x			
STZ !1510,x			
STZ !1528,x			
RTS


Moving:

if !NoUpthrowBreak
LDA !1510,x
CMP #$04
BNE ++

LDA !1588,x			
AND #$03
BEQ ++

LDA #$00
STA !B6,x
STA !160E,x
			
BRA +
++

endif

LDA !1588,x			
AND #$03			
BEQ +
JMP Shatter	
+
LDA !1510,x
CMP #$04
BEQ +
LDA !1588,x			
AND #$84
BEQ ++
LDA #$00
STA !AA,x
BRA ++
+
LDA !1588,x			
AND #$84
BEQ ++
LDA !AA,x
BPL +++
LSR
ORA #$80
STA !AA,x
+++

LDA !B6,x
BPL +++
LSR
ORA #$80
STA !B6,x
STA !160E,x
BRA ++
+++
LSR
STA !B6,x
STA !160E,x
++

JSR SpriteInteract		
LDA !1510,x			
CMP #$02			
BEQ Left			
CMP #$03			
BEQ Right			
CMP #$04
BEQ Up

LDA $15
AND #$08
BEQ ++
LDA $7B
BMI +++
LSR
BRA ++++
+++
LSR
ORA #$80
++++
STA !B6,x
STA !160E,x
LDA #$10
STA !154C,x
BRA Up
++

%SubHorzPos()
CPY #$00
BEQ Left			


Right:

LDA !1510,x
CMP #$03
BEQ +

LDA #$03			
STA !1510,x			

LDA !RightSpeed	
STA !B6,x
STA !160E,x

if !ThrowMomentum
EOR $7B
BMI NoSpeed
LDA $7B
STA $00
ASL $00
ROR
CLC
ADC !RightSpeed
endif
BRA SetSpeed 

+
if !SpinJump
JSR SpinCheck
endif
if !Bounce
JSR BounceCheck
endif
JSR TriangleCheck

BRA NoSpeed

Up:
LDA #$04			
STA !1510,x			

JSR UpThrow

BRA NoSpeed

Left:

LDA !1510,x
CMP #$02
BEQ +
LDA #$02			
STA !1510,x			

LDA !LeftSpeed		
STA !B6,x
STA !160E,x

if !ThrowMomentum
EOR $7B
BMI NoSpeed
LDA $7B
STA $00
ASL $00
ROR
CLC
ADC !LeftSpeed
endif
BRA SetSpeed 

+
if !SpinJump
JSR SpinCheck
endif
if !Bounce
JSR BounceCheck
endif
JSR TriangleCheck
BRA NoSpeed

SetSpeed:
STA !160E,x
NoSpeed:

LDA !B6,x
BEQ +
EOR !160E,x
AND #$80
BEQ +

LDA !160E,x
EOR #$FF
INC
STA !160E,x
LDA !1510,x
EOR #$01
STA !1510,x
+
LDA !160E,x
STA !B6,x			
;JSL $018022		
JMP CarrySet

Shatter:
LDA !ShatterSound	
STA !ShatterBank			
LDA !E4,x          
STA $9A            
LDA !14E0,x        
STA $9B            
LDA !D8,x          
STA $98            
LDA !14D4,x        
STA $99  			
PHB				
LDA #$02		
PHA				
PLB				
LDA #$00		
JSL $028663		
PLB				
STZ !14C8,x		

if !BreakSpawn
JSL $02A9DE|!BankB
BMI EndSpawn

TYA
STA !160E,x


LDA !Sprite
if !Custom
PHX
TYX
STA !7FAB9E,x
PLX
else
STA !9E,y
endif
	
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

if !Custom

	LDA #$08|(!Extra*4)
	STA !7FAB10,x
	JSL $0187A7|!BankB

endif
PLX

LDA !State
STA !14C8,y

LDA #$10
STA !154C,y
EndSpawn:
endif
RTS

SpriteInteract: 
LDY #$0B		
-
LDA !14C8,y		
CMP #$08		
BEQ CheckSprite	
Next:
DEY				
BPL -
RTS

CheckSprite:
PHX				
TYX				
JSL $03B6E5		
PLX				
JSL $03B69F		

JSL $03B72B		    
BCC Next	

LDA !167A,y			
AND #$02			
BNE NoContact		
LDA #$02			
STA !14C8,y			
LDA #$C0			
STA !AA,y			
LDA #$00			
STA !B6,y			
NoContact:
RTS



UpThrow:

if !Vanish = 0
LDA !1570,X     
BMI +        	
CMP #$05
BPL +
LDA #$FF
STA !1570,x
+
endif

JSL $018022		


LDA !154C,x
BNE EndUp

JSL $01A7DC		
BCC EndUp		

LDA $15        	
AND #$40        
BEQ KickU	    

LDA !14C8,x		
BEQ EndUp		

LDY #$0B		
CheckCarryU:	
LDA !14C8,y		
CMP #$0B		
BEQ KickU		
DEY				
BPL CheckCarryU	

LDA #$0B		
STA !14C8,x		

LDA #$01		
STA !1510,x		
BRA EndUp

KickU:

LDA !KickSound
STA !KickBank

LDA #$10
STA !154C,x

LDA #$01		
STA !1510,x		

LDA $76			
STA !1528,x		
EndUp:
RTS



Graphics:
	%GetDrawInfo()
	


	LDA $00			
	STA $0300|!Base2,y		

	LDA $01			
	STA $0301|!Base2,y

	LDA !Tile
	STA $0302|!Base2,y

	LDA !15F6,x		
	ORA $64
	STA $0303|!Base2,y

	INY #4
	LDA #$F0
	STA $0201|!Base2,y

	LDY #$02
	LDA #$00

	JSL $01B7B3|!BankB
	RTS		


SpinCheck:
			LDA !B6,x
			BEQ ++
			LDA !154C,x
			BNE ++

			LDA $140D|!Base2
			BNE +
			++
			RTS
			+
			LDA $7D
			BMI NoSpin

			JSL $01A7DC|!BankB		
			BCS +
			BRA NoSpin
			+

			LDA !15AC,x
			BEQ +
			DEC
			STA !15AC,x
			BRA NoSpin

			+
		


			LDA #$10
			STA !15AC,x

			LDA $15		
			AND #$80	
			BEQ BounceLow
			LDA #$A8	
			STA $7D		
			BRA Sound	
		BounceLow:
			LDA #$C0	
			STA $7D		
		Sound:

			JSL $01AB99|!BankB
			if !SpinBreak
			JMP Shatter
			else
			LDA !SpinSound
			STA !SpinBank
			endif
		NoSpin:
	RTS


BounceCheck:
			LDA $72
			BEQ ++
			LDA !B6,x
			BEQ ++
			LDA !154C,x
			BNE ++

			LDA $140D|!Base2
			BEQ +
			++
			RTS
			+
			LDA $7D
			BEQ NoBounce
			BMI NoBounce

			JSL $01A7DC|!BankB		
			BCS +
			BRA NoBounce
			+

			LDA !15AC,x
			BEQ +
			DEC
			STA !15AC,x
			BRA NoBounce

			+
		


			LDA #$10
			STA !15AC,x

			LDA $15		
			AND #$80	
			BEQ BounceLow2
			LDA #$A8	
			STA $7D		
			BRA Sound2
		BounceLow2:
			LDA #$C0	
			STA $7D		
		Sound2:
			JSL $01AB99|!BankB
			LDA #$00
			STA !160E,x
			STA !B6,x
			STA !1510,x
			LDA #$10
			STA !154C,x
			if !BounceBreak
			JMP Shatter
			else
			LDA !BounceSound
			STA !BounceBank
			endif
		NoBounce:
	RTS

TriangleCheck:
	PHX
	REP #$20
	LDX #$00

	LDA $1860
	STA $00	
	LDA $1862
	STA $01

	-
	LDA BounceTiles,X
	CMP #$FFFF
	BEQ TriangleEnd
	CMP $00
	BNE TriangleNext

	PLX
	SEP #$20
	LDA !BounceSpeed
	STA !AA,X
	RTS

TriangleNext:
	INX
	INX
	BRA -

TriangleEnd:
	SEP #$20
	PLX
	RTS