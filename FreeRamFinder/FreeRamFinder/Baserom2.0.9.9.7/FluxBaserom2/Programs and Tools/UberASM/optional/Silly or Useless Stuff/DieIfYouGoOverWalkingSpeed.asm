; ; Max X speeds ($7B) are 49/37/21 for sprinting, running, and walking respectively. 

;!MinSpeed = $30
;!MaxSpeed = $10


!MaxLeft = $DE			;\ DE is equivalent to 21, maximum "walking" speed before run
!MaxRight = $21			;/maximum speeds for left and right. 49/37/21 for sprinting, running, and walking 

main:
LDA $7B				;check speed
BPL .right			;if going right, check right

.left
CMP #!MaxLeft		;if below max ($DE)
BPL .re				;return
BRA .set			;

.right
CMP #!MaxRight			;if it's not max
BMI .re				;return

.set
JSL $00F606

.re
RTL				;