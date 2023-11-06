; Make sure that the multiple UberASMs you're using are all in the Library folder 
; (and add the name of this one to the level section of list.txt).

; In this example, UberFileOne's code has two labels (init and main),
; but UberFileTwo only has a main label. Modify as necessary.

; Follow the instructions here if you're confused:
; https://www.smwcentral.net/?p=faq&page=1515827-uberasm

; Also note that, unfortunately, you can't call (e.g. JSL) a code in Library 
; from one that's also in Library. So if you're trying to have multiple codes in one level
; by putting both of them in Library, and yet one of them JSLs to
; something that's ALSO supposed to be in Library, you'll have to merge them instead.


macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
%call_library(UberFileOne_init)
    rtl

main:
%call_library(UberFileOne_main)
%call_library(UberFileTwo_main)
    rtl

load:
;%call_library(UberFileThree_load)
    rtl	
	
nmi:
;%call_library(UberFileFour_nmi)
    rtl