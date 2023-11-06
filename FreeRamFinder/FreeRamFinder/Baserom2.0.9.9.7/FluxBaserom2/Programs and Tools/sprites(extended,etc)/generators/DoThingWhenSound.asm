; You can use this to make a hacky jump counter, even when you get a frame perfect jump.
; Just make sure no other SFX will eat your jump/spin sound, I guess.
; See here for SFX values: https://www.smwcentral.net/?p=viewthread&t=6665 

!AddressToSet = $13CC ; $13CC, coin count

Print "INIT ",pc
Print "MAIN ",pc

LDA $1DFC|!addr
CMP #$04 ; spin sound. 
BNE +
BRA .Thing
+
LDA $1DFC|!addr
CMP #$35 ; regular jump sound
BNE .Ret
.Thing
INC !AddressToSet ; or DEC, or LDA, etc. 
.Ret
RTL