;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This patch fixes berry interaction in vertical and Layer 2 levels.
;;
;; Note that this doesn't account for non-constant Layer 2 scrolling,
;;  so that will still have strange results.
;;
;; Coded by kaizoman/Thomas, no credit necessary.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!berryLayer		=	!1510,x
	; Some RAM address to track the layer of a berry when touched by Yoshi's mouth.
	;  (can be static or X indexed like this one, either is fine)
	; The default address here should work without any conflicts,
	;  unless you messed with Yoshi's code using another patch.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!base2	= $0000
!1510	= $1510

if read1($00FFD5) == $23
	sa1rom
	!base2	= $6000
	!14E0	= $326E
	!1510	= $750A
endif

org $02B9FA
	autoclean JML TongueFix

org $02D0E1
	JSL MouthFix
	PLB
  SkipMouthHijack:
	RTL
org $02D0D7
	BNE SkipMouthHijack
org $02D0DC
	BPL SkipMouthHijack
org $02D148
	RTL
org $02D1F0
	RTL
org $02D1EC
	JSL MouthFix2

org $02D0ED
	JSL MouthFixA
org $02D0FC
	JSL MouthFixB
org $02D108
	JSL MouthFixC
	NOP
org $02D117
	JSL MouthFixD

org $02D20B
	JSL MouthTileGenFix

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode
;; Fix interaction for Yoshi's tongue and baby Yoshi.
TongueFix:
	STZ $0F
	LDA $5B
  .loop
	LSR
	PHA
	BCS .vLayer
	JSL $02BA48
	BRA .doneLayer
  .vLayer
	JSL $02B9FE
  .doneLayer
	PLA
	LDY $0F
	INY
	CPY #$02
	BEQ .done
	STY $1933|!base2
	STY $0F
	LDY $5B
	BMI .loop
  .done
	STZ $1933|!base2
	RTL


;; Fix interaction for Yoshi's head.
MouthFix:
	STZ $0F
	LDA $5B
  .loop
	LSR
	PHA
	BCS .vLayer
	JSL $02D149
	BRA .doneLayer
  .vLayer
	JSL $02D0EA
  .doneLayer
	PLA
	LDY $0F
	INY
	CPY #$02
	BEQ .done
	STY $0F
	LDY $5B
	BMI .loop
  .done
	RTL

;; More fixing for Yoshi's head.
MouthFix2:
	ADC #$00
	STA $97
	LDA $0F
	STA !berryLayer
	RTL

;; And a few more because this routine is lacking some lines.
MouthFixA:
	ADC #$08
	STA $18B2|!base2
	AND #$F0
	RTL
MouthFixB:
	STA $18B3|!base2
	STA $03
	AND #$10
	RTL
MouthFixC:
	ADC $D0D0,Y
	STA $18B0|!base2
	STA $01
	RTL
MouthFixD:
	STA $18B1|!base2
	STA $02
	LDA $01
	RTL


;; Fix tile generation for Yoshi's head.
MouthTileGenFix:
	LDA !berryLayer
	STA $1933|!base2
	JSL $00BEB0
	STZ $1933|!base2
	STZ !berryLayer
	RTL