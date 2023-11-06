 ; Note that this won't even bring up retry prompt
 ; and if you die to sprite, weird physics after transition

!SentBackToCurrentLevelNumberMinusOne = 1 ; otherwise FORWARD one level

main:
LDA $71
CMP #$09
BNE Return

  REP #$20
  LDA $010B
  if !SentBackToCurrentLevelNumberMinusOne
  DEC
  else
  INC
  endif
  JSL TeleportYee
Return:
  RTL
  
TeleportYee:
	PHX
	PHY
	PHA
	STZ $88
	SEP #$30
	JSL $03BCDC ; |!bank
	PLA
	STA $19B8|!addr,x
	PLA
	ORA #$04
	STA $19D8|!addr,x
	LDA #$06
	STA $71
	PLY
	PLX
	RTL
