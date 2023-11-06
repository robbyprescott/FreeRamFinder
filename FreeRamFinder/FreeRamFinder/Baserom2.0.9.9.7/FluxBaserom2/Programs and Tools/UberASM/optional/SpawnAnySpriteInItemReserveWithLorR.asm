; By SJandCharlieTheCat
; Works with two or three different patches, already applied

!SpriteValue = $0D ; key, see Default Item Box Values in documentation for conversion values. 
!SpriteStatus = $0DF5 ; match below
!DropIfYouTakeDamage = 0 ; item falls down when you take damage as big Mario

; $0DF4 = 1 Initialise
; $0DF5 = 9 Carryable, flipped, stunned
; $0DF6 = A Kicked
; $0DF7 = B Carried

main:
if !DropIfYouTakeDamage
LDA #$01
STA $0DF8 ; FreeRAM
endif
LDA #$01
STA !SpriteStatus
LDA $9D
ORA $13D4         ; Freeze checks
BNE Return 
LDA $18
AND #$30 ; #$20 is L, #$10 is R
BEQ Return 
LDA #!SpriteValue  
STA $0DC2 
LDA #$10 ; magikoopa	
STA $1DF9
Return:
RTL
   