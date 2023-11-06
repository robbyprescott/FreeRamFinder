print "This block will not only change the music to the next song (or a defined song) when you touch it, but if used in conjunction with the ChangeMusicOnRAMTrigger Uber, will KEEP playing the new song after you've changed it, even after death/retry (whereas it normally will revert to the level's main song)."

; However, if you start+select out and reenter the level after changing, it will revert to the original song. 
; (Add midway check, or use RAM that's not reset on OW load?)

db $42

!KeepPlayingSongOnReset = 1
!NoResetRAM = $1926 
!song = 0    ; If you want to change to a specific song number, put the number like so: $12 or $18, etc. 
             ; Match this in ChangeMusicOnRAMTrigger Uber if you use midway music change

JMP Mario : JMP Mario : JMP Mario
JMP Nothing : JMP Nothing
JMP Nothing : JMP Nothing
JMP Mario : JMP Mario : JMP Mario

Mario:
    if !KeepPlayingSongOnReset 
    LDA #$01
	STA !NoResetRAM 
	endif
	if !song = 0
	INC $1DFB ; DEC to song BEFORE this
	else
	LDA !#song				; \ Change This to the song that you want to change
	STA $1DFB				; /
	endif
	%erase_block()
Nothing:
RTL