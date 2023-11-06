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
  BEQ .DoThis

.Next
  DEX
  BPL .Loop
  RTL

.DoThis
  LDA #$BA : STA $173D,x
  BRA .Next
endif