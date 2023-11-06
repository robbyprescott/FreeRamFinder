; The effect of side exits carries over if you transition to a sublevel from the main level
; that the side exit is placed in. This simple Uber will stop that, if it's enabled for the
; sublevel that you don't want this to happen in.

init:
	STZ $1B96
	RTL