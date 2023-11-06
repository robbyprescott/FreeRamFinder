; Normally, when you get a 1-up, there's a slight delay before it makes the 1-up sound.
; If you get a lot of 1-ups quickly in a row, this sound delay can add up, and it'll go on forever.
; This removes any delay. Note that this can be somewhat awkward when you get a moon. 

load:
LDA #$01
STA $0E0C
RTL