;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extending block. Right growing block.
; By TheBiob
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!sprite	= $A4					; Sprite number of the sprite
!extendsize	= $0005				; Maximal blocks the block can extend (Should be the same you defined in the sprite) (Above $00FF is not recommended)

!lowbyte	= !1602				; sprite table used to store the y low position of the block (Must be the same you defined in the sprite)
!highbyte	= !160E				; sprite table used to store the y high position of the block (Must be the same you defined in the sprite)

!time		= $01				; how long the block will not be hit-able (Will use below address to store to)
;!timer		= $14AC|!addr		; Needs to decrement automatically
!timer		= $0F5E|!addr		; Table of 16 individual timers

!use_multiple_timer = 1			; If this is set to 1 !timer needs to be 16 bytes long, each acting as a timer for a block on that row of a screen

; SA-1 check, do not modify
if read1($00FFD5) == $23
	!SprSize = $16
else
	!SprSize = $0C
endif

db $42
JMP M : JMP R : JMP R
JMP SVert : JMP SHoriz
JMP M : JMP R
JMP R : JMP R : JMP R

SVert:
	JSR CheckKickedV
	BCS SprSpawn
	RTL
SHoriz:
	JSR CheckKickedH
	BCS SprSpawn
R0:	RTL

SprSpawn:
	LDA $0A 			; Adjust block position when hit by a sprite
	STA $9A
	LDA $0B
	STA $9B
	LDA $0C
	STA $98
	LDA $0D
	STA $99
M:
if !use_multiple_timer
	LDA $9A
	LSR #4
	TAX
	LDA !timer,x
else
	LDA !timer
endif
	BNE R0
	REP #$20
		LDA $98		; \ Get top left corner of the block
		AND #$FFF0	; |
		STA $98		; |
		LDA $9A		; |
		AND #$FFF0	; |
		STA $9A		; /
		CLC : ADC.w #(!extendsize<<4)+1
		STA $0C
	SEP #$20
	LDX #!SprSize-1
-		LDA !7FAB10,x	; \
		AND #$08		; |
		BEQ +			; |
		LDA !7FAB9E,x	; |
		CMP #!sprite	; |
		BNE +			; |
						; |
		LDA !14D4,x		; |
		XBA				; |
		LDA !D8,x		; |
		REP #$20		; |
			CMP $98		; | Kill all sprites that are already in the block area so they don't cause problems
			BNE +		; |
		SEP #$20		; |
		LDA !14E0,x		; |
		XBA				; |
		LDA !E4,x		; |
		REP #$20		; |
			CMP $9A		; |
			BCC +		; |
			CMP $0C		; |
			BCS +		; |
		SEP #$20		; |
						; |
		STZ !14C8,x		; /

+	SEP #$20 : DEX : BPL -
	LDA #!sprite			; \ Spawn new sprite
	SEC						; |
	%spawn_sprite()			; |
	BCS R					; |
	TAX						; |
	%move_spawn_into_block(); /

	LDA $9A			; \ Store position so the sprite knows where to return to
	STA !lowbyte,x	; |
	LDA $9B			; |
	STA !highbyte,x	; /
if !use_multiple_timer
	LDA $9A
	LSR #4
	TAX
	LDA #!time		; \ Set "cannot hit block" timer
	STA !timer,x
else
	LDA #!time		; \ Set "cannot hit block" timer
	STA !timer		; /
endif
R: 	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Sprite Checks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This subroutine checks to see if a sprite was thrown at the block vertically.
; If the carry flag is set, the sprite was thrown with enough force.
CheckKickedV:
	LDA !AA,x
	BPL EndKickCheck1
	LDA !14C8,x
	CMP #$09
	BCC EndKickCheck1
	SEC
	RTS

EndKickCheck1:
	CLC
	RTS

; This subroutine checks to see if a sprite was thrown at the block horizontally.
; If the carry flag is set, the sprite was thrown with enough force.
CheckKickedH:
	LDA !14C8,x
	CMP #$09
	BEQ SpriteKickHCont
	CMP #$0A
	BEQ SpriteKickH1
	CLC
	RTS

SpriteKickHCont:
	LDA !B6,x
	BMI SpriteKickH0
	CMP #$08
	BCS SpriteKickH1
SpriteKickHReturn:
	CLC
	RTS

SpriteKickH0:
	CMP #$F8
	BCS SpriteKickHReturn
SpriteKickH1:
	SEC
	RTS

print "This block can grow up to ", dec(!extendsize), " tiles right when hit from below or the side. Don't use in true vertical levels! If you had planned on doing this, use the tall horizontal level mode to emulate a vertical level instead."