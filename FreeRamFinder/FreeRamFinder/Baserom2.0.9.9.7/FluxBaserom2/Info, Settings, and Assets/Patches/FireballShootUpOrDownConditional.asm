; By kevin, modified by Fernap and SJC

!yspeedup = $A0 ; $80 is faster upward.
!yspeeddown = $40 ; $60 is faster downward
!FreeRAM = $0DFD 

if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !bank = $000000
else
    lorom
    !addr = $0000
    !bank = $800000
endif

!extended_x_speed = $1747|!addr
!extended_y_speed = $173D|!addr

org $00FEC4
autoclean JML InitSpeed
NOP

freedata
InitSpeed:

    LDA !FreeRAM
	BEQ .normal
    LDA $15
    AND #%00001000
    BEQ .checkdown
    LDA.b #!yspeedup
	BRA .shared
.checkdown
    LDA $15
	AND #%00000100 ; holding down
	BEQ .normal
	LDA #!yspeeddown	
.shared	
    STA !extended_y_speed,x
    STZ !extended_x_speed,x
    LDY $76
    JML $00FED1|!bank

.normal
    LDA #$30
    STA !extended_y_speed,x
    JML $00FEC9|!bank