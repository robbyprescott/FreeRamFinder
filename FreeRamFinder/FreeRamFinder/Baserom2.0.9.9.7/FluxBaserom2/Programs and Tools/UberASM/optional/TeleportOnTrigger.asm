!Trigger = $14AF
!TeleportToNextLevel = 1  ; If you set this to 1, will
                          ; simply teleport you to next level 
						  ; up from the current level number
!LevelToTeleportTo = $103 ; (If not using TeleportToNextLevel)

main:
LDA !Trigger
BEQ End
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
End:
RTL


; Won't need the actual EXLEVEL versional check,
; because it's not 2019.

;macro assert_lm_version(version, define)
;    !lm_version #= ((read1($0FF0B4)-'0')*100)+((read1($0FF0B6)-'0')*10)+(read1($0FF0B7)-'0')
;    if !lm_version >= <version>
;        !<define> = 1
;    else
;        !<define> = 0
;    endif
;endmacro

;%assert_lm_version(257, "EXLEVEL") ; Ex level support