main:
LDA $74					;\ If player is climbing
BEQ +					;/
STZ $1407|!addr			;\ Disable flight
RTL