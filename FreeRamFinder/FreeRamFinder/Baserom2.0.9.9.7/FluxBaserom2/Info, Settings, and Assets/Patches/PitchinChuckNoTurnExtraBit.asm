if read1($00FFD5) == $23
	sa1rom
	!7FAB10 = $6040
	!Bank = $000000
else
	lorom
	!7FAB10 = $7FAB10
	!Bank = $800000
endif

ORG $02C3F5
autoclean JML ChuckCheck

freecode

ChuckCheck:

LDA !7FAB10,x	;/
AND #$04		;| If the extra bit is set, skip over the code that makes the Pitchin' Chuck turn to face Mario.
BNE .NoTurn		;\

LDA $14				;/
AND #$3F			;\ Restore the original code (only turn every 64 frames).
JML $02C3F9|!Bank	; Return to Pitchin' Chuck's routine, and use the branch there to determine if it's time to turn.

.NoTurn
JML $02C3FE|!Bank	; Return to the Pitchin' Chuck's routine without turning.