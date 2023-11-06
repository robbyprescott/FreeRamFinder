; Use with ScoreOnly_LibraryFile.asm
; By Fernap, mods by SJC

; This triggers the thing when you reach a MINIMUM of the specific score.
; You'll need to tweak if you want it to no longer trigger the thing if you're ABOVE the value.

; Put ScoreOnly library file in Library
; Use in conjunction with layer 3 file ExGFX328, which you put in LG1 slot.
; See example level AD which has score palette ExAnimation, too


!ScoreValue = 0000400  ; In decimal. 
!PlaySFX = 1 ; when you reach score. Probably don't disable this
!RepeatSound = 0 ; If 1, will continually make sound when trigger set. Please don't make it annoying

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
load:
    REP #$20
    LDA $7FC0FC
    AND #$FFF7
    STA $7FC0FC
    SEP #$20
%call_library(ScoreOnly_LibraryFile_load)
    rtl	

init:
%call_library(ScoreOnly_LibraryFile_init)
    rtl

nmi:
%call_library(ScoreOnly_LibraryFile_nmi)
    rtl
	
main:
%call_library(ScoreOnly_LibraryFile_main)

    rep #$20
    lda $0f34|!addr
    sec : sbc.w #(!ScoreValue/10)&$ffff
    sep #$20
    lda $0f36|!addr
    sbc.b #(!ScoreValue/10)>>16
    bcc .Nope                 ; score < scorevalue. If lower... (Or BNE)

.DoThing:
     inc $19 ; your code here
	 if !PlaySFX
	 REP #$20
     LDA $7FC0FC ; ExAnimation
	 AND #$0008 ; Custom trigger 3
	 BNE .Nope
     SEP #$20
	 
	 LDA #$29 
	 STA $1DFC
	 
	 REP #$20
     LDA $7FC0FC
     ORA #$0008
     STA $7FC0FC
     ;SEP #$20
	 endif
.Nope:
    if !PlaySFX
    SEP #$20
	endif
    rtl