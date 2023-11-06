; By default, will play another death sound from bank $1DF9.
; If you want to play a sound from bank $1DFC, change !Bank1DFC to 1
; See the list here for all available sounds: https://www.smwcentral.net/?p=viewthread&t=6665

!Sound = $20
!Bank1DFC = 0

load:
if !Bank1DFC
LDA #!Sound
STA $0E1B
else
LDA #!Sound
STA $0E1A
endif
RTL