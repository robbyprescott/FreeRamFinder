;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Extending block. Left Sprite.
; By TheBiob
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!block			= $0131			; Which block to spawn (Map 16 tile number)

!tile			= $40			; Which tile to display
!properties		= $04			; YXPPCCCT properties of that tile
!extendsize		= $05			; Maximal blocks the sprite can extend (Should be the same you defined in the block) (Above $FF is not recommended)

!speed			= $E0			; Speed (Needs to be between FF and 80)

!time			= $80			; How long the block should stay up

!lowbyte		= !1602			; sprite table used to store the y low position of the block (Must be the same you defined in the block)
!highbyte		= !160E			; sprite table used to store the y high position of the block (Must be the same you defined in the block)

!sound			= $02
!sndAddress		= $1DFC|!addr

print "INIT ",pc
	STZ !1510,x
RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
		JSR SpriteMain
	PLB
RTL


SpriteMain:
	LDA $9D			; \ Return if sprites are locked
	BNE .return0	; /
	
	LDA !1510,x
	BEQ .check
	CMP #$01
	BEQ .upspeed
	
	LDA !154C,x
	BNE .return0
	
	JSR GFX			; draw sprite
	JSL $01B44F		; Invisible solid block routine
	
	LDA #(!speed^$FF)+1
	STA !B6,x
	
	JSL $018022		; Update sprite's Y position without gravity
	
	LDA !highbyte,x	; \ Kill sprite if it has passed the starting point
	XBA				; |
	LDA !lowbyte,x	; |
	REP #$20		; |
		STA $0E		; |
	SEP #$20		; |
	LDA !14E0,x		; |
	XBA				; |
	LDA !E4,x		; |
	REP #$20
		CMP $0E		; |
	SEP #$20		; |
	BCS .killsprite	; /
	
	JSR SetupBlock
	
	REP #$20
		%GetMap16()
		CMP.w #!block
	SEP #$20
	BNE .return0
	
	LDA #$02		; \ Create empty tile at sprites position
	STA $9C			; |
	JSL $00BEB0		; /
	
	RTS
.killsprite
	STZ !14C8,x
	RTS
.upspeed
	JSR GFX			; draw sprite
	JSL $01B44F		; Invisible solid block routine
	
	LDA #!speed
	STA !B6,x
	JSL $018022		; Update sprite's X position without gravity
	LDA !E4,x
	AND #$0F
	BNE .return0
	JSR PlaceBlock
-	LDA #!time
	STA !154C,x
	LDA #$02
	STA !1510,x
.return0
	RTS

.check
	LDA !1504,x			; \ Find the next tile
	CMP #!extendsize	; |
	BCS -				; |
	INC !1504,x			; |
	LDA !14E0,x			; |
	XBA					; |
	LDA !E4,x			; |
	REP #$20			; |
		SEC : SBC #$0010; |
		STA $9A			; |
	SEP #$20			; |
	LDA !D8,x			; |
	STA $98				; |
	LDA !14D4,x			; |
	STA $99				; |
	REP #$20
		%GetMap16()		; |
	CMP.w #!block		; |
	SEP #$20			; |
	BNE .noblock		; |
	LDA $9A			; \ Set new sprite position
	STA !E4,x		; |
	LDA $9B			; |
	STA !14E0,x		; /
	BRA .check		; > Check if the next block is open
.noblock
	LDA #$01		; \ Go to next state
	STA !1510,x		; /
	LDA #!sound		; \ Play sound
	STA !sndAddress	; /
.return
RTS

GFX:
	%GetDrawInfo()
	
	LDA $00			; x position
	INC				; \ Adjust X by 2 pixel
	INC				; /
	STA $0300|!addr,y
	LDA $01			; y position
	DEC				; Adjust Y by 1 pixel
	STA $0301|!addr,y
	LDA #!tile 		; tile
	STA $0302|!addr,y
	LDA #!properties; properties
	STA $0303|!addr,y
	
	LDY #$02		; 16x16
	LDA #$00		; 1 tile
	JSL $01B7B3		; reserve
RTS

SetupBlock:
	LDA !E4,x		        ; \ XPos
    STA $9A                 ;  |
	LDA !14E0,x				;  | Screen
	STA $9B                 ;  |
	LDA !D8,x             	;  | YPos
	STA $98					;  |
	LDA !14D4,x	            ;  | SubScreen
	STA $99                 ; / set up block position
RTS

PlaceBlock:
	JSR SetupBlock
	
	PHP
	REP #$20                ; \ generate map16 tile 
		LDA.w #!block       ;  |
		%ChangeMap16()  ;  |
	PLP                     ; /
RTS
