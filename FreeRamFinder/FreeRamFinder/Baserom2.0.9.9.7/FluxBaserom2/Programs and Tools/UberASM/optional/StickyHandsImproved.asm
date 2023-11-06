; Better Sticky Hands, WIP by SJC

; This allows you to spawn in a level automatically carrying the item, without having to grab it first.
; To do this, take the sprite you want Mario to hold and place it directly on top of Mario's LOWER HALF.
; (If you place it on his upper half, sometimes it won't work properly.)

; Unlike the original, this Uber also prevents you from the dropping the item when you get a powerup.

; Note that because this forces a Y hold, you'll always have that added speed, etc.
; Also don't use DisableScreenShake immediately at level load if you use this

; $00D0AD Mario fireball

init:
LDA #$01
STA $18BD ; single Mario stunned frame upon spawn (won't affect you)
RTL

main: 
LDA $18BD ; check if Mario stunned (per init)
ORA $71 ; freeze check, e.g. during powerup animation
BEQ Sticky
LDA #$40 
TSB $15 ; force Y, which obviously forces item hold

Sticky:
LDA $1470 ; item carry checks
ORA $148F
BEQ Return

LDA #$40 ; force Y: don't allow you to let go of item if carrying
TSB $15

;LDA $15
;AND #$40
;BNE Return

Return:
RTL