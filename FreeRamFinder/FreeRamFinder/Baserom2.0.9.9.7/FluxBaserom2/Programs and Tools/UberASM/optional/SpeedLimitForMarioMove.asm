; Horizontal speed limit
; This code makes it so player can only walk or run at a certain speed.
; by RussianMan, credit is unecessary.

!MaxLeft = $DE			;\ DE is equivalent to 21, maximum "walking" speed before run
!MaxRight = $21			;/maximum speeds for left and right. 49/37/21 for sprinting, running, and walking 

main:
LDA $7B				;check speed
BPL .right			;if going right, check right

.left
CMP #!MaxLeft			;if it isn't max yet
BPL Return				;return
LDA #!MaxLeft			;otherwise it has hit max, no running
BRA .set			;

.right
CMP #!MaxRight			;if it's not max
BMI Return				;return

.nomore
LDA #!MaxRight			;no more than this

.set
STA $7B				;no run

Return:
RTL				;