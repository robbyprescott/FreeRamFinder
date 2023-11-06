!ValueToStartWith = $05
!FreeRAM = $0E52 ; $0DBF, coin

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
    LDA #!ValueToStartWith
	STA !FreeRAM
    rtl

main:
    %call_library(FireballUseLimit_main)
	LDA !FreeRAM ; will display this address' value
	JSL ThreeDigitCounter_main
    rtl