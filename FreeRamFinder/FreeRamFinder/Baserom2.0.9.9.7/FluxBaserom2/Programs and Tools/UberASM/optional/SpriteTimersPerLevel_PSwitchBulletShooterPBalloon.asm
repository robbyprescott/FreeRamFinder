; by dirty!
; modify timers


; Can also set all to $00 for the default timer.


!BillShooter   = $60  ; How often bullet bill shooter fires (defaults to #$60). 
!PBalloon      = $FF  ; How long the P Balloon lasts (defaults to #$FF)
!PSwitch       = $B0  ; How long a PSwitch lasts (defaults to #$B0)

; The timer for bullet bill shooter shooter only decrements every other frame, so the total time between shots is double the value.
; The timer for the P-balloon decrements every fourth frame, and since the default is already $ff, you can only lower it, not raise it.
; The value for the P-switches decrements every fourth frame.


; Empty ram listed inside the Asar patch (change these depending on whats in the main patch)


!BulletBillShooter_RAM    = 	$0EB4|!addr
!PSwitches_RAM            =   	$0EB5|!addr
!PBalloon_RAM             =   	$0EB6|!addr

; you don't have to edit anything below, but you're welcome to if you'd like

init:
LDA #!BillShooter
STA !BulletBillShooter_RAM
LDA #!PBalloon
STA !PBalloon_RAM
LDA #!PSwitch
STA !PSwitches_RAM
RTL
