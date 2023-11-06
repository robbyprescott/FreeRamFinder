;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Yoshi Coin Fix, by imamelia
;;
;; This patch fixes two glitches with the Yoshi coin:
;;
;; 1) You can now place the coins on subscreen boundaries.
;; 2) You can now make Map16 tiles on other pages act like the Yoshi coin tiles.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lorom
!addr = $0000
!long = $800000
if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!long = $000000
endif


org $00F332
CPY #$2D
BCC $31
PHY
JSL $00F377|!long
INC $1422|!addr
LDA $1422|!addr
CMP #$05
BCC $0B
PHX
JSR $F3B2
ORA $1F2F|!addr,y
STA $1F2F|!addr,y
PLX
LDA #$1C
STA $1DF9|!addr
LDA #$01
JSL $05B330|!long
LDA #$01
STA $9C
JSL $00BEB0|!long
autoclean JML NewGen

freecode
reset bytes

NewGen:
LDA #$01
STA $9C
JSL $00BEB0|!long
PLY
REP #$20
LDA $98
CPY #$2D
BNE .NotTopTile
CLC
ADC.w #$0010
BRA .SetY
.NotTopTile
SEC
SBC.w #$0010
.SetY
STA $98
SEP #$20
LDA #$01
STA $9C
JSL $00BEB0|!long
JML $00F373|!long

print "Freespace used: ",bytes," bytes."
