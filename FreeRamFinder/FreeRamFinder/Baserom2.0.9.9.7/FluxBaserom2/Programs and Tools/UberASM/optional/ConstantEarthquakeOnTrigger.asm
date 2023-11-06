; Will start shaking at level load, only stopping when trigger is turned off.
; Revision of BlueToad's UberASM by SJandCharlieTheCat


!StartWithEarthquakeUntilTurnOff = 0 ; If not 1, will only start when you toggle trigger
!Trigger = $14AF        ; On/off
!Shake = $1F		    ; Duration and frequency.
                        ; Needs to be low to be able to promptly flip on and off
!SoundEffect = $21      ; Low rumbling. Set to $FF to disable.
!SoundBank = $1DF9      ; The sound bank of the effect.
!FreeRAM = $0E84		


init:
    STZ !FreeRAM
	if !StartWithEarthquakeUntilTurnOff
	LDA #$FF            ; Ensures that earthquake starts
	STA $1887           ; immediately on level load.
	endif
    RTL

main:
    if !StartWithEarthquakeUntilTurnOff
	LDA !Trigger        ; Will only be turned off
    BNE	Return2         ; when trigger turned off.
	else
	LDA !Trigger        ; Will only be turned on
    BEQ	Return2         ; when trigger turned on.
	endif
	LDA $9D             ; Or death/pause.
	ORA $13D4
	BNE Return2
	INC !FreeRAM
    LDA !FreeRAM
    CMP #!Shake
    BNE +
    STZ !FreeRAM        ; Kill FreeRAM too.
    +
    BNE Return2
    LDA #!Shake
    STA $1887
    LDA #!SoundEffect
    STA !SoundBank
    Return2:
    RTL
