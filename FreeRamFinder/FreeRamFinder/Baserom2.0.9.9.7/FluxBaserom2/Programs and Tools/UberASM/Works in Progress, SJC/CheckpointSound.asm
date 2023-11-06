; However, will play midway sound again if you exit level and re-enter

init:
LDA $192C ; not reset level load
BNE Return
LDA #$05
STA $1DF9
LDA #$01
STA $192C
Return:
RTL