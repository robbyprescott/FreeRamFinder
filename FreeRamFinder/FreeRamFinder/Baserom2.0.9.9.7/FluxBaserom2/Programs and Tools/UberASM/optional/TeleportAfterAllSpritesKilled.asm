; Code which teleports the player to a specified level when all sprites are killed.
; Can rework this to add exception, like $B9

!FirstException = $B9 ; message box
!TeleportToNextLevel = 1  ; If you set this to 1, will
                          ; simply teleport you to next level 
						  ; up from the current level number
!LevelToTeleportTo = $103 ; (If not using TeleportToNextLevel)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
LDX.b #!sprite_slots-1
- LDA !14C8,x
BNE .ret
DEX
BPL -

REP #$20 
if !TeleportToNextLevel
LDA $010B
INC ; Change to DEC to teleport to the level BEFORE current one
else       
LDA #!LevelToTeleportTo
endif
PHX
PHY
PHA
STZ $88
SEP #$30
JSL $03BCDC|!bank ; EXLEVEL
PLA
STA $19B8|!addr,x
PLA
ORA #$04
STA $19D8|!addr,x
LDA #$06
STA $71
PLY
PLX

.ret
RTL