; Hacky way to make a counter for something. Currently DECREMENTS value when you use fireball or cape swing.
; There's also a patch version of the latter: https://www.smwcentral.net/?p=section&a=details&id=29800
 
; Just make sure no other SFX will eat your sound, I guess.
; See here for SFX values: https://www.smwcentral.net/?p=viewthread&t=6665 

!Decrement = 1 ; change to 0 to increment instead
!AddressToSet = $0E52 ; $13CC, coin count

Print "INIT ",pc
Print "MAIN ",pc

LDA $1DF9|!addr
CMP #$09 ; cape
BNE +
BRA .ThingToDo
+
LDA $1DFC|!addr
CMP #$06 ; fireball
BNE .Ret
.ThingToDo
if !Decrement
DEC !AddressToSet ; or DEC, or LDA, etc. 
else
INC !AddressToSet
endif
.Ret
RTL