; By default, get all five Yoshi coins in a level
; By PermaBan, with edits by SJC


!AddressOrThing = $1420 ; $1420, Yoshi coin
!Value = $05 ; Number of Yoshi coins
!Song = $04 ; default end theme using AMK 

!exit_number = #$00			;Normal exit = 00, Secret exits 1-3 = 01,02,03

main:
    LDA $1493|!addr
    ORA $13C6|!addr			;Don't try to trigger the end again
    BNE return

    LDA !AddressOrThing|!addr
    CMP #!Value
    BCC return        		;Check for 5 or more dragon coins

endlevel:
    LDA #$FF
    STA $1493|!addr			;End level if 5 or more dragon coins
	LDA !exit_number
    STA $141C|!addr			;End level based on exit type
    LDA #!Song
    STA $1DFB|!addr        ;Play goal theme

return:
    RTL