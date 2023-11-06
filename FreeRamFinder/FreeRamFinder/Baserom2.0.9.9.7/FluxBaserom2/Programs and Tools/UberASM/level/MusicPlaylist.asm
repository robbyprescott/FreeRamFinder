macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
;%call_library(_init)
    rtl

main:
%call_library(PlaylistDisplay_main)
%call_library(PlaylistFunction_main)
    rtl

	
	