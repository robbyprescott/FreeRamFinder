; Put other ScoreOnly file in Library
; Use in conjunction with layer 3 file ExGFX328, which you put in LG1 slot.


; Be sure to include pointers to any other codes you need for the level, too

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
load:
%call_library(ScoreOnly_LibraryFile_load)
    rtl	

init:
%call_library(ScoreOnly_LibraryFile_init)
    rtl

main:
%call_library(ScoreOnly_LibraryFile_main)
    rtl

nmi:
%call_library(ScoreOnly_LibraryFile_nmi)
    rtl
	