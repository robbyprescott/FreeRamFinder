; I already added the prep patch, so you don't need to. (Without it, it will trigger side exit)

;  This connects the left and right sides of the screen, wrapping sprites and Mario from one to the other.
;  Using this will disable any horizontal scrolling, and shift the level two tiles rightwards;
;  this is done so that you can handle interaction properly for just outside the left edge of the level.
;
; Coded by kaizoman666 / Thomas, based on the patch by Noobish Noobsicle.


!ScrollSettingsFix = 0
!levelShift = $0020		; how far to shift the level rightwards
!leftEdge   = $0010		; where to actually wrap Mario, on the left
!rightEdge  = $0120		; where to actually wrap Mario, on the right


;; Code below this point ---------------------------------------
!dist = !rightEdge-!leftEdge

load:
	if !ScrollSettingsFix = 0
	REP #$20
	LDA #!levelShift
	STA $1A
	STA $1462|!addr
	LDY $1413|!addr
	BEQ ++
	DEY
	BEQ +
	LSR
  +	STA $1E|!addr
 ++ SEP #$20
	STZ $1411|!addr
	SEC : ROR $1B96  ; simply changing to LDA #$AC : STA $1B96 would force side-exit enable when touch sides, so had to apply prep patch
	endif
	if !ScrollSettingsFix = 1
	REP #$20
	LDA #!levelShift
	STA $1A
	STA $1462|!addr
	PHK
	PEA .return-1
	PHK
	LDY.b #!bank>>16 : PHY : PLB
	JML $00F79D|!bank
.return
	SEP #$20
	STZ $1411|!addr
	SEC : ROR $1B96|!addr
	endif
	RTL

main:
	LDA $9D
	BNE .noWrap
	JSR WrapMario
	JSR WrapSprites
  .noWrap
	RTL


WrapMario:
	REP #$20
	LDA $94
	CMP #!rightEdge
	BMI .checkLeft
	SEC : SBC #!dist
	STA $94
	BRA .noWrap
  .checkLeft
	CMP #!leftEdge
	BPL .noWrap
	CLC : ADC #!dist
	STA $94
  .noWrap
	SEP #$20
	RTS


WrapSprites:
	LDX #!sprite_slots-1
  .loop
	LDA !14C8,x
	BEQ .skip
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CMP #!rightEdge
	BMI .checkLeft
	SEC : SBC #!dist
	SEP #$20
	STA !E4,x
	XBA
	STA !14E0,x
	BRA .skip
  .checkLeft
	CMP #!leftEdge
	BPL .skip
	CLC : ADC #!dist
	SEP #$20
	STA !E4,x
	XBA
	STA !14E0,x
  .skip
	SEP #$20
	DEX
	BPL .loop
	RTS