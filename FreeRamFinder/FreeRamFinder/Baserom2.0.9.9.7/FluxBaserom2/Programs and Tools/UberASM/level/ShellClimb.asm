macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
;init:
;%call_library(UberFileOne_init)
    ;rtl

main:
%call_library(OnlyScrollOneDirection_main)
%call_library(ShellJumpAutoRegrab_main)
    rtl
