;Fixes a small oversight that makes exiting horizontal pipes not play sound effect, unlike vertical ones.
;By RussianMan. Credit is optional. Requested by Blizzard Buffalo. 

lorom

if read1($00FFD5) == $23
sa1rom
endif

org $00D24E
;it seems like when player exits a horz pipe the speed is set from first frame, unlike vertical pipe which doesn't.
;that's a speculation though, i'm still a little confused on how this works

autoclean JSL PlayOrDont

freecode

PlayOrDont:
LDA $89			;check pipe exiting/entering index
TAX
CMP #$04		;if less than 4, that's entering a pipe, always plays a sound
BCC .Default

;LDA $89
;CMP #$06

CPX #$06		;if 6 or more, that's exiting vertical pipe. nothing to fix here.
BCS .Default

;exiting horz pipe: values 04 and 05

;LDA $7B
LDA $88			;instead of checking speed, check timer and play at specific value.
CMP #$18		;
RTL

.Default
LDA $7B			;check speed, horizontal
ORA $7D			;or vertical
RTL