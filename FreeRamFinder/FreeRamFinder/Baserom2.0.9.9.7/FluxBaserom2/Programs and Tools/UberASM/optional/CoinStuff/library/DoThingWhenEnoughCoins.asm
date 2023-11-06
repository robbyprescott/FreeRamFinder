; Will want to use with coin counter Uber

!NumberOfCoins = $02 
!ResetCoinsOnDeath = 1

init:
if !ResetCoinsOnDeath
STZ $0DBF
endif
RTL

main:
LDA $0DBF 
CMP #!NumberOfCoins  
BNE Return
;LDA #$29    ; You need to make sure the thing only happens once, and not every frame
;STA $1DFC
LDA #$01
STA $19
Return:
RTL