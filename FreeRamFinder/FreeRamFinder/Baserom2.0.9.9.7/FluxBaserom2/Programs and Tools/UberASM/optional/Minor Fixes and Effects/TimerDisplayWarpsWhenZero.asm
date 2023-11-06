; Make sure TimerDisplayWarpsWhenZero_Lib is in Library

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
%call_library(TimerDisplayWarpsWhenZero_Lib_init)
    rtl

main:
%call_library(TimerDisplayWarpsWhenZero_Lib_main)
    rtl
	
nmi:
%call_library(TimerDisplayWarpsWhenZero_Lib_nmi)
    rtl
	
	