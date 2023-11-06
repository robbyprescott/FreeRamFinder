; Use block to turn timer on

; Note that in its current state, 
; will kill some other counter fucntions in the level,
; like coin counter 

!KillVanillaCoinFunctionsEtc = 1


macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro

!FreeRAMPause = $0EB9
!FreeRAMVisible = $0EBA
						
load:
lda #$01
sta !FreeRAMPause
sta !FreeRAMVisible
if !KillVanillaCoinFunctionsEtc
sta $0DEC
endif
rtl	
					
init:
%call_library(TimerOnlyTriggered_init)
    rtl

main:
%call_library(TimerOnlyTriggered_main)
    rtl
	
nmi:
%call_library(TimerOnlyTriggered_nmi)
    rtl
	
	