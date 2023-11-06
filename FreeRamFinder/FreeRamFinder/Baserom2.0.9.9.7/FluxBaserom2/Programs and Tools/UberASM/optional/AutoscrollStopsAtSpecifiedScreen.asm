!ScreenNumber = $03

main:
LDA $1B
CMP #!ScreenNumber ; screen number
BCC .NoStop
STZ $143E
STZ $143F
.NoStop
RTL