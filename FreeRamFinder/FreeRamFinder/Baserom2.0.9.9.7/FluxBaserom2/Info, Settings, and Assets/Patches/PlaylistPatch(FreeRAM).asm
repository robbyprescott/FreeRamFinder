; 

; freeram must match the address in the uberasm file and
; should not be cleared on level load but should be cleared on overworld load.
; 2 bytes, byte 1 is flag/index, byte 2 is song number
!freeram = $1926		

lorom
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	
if read1($00FFD5) == $23
	sa1rom
	!addr = $6000
	!bank = $000000
	!sa1 = 1
endif

org $009738						; some smw routine that loads songs, it was causing an issue 
autoclean JML check_playlist	; where the song would reset back to the one chosen in Lunar Magic each death

freecode
check_playlist:
	PHA							; A contains the song level. Save it or we won't get music in any level
	LDA !freeram|!addr			;\ if our flag is not set
	BEQ .return					;| no need to do anything
	LDA !freeram+1|!addr		;| otherwise load up the song 
	STA $1DFB|!addr				;| play it
	PLA							;| 
	JML $00973D|!bank			;/ 
.return
	PLA							;\ 
	STA $1DFB|!addr				;| 
	JML $00973D|!bank			;/
