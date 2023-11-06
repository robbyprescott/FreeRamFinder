; WIP by SJC
; This will only put the score count in the HUD, and nothing else
; Use in conjunction with special layer 3 ExGFX file (328) in LG1

; By default, only the last digit of the timer is blanked out. (Intended for you to set the timer to zero.)
 
; Also, if you want, ExGFX103 is a copy of GFX00, but without the score sprites. 
; So you can use that as default, and only use GFX00 when you need the score

!RemoveBonusCounter = 1
!CoinCounterZero = 1 ; you don't want to do this if you want to move the score counter up
!MoveScoreUp = 0
!Test = 0

!StatusBarFreeRAM = $0E06

!OriginalScoreLocation = $0F29 
!NewScoreLocation = $0F0E   ; up one tile

load:
lda #$01
sta !StatusBarFreeRAM ; restore status bar stuff

STZ $0F34 ; reset score 
STZ $0F35 ; for Mario
STZ $0F36 ; on load

STZ $0F37 ; reset score 
STZ $0F38 ; for Luigi
STZ $0F39 ; on load

rtl

init:
if !MoveScoreUp = 1
STA $0F2F   ; also nix final zero digit of score if define
endif
 
RTL

main:

if !Test = 1
LDA !OriginalScoreLocation
STA !NewScoreLocation
LDA !OriginalScoreLocation+1
STA !NewScoreLocation+1
LDA !OriginalScoreLocation+2
STA !NewScoreLocation+2
LDA !OriginalScoreLocation+3
STA !NewScoreLocation+3
LDA !OriginalScoreLocation+4
STA !NewScoreLocation+4
LDA !OriginalScoreLocation+5
STA !NewScoreLocation+5
endif

stz $0DBE ; life. MARIO itself?
stz $0DBF ; Coin stuff. But don't need either of these if patch?
stz $13CC ; nix coin increment?

rtl

nmi:
LDA #$FC
if !CoinCounterZero
STA $0F14   ; remove final extraneous 0 of coin counter
endif
STA $0F16   ; tens digit of life counter, etc. need this one to stop brief display at load
STA $0F17   ; ones digit of life counter
if !RemoveBonusCounter
STA $0F03
STA $0F04
STA $0F1E
STA $0F1F
endif
;STA $0F25 ; timer hundreds
;STA $0F26 ; timer tens
STA $0F27
rtl