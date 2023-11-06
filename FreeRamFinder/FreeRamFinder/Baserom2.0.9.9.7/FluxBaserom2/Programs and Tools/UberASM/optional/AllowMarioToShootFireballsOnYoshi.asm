; By SJC, adapted from code by JamesD28
; All this code does is  temporarily sets $141E (allows Mario to shoot fireballs even when on Yoshi)
; and opens Yoshi's mouth when you press Y or X when on him.

!AllowEvenWhenNotFireMario = 1 ; If set to 1, will be able to shoot fireballs any time you're on Yoshi,
                               ; and not just when you have a fire powerup. 
                             
main:
;LDX $15E9|!addr
if !AllowEvenWhenNotFireMario = 0
LDA $19
CMP #$03
BEQ .End
endif
LDA $187A|!addr			;/
BEQ .End				;\ Return if not on Yoshi.
LDA $16					;/
ORA $18					;|
AND #$40				;| If X or Y hasn't just been pressed, don't fire a shot.
BEQ .End				;\

STZ $14A3|!addr			; Zero the timer that changes Mario's pose for hitting Yoshi. Note that the pose will still appear for a frame, but this usually isn't noticeable.

LDX $18E2|!addr
LDY !157C-1,x			;/

JSR EnableMarioFireball	; Shoot fireball.

LDA #$10				;/
STA !1558-1,x			;|	
LDA #$03				;| Set Yoshi's mouth to the spitting phase.
STA !1594-1,x			;\

LDX $15E9|!addr

.End
RTL

EnableMarioFireball:
LDA #$01
STA $141E|!addr ; enable fireball even when small Mario
RTS