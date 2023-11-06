; Very minor define, SJC

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Goal Point Question Sphere, by imamelia
;
; This is a round sprite with a "?" on it that appeared in SMW and SMB3.  It ends
; the level when touched. 
;
; Extra bytes: 1
;
; Extra byte 1:
; - Bit 0: 0 -> normal exit, 1 -> secret exit (does not work in vertical levels).
; - Bit 1: 0 -> don't walk after touching the sprite, 1 -> walk.
; - Bit 2: 0 -> play "boss defeated" music, 1 -> play normal goal music.
; - Bit 3: 0 -> no gravity (orb won't fall down), 1 -> orb has gravity.
; - Bits 4-6: Nothing (formerly sprite palette).
; - Bit 7: Unused.
;
; For example, if you had 04 for your extra byte (bit 2 set), this would play the normal goal music 
;
; *NOTE: The secret exit works only if the sprite is set to make the player walk
; after touching it.  It's an annoying quirk of SMW's exit handling.  It is possible
; to circumvent this by using the hex edit at $00C9FE.  If you do, set !AltExitHandle
; to $01 instead of $00.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!Palette = $05
!GoalMusic = $03 ; not 0B
!Tilemap = $C2    ; Replaced cloud coin in GFX01. Normally 8C, shared with ledge mole dirt (GFX09)
                          ; and probably the shards when a throwblock breaks.
!TileXFlip = $40
!AltExitHandle = $00

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	;LDA !7FAB40,x		; extra byte 1
	;AND #$70			; bits 4-6
	;LSR #3				;
	;STA $00				;
	;LDA !15F6,x			;
	;AND #$F0			; F1
	;ORA !Palette				; set the sprite palette
	;STA !15F6,x			;
	RTL					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMainRt:
	JSR SubGFX			; draw the sprite
	LDA $9D				; if sprites are locked...
	BNE ReturnMain		; return
	LDA #$00			;
	%SubOffScreen()		;
	LDA !7FAB40,x		;
	AND #$08			;
	BEQ .NoGravity		;
	JSL $01802A|!BankB	;
.NoGravity:				;
	LDA $13				; frame counter
	AND #$1F			; once every 0x20 frames...
	JSR ShowSparkle		; display sparkles
	JSL $01A7DC|!BankB	; interact with the player
	BCC ReturnMain		; return if there is no contact
	STZ !14C8,x			; erase the sprite
	LDA #$01
	STA $0E6F ; freeze, SJC
	LDA #$FF				;
	STA $1493|!Base2			; set the level end timer
	STA $0DDA|!Base2			; mark the music as "abnormal"
	LDA !7FAB40,x		;
	PHA					;
	PHA					;
	AND #$01			;
if !AltExitHandle = $00		;
	STA $141C|!Base2			; store normal/secret exit info
else						;
	INC					;
	STA $0DD5|!Base2			;
endif					;
	PLA					;
	AND #$02			;
	BNE .Walk			;
	DEC $13C6|!Base2			;
.Walk:					;
	PLA					;
	LSR #3				;
	LDA #!GoalMusic				;
	ADC #$00			;
	STA $1DFB|!Base2			; set the level end music
	LDA #$01			;
	STA $13CE|!Base2			;
ReturnMain:				;
	RTS					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; sparkle routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ShowSparkle:
	ORA !186C,x			; don't show the sparkles if the sprite is offscreen vertically
	BNE .Return			;
	JSL $01ACF9|!BankB	; get a random number
	AND #$0F			;
	CLC					;
	LDY #$00				;
	ADC #$FC			;
	BPL $01				;
	DEY					;
	CLC					;
	ADC !E4,x			;
	STA $02				;
	TYA					;
	ADC !14E0,x			;
	PHA					;
	LDA $02				;
	CMP $1A				;
	PLA					;
	SBC $1B				; if the sparkle would be offscreen...
	BNE .Return			; end the sparkle routine
	LDA $148E|!Base2			;
	AND #$0F			;
	CLC					;
	ADC #$FE			;
	ADC !D8,x			;
	STA $00				;
	LDA !14D4,x			;
	ADC #$00			;
	STA $01				; set the Y position of the sparkle
	JSL $0285BA|!BankB		; create sparkles
.Return:					;
	RTS					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()		;
	LDA $00				;
	STA $0300|!Base2,y			; tile X position
	LDA $01				;
	STA $0301|!Base2,y			; tile Y position
	LDA #$C2 ; #!Tilemap			;
	STA $0302|!Base2,y			; tile number
	LDA !15F6,x			; palette and GFX page. 7A?
	ORA $64				; plus priority bits
	ORA #!TileXFlip		; X-flip the tile
	STA $0303|!Base2,y			; tile properties
	LDY #$02				; 16x16 tile
	LDA #$00			; 1 tile drawn
	JSL $01B7B3|!BankB		;
	RTS					;








