; Will not only switch to new song when midway is gotten,
; but will KEEP playing after reset

!song = #$12
!freeRAM = $1926 ; same as PlaylistPatch	

main:
LDA $13CE ; check if midway is gotten
BEQ Return
INC !freeRAM
LDX !freeRAM			;\ load the song
LDA !song
STA $1DFB|!addr			;| put it in music slot
STA !freeRAM+1			;/
Return:
RTL