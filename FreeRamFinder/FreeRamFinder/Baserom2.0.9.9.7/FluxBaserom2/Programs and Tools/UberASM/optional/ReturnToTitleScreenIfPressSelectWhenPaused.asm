; by SJC

!FreeRAM = $0E07

init:
lda #$01
sta !FreeRAM 
rtl

main:
lda $13d4 : beq +
LDA $16				;check if controller button is newly pressed.
AND #$20			; Select button
BEQ +
LDA #$02 ; 03 is instant title
STA $0100 ; game mode
+
rtl