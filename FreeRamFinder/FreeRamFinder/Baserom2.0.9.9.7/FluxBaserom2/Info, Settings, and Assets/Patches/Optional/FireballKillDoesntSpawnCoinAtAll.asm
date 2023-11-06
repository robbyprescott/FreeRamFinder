; SJC: I made an Uber version of this

; Don't patch this if you're patching FireballKillTurnsIntoNon-MovingCoin.asm
; https://www.smwcentral.net/?p=section&a=details&id=18548

;Ignore the comments, they're left over from the old version and have been moved around a bit.

!XSpeedRight = $10	; Speed for dead sprite, facing right. Used as a base to calculate the speed going left.
!XSpeedLeft = !XSpeedRight^$FF+$01 ; 2's complement. Do not edit unless you know what you are doing.
!Score = $05 ; Changing this will change the amount of score you get (1=10,2=20,3=40,4=80,5=100,6=200,7=400,8=800,9=1000,A=2000,B=4000,C=8000,D=1up)

lorom
!addr = $0000
!B6 = $B6		; don't need a SA-1 define, because this address doesn't change.
!14C8 = $14C8
!bank = $800000

if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!14C8 = $3242
	!bank = $000000
endif

org $02A129
LDA #$02    ; / Make sprite fall down...
STA !14C8,x ; \ ... or disappear in smoke (depends on its settings)
autoclean JSL Mycode
JSL $02ACEF|!bank ; Jump to the score routine handler.


freecode

Mycode:
LDY $185E|!addr
LDA $1747|!addr,y
BMI +
LDA #!XSpeedRight
BRA ++
+
LDA #!XSpeedLeft
++
STA !B6,x
LDA #!Score
RTL