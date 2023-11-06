lorom

!base = $0000

if read1($00ffd5) == $23
	sa1rom
	!base = $6000
endif

org $00E99C
autoclean JSL SideExitTeleportMain

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

SideExitTeleportMain:
LDA $1B96|!base
CMP #$02
BCC .NormalSideExit
STZ $1B96|!base
LDA #$06
STA $71
STZ $88
STZ $89
RTL

.NormalSideExit
JML $05B160
