; Use with custom GFX file, ExGFX102, put in SP4

; Slight mods by SJC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Metroid Escape Sequence Timer + Stopwatch (from Krack The Hack)
; Coded by Mellonpizza
; Modified by Daizo Dee Von
;
; The timer from Super Metroid using sprite tiles. Can be placed
; anywhere on screen, and with the !COUNTING define it can be
; a stopwatch or a timer. It resets when the player is on the
; overworld. Credit must be given to both of us. :)
;
; See .TimerTileLookup to change each oam tile
;
; NOTE WITH RETRY PATCH: Make sure to add STZ $1489 (or whatever
; you changed !ResetCheck to) in retry_extra.asm where "DeathRoutine:"
; is just so the timer is reset after you die.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!COUNTING = !UP ; Change to !UP or !DOWN if you want a stopwatch or a timer

!Seconds = 0	; Leave 0 for stopwatch
!Minutes = 0	; same as above

!FreeRAM = $0EE6

!Y_Placement = $C4 ; y placement for the entire timer (C8 is at very bottom of screen)
!X_Placement = $60 ; x placement for above (60 is default, C0 is at the very edge of right side)

!Properties = %00110101 ; yxppccct format (Palette A; 00110111 uses Palette B)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FreeRAM used (make sure they reset while on overworld)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!MetroidEscapeTimer = $146C
!MetroidTimerState = !MetroidEscapeTimer+3
!MetroidTimerXpos = $1487
!MetroidTimerYpos = !MetroidTimerXpos+1
!ResetCheck = $1489

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; don't change these defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!UP		= $00
!DOWN	= $01


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Init code (for setting during first frame of level start)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init:
	LDA $1489
	BNE +
	INC !MetroidTimerXpos+2
	LDA #!Y_Placement
	STA !MetroidTimerYpos
	LDA #!X_Placement
	STA !MetroidTimerXpos
	LDA #!Seconds ; note: this can be controlled with freeram too
	STA !MetroidEscapeTimer+1
	LDA #!Minutes ; note: this can be controlled with freeram too
	STA !MetroidEscapeTimer+2
	+
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		Main code (for every frame)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main:
	
	LDA $9D : BEQ +			;> check freeze frame
	JMP .DrawMetroidTimer
+	LDA $13D4 : BEQ +		;> check pause
	JMP .DrawMetroidTimer
+	LDA !FreeRAM : BEQ +		;> check this FreeRAM
	JMP .DrawMetroidTimer
+	LDA $1493 : BEQ +		;> check end level sequence
	JMP .DrawMetroidTimer	; change to RTL if you want timer to disappear
+
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Put your code here for anyything that runs during the
; countdown sequence. Example:
; LDA $1887 : BNE + : LDA #$FF : STA $1887 : +
; for continuous shaking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if !COUNTING == !UP
	INC !MetroidEscapeTimer
	LDA !MetroidEscapeTimer : CMP #$3C : BCC .DrawMetroidTimer
	stz !MetroidEscapeTimer
	INC !MetroidEscapeTimer+1 
	LDA !MetroidEscapeTimer+1 : CMP #$3C : BCC .DrawMetroidTimer
	stz !MetroidEscapeTimer+1
	INC !MetroidEscapeTimer+2 
	LDA !MetroidEscapeTimer+2 : CMP #$3C : BCC .DrawMetroidTimer
	
	; Stops at 59:59:58
	LDA #$3C
	STA !MetroidEscapeTimer
	STA !MetroidEscapeTimer+1
	STA !MetroidEscapeTimer+2
	JMP .DrawMetroidTimer
else
	dec !MetroidEscapeTimer : bpl .DrawMetroidTimer
	lda #$3B : sta !MetroidEscapeTimer
	dec !MetroidEscapeTimer+1 : bpl .DrawMetroidTimer
	lda #$3B : sta !MetroidEscapeTimer+1
	dec !MetroidEscapeTimer+2 : bpl .DrawMetroidTimer
	
	;; Timer expired, run ending routine
	stz !MetroidEscapeTimer
	stz !MetroidEscapeTimer+1
	stz !MetroidEscapeTimer+2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Put your code here for what happens if time runs out
; for example, mario dying (a classic)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	JSL $00F606 ; kill mario
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JMP .DrawMetroidTimer
endif

.DrawMetroidTimer
	;; Draw milliseconds (Convert 60 frames -> 100 milliseconds)
	lda !MetroidEscapeTimer
	ldx #$00 : sec
	-
	sbc #$06 : bcc +
	inx : bra -
	+
	adc #$06 : tay
	lda .Millisecond_Display,y
	jsr .Convertlookup
	sty $0C : sta $0B

	;; Draw seconds
	lda !MetroidEscapeTimer+1 : jsr .HexToDec
	sty $0A : sta $09

	;; Draw minutes
	lda !MetroidEscapeTimer+2 : jsr .HexToDec
	sty $08 : sta $07

	;; Draw tiles
	rep #$20
	lda #$EEDE : sta $04 ; First number here, EE, is tile for -IME (and tick mark?). DE is the T-. Default lda #$441A : sta $04 
	sep #$20
	lda #$CE : sta $06  ; Seconds tick mark GFX. Default lda #$0A : sta $06
	lda !MetroidTimerXpos : sta $00
	lda !MetroidTimerYpos : sta $01
	lda.b #$B4/4 : sta $02
	ldx #$08 : ldy #$B4
	-
	lda $00 : clc : adc .MetroidTimeXoff,x : sta $0200,y
	lda $01 : clc : adc .MetroidTimeYoff,x : sta $0201,y
	lda $04,x : sta $0202,y
	lda #!Properties : sta $0203,y
	ldy $02 : lda .MetroidTimeSize,x : sta $0420,y
	iny : sty $02 : tya : asl #2 : tay
	dex : bpl -
	rtl


.HexToDec
	ldx #$00
	-
	cmp #$0A : bcc .Convertlookup
	sbc #$0A : inx : bra -

.Convertlookup
	tay : lda .TimerTileLookup,y : tay
	lda .TimerTileLookup,x
	rts

.Millisecond_Display:
db $00,$01,$03,$05,$06,$08

.TimerTileLookup
db $80,$82,$84,$86,$88,$A0,$C0,$C2,$8E,$AE ; default $00,$02,$04,$06,$20,$22,$24,$26,$40,$42
db $A6,$A8,$CC,$CE,$EC,$EE;DEBUG

.MetroidTimeXoff
db $00,$08,$28,$00,$08,$18,$20,$30,$38
.MetroidTimeYoff
db $00,$00,$08,$08,$08,$08,$08,$08,$08
.MetroidTimeSize
db $00,$02,$00,$02,$02,$02,$02,$02,$02