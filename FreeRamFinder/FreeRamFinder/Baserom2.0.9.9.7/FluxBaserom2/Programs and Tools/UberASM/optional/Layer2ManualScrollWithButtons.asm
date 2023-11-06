;========================
;uberASM
;========================
;Version 1.4
;========================
;This ASM scrolls layer 2
;up and down depending on
;the button you pressed. (Default L and R shoulder buttons)
;========================
;Created by badummzi
;========================


;===Customizable===

!freeram = $0E18	;1-Byte. Only used, when SpeedType = $00

!Direction = $1468	;Which 'direction' layer two should scroll ($1466 = left/right, $1468 = up/down)

!U = #%00100000		;Which button causes layer 2 to scroll up/left; default L. (Format: axlr---- (Only when adress is $17. For other formats, please refer to the SMWC Ram-Map)
!D = #%00010000		;Which button causes layer 2 to scroll down/right, default R.

!UAddr = $17		;Ram-Adress of the button that makes layer 2 scroll up/left
!DAddr = $17		;Ram-Adress of the button that makes layer 2 scroll down/right

!ULock = #$00FF		;How much layer 2 can scroll up/left (16-Bit/Little-Endian! Use $1468 for reference on up/down and $1466 for reference on left/right)
!DLock = #$0000		;How much layer 2 can scroll down/right (16-Bit/Little-Endian! Use $1468 for reference on up/down and $1466 for reference on left/right)

!SpeedType = $00	;How fast the speed-values below are. ($01 = Default / Gets faster the higher the value, $00 = Slower than default (uses the freeram adress) / gets slower, the higher the value)

; > If set to $FF, when SpeedType = $01/$00, the layer won't move in the certain direction.
!SpeedUp = $00		;What speed the layer scrolls up/left
!SpeedDown = $00	;What speed the layer scrolls down/right

!HScroll = $01		;Set this to $00, if you're in a vertical level and want to disable the horizontal scroll (also makes layer 2 not move with the player (in vertical levels)) ;)

!ScrollLevelEnd = $00	;Set this to $01, if you want the player to still be able to scroll, after he hit the goaltape/ orb, etc. (Good for a troll :P)

;===End of customizable stuff===

;===Code begins below===

main:
	if !HScroll == $00
		STZ $1411|!addr
	endif
	LDA #!SpeedType
	BNE .check
	LDA !freeram|!addr
	BNE .SpeedSlow
	JSL .check
	RTL

.SpeedSlow:
	DEC !freeram|!addr
	RTL

.check:
	if !ScrollLevelEnd == $00
		LDA $1493|!addr
		BNE .end
	endif
	LDA $13D4|!addr
	BNE .end
	LDA $9D
	BNE .end
	LDA !UAddr
	AND !U
	if !SpeedType == $00
		BNE .upSlow
	else
		BNE .up
	endif
	LDA !DAddr
	AND !D
	if !SpeedType == $00
		BNE .downSlow
	else
		BNE .down
	endif
	RTL

.up:
	if !SpeedUp != $FF
		REP #$20
		LDX #!SpeedUp
		.increase
			LDA !Direction|!addr
			CMP !ULock
			BEQ .end
			INC !Direction|!addr
			DEX
			BPL .increase
		SEP #$20
	endif
	RTL

.down:
	if !SpeedDown != $FF
		REP #$20
		LDX #!SpeedDown
		.decrease
			LDA !Direction|!addr
			CMP !DLock
			BEQ .end
			DEC !Direction|!addr
			DEX
			BPL .decrease
		SEP #$20
	endif
	RTL

.end:
	SEP #$20
	RTL

.upSlow:
	if !SpeedUp != $FF
		LDA #!SpeedUp
		STA !freeram|!addr
		REP #$20
		LDA !Direction|!addr
		CMP !ULock
		BEQ .end
		INC !Direction|!addr
		SEP #$20
	endif
	RTL

.downSlow:
	if !SpeedDown != $FF
		LDA #!SpeedDown
		STA !freeram|!addr
		REP #$20
		LDA !Direction|!addr
		CMP !DLock
		BEQ .end
		DEC !Direction|!addr
		SEP #$20
	endif
	RTL
