;The top-left of the custom switch palace switch.
;Acts like $130

!FreeRAM = $0E1D

!TopLeft	= $10FE		;\The tiles the switch turns into when pressed.
!TopRight	= $10FF		;|must be 4 hex digits long.
!BottomLeft	= $110E		;|
!BottomRight = $110F		;/

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH
JMP MarioCape : JMP MarioFireBall : JMP TopCorner : JMP HeadInside : JMP BodyInside

MarioAbove:
TopCorner:
	LDA $7D			;\Don't trigger the switch if the player goes up on the corners
	BPL +			;/of the block.
	RTL
+
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Map16 change routine, do not touch, but however, feel free to use it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REP #$10		;\Change the top left block.
	LDX #!TopLeft		;|
	%change_map16()		;|
	SEP #$10		;/

	PHY			;>Protect block behavor
	REP #$30		;>16-bit AXY
	LDY #$0004		;>Loop start	
-
	PHP			;>protect processor mode.
	PHY			;>This subroutine should not mess with Y as a loop counter.
	SEP #$30		;>Because this subroutine is 8-bit mode
	JSR SwapXYHigh		;>Vertical levels have their $99 and $9B swapped.
	REP #$30		;>Even with PLP, this needed to prevent game crashes.
	PLY			;>Now use Y as a loop counter index
	PLP			;>restore processor mode.

	LDA $98			;\Shift Y position
	CLC			;|
	ADC YPosShft,y		;|
	STA $98			;/
	LDA $9A			;\Shift X position
	CLC			;|
	ADC XPosShft,y		;|
	STA $9A			;/

	PHY
	LDX TileChangeTbl,y	;\Change current tile
	%change_map16()		;/
	PLY

	DEY			;\two bytes over since the tables are 16-bit numbers.
	DEY			;/
	BPL -

	SEP #$30		;>8-bit AXY
	PLY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Put your custom code here, this runs for 1 frame.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDA #$20		;\Earthquake effect.
	STA $1887		;/

;Example:
	LDA #$0B		;\On/Off switch sfx (in smw, switch palaces has no sfx when pressed)
	STA $1DF9		;/so feel free to remove this if you want.
	
	LDA #$01
	STA !FreeRAM
	
	;LDA #$01 ; Message display. 01=Message1 02=Message2 03=Yoshi thanks message
	;STA $1426
	
	;LDA $xxxx		;\ $1F27: Green, $1F28: Yellow, $1F29: Blue, $1F2A: Red
	;EOR #$01		;|
	;STA $xxxx		;/



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Custom stuff ends here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MarioBelow:
MarioSide:
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
HeadInside:
BodyInside:
	RTL

SwapXYHigh:
	LDA $5B				;\Check if vertical level = true
	AND #$01			;|
	BEQ +				;/
	LDA $99				;\Fix the $99 and $9B from glitching up if placed
	LDY $9B				;|other than top-left subscreen boundaries of vertical
	STY $99				;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B				;|(this switch values $99 <-> $9B, since the subscreen boundaries are sideways).
+					;/
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Tables to move and change tiles, do not touch, but feel free to use.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
XPosShft:
	dw $FFF0, $0000, $0010
YPosShft:
	dw $0000, $0010, $0000
TileChangeTbl:
	dw !BottomLeft, !BottomRight, !TopRight

print "The top-left part of a 32x32 switch palace switch. By default this will NOT activate the normal switch palace switch stuff (not even the message). Instead, hitting it will simply press the switch down and activate an arbitrary RAM address ($0E1D), which you can then use for other purposes (including, for example, DelayBeforeRunningCodeTemplate.asm); or you can also set it to activate a specific color switch, too."