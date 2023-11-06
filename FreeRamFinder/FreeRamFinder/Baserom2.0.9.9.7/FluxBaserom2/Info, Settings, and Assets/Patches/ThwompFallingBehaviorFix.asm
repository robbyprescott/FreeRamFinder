;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Thwomp Sprite Fix by Davros & Lui37.
;;
;; Fixes various glitches in which the Thwomp doesn't check the high byte of the initial
;; position, the proximity range of the sprite and the object clipping field when it comes
;; in contact with the ground from the right side.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!D8 = $D8
!151C = $151C
!14D4 = $14D4
!1510 = $1510
!14E0 = $14E0
!E4 = $E4
!1588 = $1588
!1656 = $1656
!basef = $800000

if read1($00FFD5) == $23
sa1rom
!D8 = $3216
!151C = $3284
!14D4 = $3258
!1510 = $750A
!14E0 = $326E
!E4 = $322C
!1588 = $334A
!1656 = $75D0
!basef = $000000
endif

	!HORZ_RANGE1 = $0040    ; max X distance of Mario for attack
	!HORZ_RANGE2 = $0024    ; max X distance of Mario for attack

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Init Position code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01AE96

	autoclean JML InitPositionFix		; go to new routine
	NOP									; cancel out routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Proximity Range code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01AEC6
	BNE Return              ; repoint to return

org $01AED7
	BRA Skip                ; skip routine
	NOP                     ; cancel out routine
Skip:
	autoclean JSL ProximityRange1     ; go to new routine

org $01AEE5
	BRA Skip2               ; skip routine
	NOP                     ; cancel out routine
Skip2:
	autoclean JSL ProximityRange2     ; go to new routine

org $01AEF9
Return:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Ground Detection code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01AF0A
	autoclean JML CheckGround			; go to new routine
	NOP									; cancel out routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Position Check code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $01AF2C
	autoclean JML InitPositionCheck		; go to new routine
	NOP									; cancel out routine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Init Position fix code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	freecode
	reset bytes

	print "Code is located at: $", pc

InitPositionFix:
	LDA !D8,x               ; \ store y position (low byte)
	STA !151C,x             ; /
	LDA !14D4,x             ; \ store y position (high byte)
	STA !1510,x             ; /
	JML $01AE9B|!basef		; return to original routine

InitPositionCheck:
	LDA !D8,x               ; \ check y position (low byte)
	CMP !151C,x             ;  |
	BNE Rise                ; /
	LDA !14D4,x             ; \ check y position (high byte)
	CMP !1510,x             ;  |
	BNE Rise                ; /
	JML $01AF33|!basef		; return to original routine

Rise:
	JML $01AF38|!basef		; return to original routine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Proximity Range fix code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProximityRange1:
	REP #$20                ; \ set horizontal range
	LDA #!HORZ_RANGE1       ;  |
	BRA Store_Value         ; /

ProximityRange2:
	REP #$20                ; \ set horizontal range
	LDA #!HORZ_RANGE2       ;  |
Store_Value:				;  |
	STA $0C                 ;  | store value in temp ram
	SEP #$20                ; /

Horz_Proximity:
	LDA !14E0,x             ; \ if Mario is near the sprite...
	XBA                     ;  |
	LDA !E4,x               ;  |
	REP #$20                ;  |
	SEC                     ;  |
	SBC $94                 ;  |
	BPL H_Result_Is_Plus    ;  |
	EOR #$FFFF              ;  |
	INC	                    ;  |
H_Result_Is_Plus:			;  |
	CMP $0C                 ;  | compare value of temp ram
	SEP #$20                ;  |
	RTL                     ; / return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thwomp Ground Detection fix code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckGround:
	LDA !1588,x             ; \ if on the ground...
	AND #$04                ;  |
	BNE On_Ground           ; /

	LDA !1656,x             ; \ preserve object clipping field
	PHA                     ; /
	ORA #$07                ; \ set object clipping field
	STA !1656,x             ; /
	JSL $019138|!basef		; interact with objects
	PLA                     ; \ restore object clipping field
	STA !1656,x             ; /

	LDA !1588,x             ; \ if on the ground...
	AND #$04                ;  |
	BNE On_Ground           ; /
	JML $01AF23|!basef		; return to original routine

On_Ground:
	JML $01AF0F|!basef		; return to original routine


print "Freespace used: ",bytes," bytes."
