; When you use this, make sure you put both HPSystemForSmallMarioLibrary
; AND HPSystemOrLifeCounterLibrary in the Library folder

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
load:
%call_library(HPSystemForSmallMarioLibrary_load)
    rtl		
	
init:
%call_library(HPSystemOrLifeCounterLibrary_init)
    rtl

main:
%call_library(HPSystemOrLifeCounterLibrary_main)
%call_library(HPSystemForSmallMarioLibrary_main)
    rtl

