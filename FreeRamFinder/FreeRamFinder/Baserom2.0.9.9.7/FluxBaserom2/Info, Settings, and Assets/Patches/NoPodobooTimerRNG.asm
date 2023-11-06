; Removes RNG from the vertical fireball sprite

!Timer = $7F

if read1($00FFD5) == $23
	sa1rom
endif

org $01E0D7
	LDA #!Timer
	NOP #6