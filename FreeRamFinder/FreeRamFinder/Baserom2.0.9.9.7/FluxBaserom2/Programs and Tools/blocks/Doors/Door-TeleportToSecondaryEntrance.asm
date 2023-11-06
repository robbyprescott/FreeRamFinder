; by MolSno. Notes modified by SJC

; This door will teleport you to the secondary entrance set in the table below
; Note that if you stack doors/blocks vertically on the same x-coordinate, they will both lead to the same place. 
; If this is a problem, however, you could insert multiple copies of this block with separate WarpTables to get around that limitation.

db $42

JMP Return : JMP Return : JMP Return
JMP Return : JMP Return 
JMP Return : JMP Return
JMP Return : JMP MarioBodyInside : JMP Return

; After these comments is where you add exits.
; Format: dw $LLLL,$XXXX,$EEEE
; $LLLL = CURRENT level number.
	; Must be 4 digits long. For example, level 105 = $0105, or 24 = $0024.
; $XXXX = X-coordinate of the block.
	; The first two digits are the screen number. 
	; The second two digits are the x-coordinate of this block. 
	; Obviously you can just hover your cursor over a tile and look in the bottom-left corner of Lunar Magic to see the coordinates.
	; Note, however, that when you input the x-coordinate here, it should $xx00, xx10, 20, ... F0, etc., instead of 00, 01, 02, ... 0F.
	; For example, if it's tile 06 of screen 01, put $0160, or if it's tile 0A on screen 05, put $05A0. 
; $EEEE = Secondary entrance number this entry connects to, as set in the "2" double-door icon at the top of Lunar Magic.
	; Must be 4 digits. For example, Secondary Entrance 1 = $0001. Secondary entrance 1FF = $01FF.
	; You can then set the y-position of the secondary entrance Mario sprite itself.
	; The destination level can be the same as your current level.
WarpTable:
   ;   $LLLL,$XXXX,$EEEE
	dw $0105,$0110,$0001	;\ Level 105; screen 01 (01), tile 01 (10); secondary entrance 001
	dw $0105,$0130,$0002    ;/ Level 105; screen 01 (01), tile 03 (30); secondary entrance 002
	dw $FFFF				; Don't remove this entry or strange things might happen.

!Small_Door	= 0			; 0 = Allow all forms of Mario. 1 = Small Mario only.
						; Change this to 1 if you only want a small door.

!Level		= $010B		; Don't change this or every door will lead to level 0.

MarioBodyInside:
	; Determine if Mario is close enough to the center of the door.
	REP #$20
	LDA $9A : AND #$FFF0 : SEC : SBC #$0005 : CMP $94 : BCS Return
	CLC : ADC #$0008 : CMP $94 : BCC Return
	SEP #$20
	
	LDA $16 : AND #$08 : BEQ Return
	LDA $72
if !Small_Door > 0
	ORA $19
endif
	BNE Return
	; Everything checks out. Play the door sound.
	LDA #$0F : STA $1DFC
	
	; Check the warp table for level and x-coordinate. If they match, warp.
	REP #$30
	LDX #$0000
.Level
	LDA WarpTable,x
	CMP #$FFFF : BEQ NoExit
	CMP !Level : BEQ .XPos
	TXA : CLC : ADC #$0006 : TAX
	BRA .Level
.XPos
	INX #2
	LDA $9A : AND #$FFF0 : CMP WarpTable,x : BEQ .Warp
	TXA : CLC : ADC #$0004 : TAX
	BRA .Level
.Warp
	INX #2
	LDA WarpTable,x : SEP #$30 : LDY $95 : STA $19B8,y
	XBA : ORA #%00000110 : STA $19D8,y   ; exit table
	LDA #$06 : STA $71
	STZ $88 : STZ $89
Return:
	SEP #$20
	RTL
	
NoExit:
	LDA #$0000
	%teleport()
	RTL

print "A block that allows you to have a lot of doors with different destinations on the same screen. However, you must set the coordinates for where place the doors in the ASM file; and only one of these may be placed in the same x-coordinate. But you can have 14+ doors on dfferent y-coordinates."