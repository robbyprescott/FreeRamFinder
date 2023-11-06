!MoreFireballs = 1			;if you're using a patch that allows more fireballs, turn this on

main:
;vanilla fireballs in hardcoded slots
if not(!MoreFireballs)
  STZ $1746|!addr			;no y-speed for fireballs
  STZ $1745|!addr

  STZ $175A|!addr			;fraction bits also
  STZ $1759|!addr
  RTL

;fireballs in any slots
else
  LDX #$09

.Loop
  LDA $170B|!addr,x
  CMP #$05				;check if it's Mario's fireball
  BEQ .Yes

.Next
  DEX
  BPL .Loop
  RTL

.Yes
  STZ $173D|!addr,x			;speed = 0
  STZ $1751|!addr,x			;fraction = 0
  BRA .Next
endif