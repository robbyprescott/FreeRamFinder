; COURSE CLEAR text uses palette colors 19 and 1B, 

org $05CC66   ; No random one-up after goal tape
db $80,$1C   ;  Looks like this can accidentally happen if you nuke status bar

org $05CC42	;\ Remove all numbers and symbols
NOP #31		;/

org $05CD51   ; Remove more BONUS stuff, multiplication?
db $FC,$FC
db $FC,$FC
db $FC,$FC

org $05CD79   ; Stops calculation and drum-roll
db $80

org $05CDD8   ; Stops calculation and drum-roll
db $80

;org $05CC1A 					;\ Remove MARIO tiles
;db $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC	;/


; Unnecessary stuff now covered by big $05CC42 skip:

 ;org $05CC46   ; No multiplication symbol
;db $FC,$FC

;org $05CC4E
;db $FC,$FC    No multiplication symbol 
;db $FC,$FC
;db $FC,$FC
;db $FC,$FC    No = sign