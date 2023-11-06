!WallRunEnabled = 1		;Lets you enter pipe while wall running
!MaxVertSpeed = $00		;Maximum vertical speed to enter, 0 = no limit
						;If wall running speed is ignored
						;will not work with negative value, keep it positive

!SoundID = $04
!SoundBank = $1DF9

db $37
JMP Exit : JMP Exit : JMP MarioSide
JMP Exit : JMP Exit : JMP Exit : JMP Exit
JMP Exit : JMP Exit : JMP Exit
JMP WallFeet : JMP Exit


WallFeet:

if !WallRunEnabled == 0		;If wall running not enabled just exit
	RTL
endif

MarioSide:

PHY
LDA $15					;Check if pressing left or right
LDY $93
BEQ .LeftFace
AND #$02
BRA .Compare
.LeftFace
AND #$01
.Compare
BEQ .Return

if !WallRunEnabled == 1		;If wall running enabled and currently wall running don't check speed and enter pipe
	LDA $13E3|!addr
	STZ $13E3|!addr
	BNE .EnterPipe
endif
if !MaxVertSpeed != $00		;If max speed enabled check if not too fast
	LDA $7D
	BPL .noInvert
	EOR #$FF : INC
	.noInvert
	CMP #!MaxVertSpeed
	BCS .Return
endif

.EnterPipe
LDA #$05 : STA $71					;Enter pipe trigger
LDA #$30 : STA $88					;Enter pipe timer
TYA : EOR #$01 : STA $89		;Pipe facing for animation
LDY $148F|!addr : BEQ .SetMarioFacing		;If holding item
EOR #$01							;Invert Mario's direction
LDY #$08 : STY $1499|!addr			;Face camera for turn around effect
.SetMarioFacing
STA $76
LDA #$01 : STA $1419|!addr : STA $9D	;Set Yoshi pipe enter animation and lock sprites
LDA #!SoundID : STA !SoundBank|!addr	;Play sound

.Return
PLY
Exit:
RTL

print "A vanilla horizontal exit pipe, except that you can enter it while in midair (you don't need to be standing on anything solid)."