macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
main:
%call_library(InputDisplay_main)
; %call_library(SlowdownToggleWithLorR_main)
    rtl
	
nmi:
%call_library(Layer3VisualToggleOnTrigger_nmi)
    rtl