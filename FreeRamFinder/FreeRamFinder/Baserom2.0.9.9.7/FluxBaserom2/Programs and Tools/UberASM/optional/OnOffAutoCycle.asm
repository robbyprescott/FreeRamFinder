;Flip on-off switch every X frames

!freeRAM = $0EF3	;2 consecutive bytes of freeRAM
!time = $0078		;Number of frames(hex) between on/off switches
                        ; 3C is 60 frames, or one full second
                        ; 78 is 120 frames
                        ; B4 is 180 frames
                        ; F0 is 240 frames, or four seconds

!DontContinueDuringFreeze = 1 ;Otherwise you might not be able to see how on/off blocks killed you

!sfxplay = 1		;Whether an sfx should be played when the on/off switches. 1=true, 0=false
!sfxbank = $1DF9	;Which bank to play the sound effect from.
!sfxno = $0B		;Which sound effect to play.

!levelend = 0		;Whether the on/off should switch even on end goal march. 1=true, 0=false

init:
REP #$20
STZ !freeRAM
SEP #$20
RTL

main:
LDA $9D
ORA $13D4|!addr
ORA $1426|!addr
if not(!levelend)
	ORA $1493|!addr
endif
BNE return
LDA $71
CMP #$0A
BEQ return


REP #$20
INC !freeRAM|!addr

LDA !freeRAM|!addr
CMP #!time
BNE +
STZ !freeRAM|!addr
+

SEP #$20
BNE return

if !sfxplay
	LDA #!sfxno	
	STA !sfxbank|!addr	
endif

LDA $14AF|!addr	
EOR #$01	
STA $14AF|!addr	

return:
RTL