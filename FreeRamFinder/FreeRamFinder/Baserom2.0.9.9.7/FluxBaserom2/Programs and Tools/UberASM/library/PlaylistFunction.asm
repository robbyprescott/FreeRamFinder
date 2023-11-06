; by binavik

; All of the songs you wish to use from AddMusicK's list.txt
; The very first song should be the levels selected song from Lunar Magic.
; Other than the first song, order doesn't matter. Max amount of songs allowed is 127.
songs: db $2A,$2B,$2C,$2D,$2E,$2F,$30,$31

; freeram should match address in the asar file and
; should not be cleared on level load but should be cleared on overworld load.
; 2 bytes, first for index/flag 2nd for actual song number
!freeRAM = $1926|!addr		
!BlockFreeRAM = $14AF ; match Uber		

; don't change this
!total_songs = #(main-songs-1)

main:
	LDA $9D
	ORA $13D4|!addr
	BNE .return
	LDA !BlockFreeRAM		;\ If RAM not set
	BEQ .return				;/ don't run this code
	LDA $18					;\ 
	AND #%00100000			;| check if L is pressed
	BNE .decrease			;/
	LDA $18					;\ 
	AND #%00010000			;| check if R is pressed
	BNE .increase			;/
	RTL

.increase
	INC !freeRAM			;\ 
	LDA !freeRAM			;| increase the index
	CMP.b !total_songs+1	;| and check if we are over the total number of songs
	BMI .changeSong			;| branch if we are not
	STZ !freeRAM			;| reset to the 0th index if we are
	BRA .changeSong			;/
.decrease
	DEC !freeRAM			; same as above but in reverse 
	LDA !freeRAM
	BPL .changeSong			; 
	LDA.b !total_songs
	STA !freeRAM
.changeSong
	LDX !freeRAM			;\ load the song
	LDA songs,x				;|
	STA $1DFB|!addr			;| put it in music slot
	STA !freeRAM+1			;/
.return
	RTL
	
	