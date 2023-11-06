; By SJandCharlieTheCat
; Allows you to drop any sprite in (almost) any desirable sprite state in item box

!FreeRAM = $0DF4 ; uses four bytes, $0DF4 - $0DF7
!14C8 = $14C8

org $028042
autoclean JSL ItemDropSpriteStatus
NOP

freecode

ItemDropSpriteStatus:
LDA !FreeRAM
BEQ Stunned
LDA #$01 ; init               
STA !14C8,x
BRA Return 
Stunned:
LDA !FreeRAM+1
BEQ Kicked
LDA #$09               
STA !14C8,x
BRA Return 
Kicked:  
LDA !FreeRAM+2
BEQ Carried
LDA #$0A               
STA !14C8,x
BRA Return 
Carried: 
LDA !FreeRAM+3
BEQ Normal
LDA #$0B               
STA !14C8,x
BRA Return    
Normal:
LDA #$08                
STA !14C8,x  
Return:
RTL
