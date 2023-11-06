; By SJC
; Use with DeathAndDamageDisableFlag.asm patch.
; You can use this with a counter, or ThreeDigitCounter.
; If you become any sort of big Mario, your HP will now be one value greater than the defined number of hits.
; (By default, then, if you have a powerup, this will allow you to be damaged THREE times total)
; Also with ShortMarioFreezeOnTrigger.asm: if you make the trigger $0E05, to give damage freeze

!NumberOfEXTRAHitsYouCanTakeWhenSmall = $01
!Counter = $0E03
!SecondaryCounter = $0DBE ; Life counter. E.g. for quick use with other common visual counters. 

load:
    LDA #!NumberOfEXTRAHitsYouCanTakeWhenSmall
	STA !Counter ; $0E03 decremented in death patch
	STA !SecondaryCounter
    LDA #$01
	STA $0EB7 ; Flag for conditional death patch in general.
	STA $0E02 ; Flag within death patch, allows damage as small Mario 
	RTL
	
main:
	LDA !Counter
    STA !SecondaryCounter
	
    LDA !Counter  
	BPL IfBigMario
    JSL $00F60A ; Must be this instead of $00F606
	LDA $71	
    CMP #$09 ; Reset counter when actually die
    BNE IfBigMario
    STZ !Counter
	STZ !SecondaryCounter ; This prevents overflow (underflow?)
	BRA End
IfBigMario:
    LDA $19     ; Big Mario
	CMP #$01    ; If any type 
	BCC DamageCheck
	LDA #!NumberOfEXTRAHitsYouCanTakeWhenSmall+1 ; Make sure the HP counter (when big) is
	STA !Counter                                 ; one value greater than the original defined number of hits
	;STA !SecondaryCounter
DamageCheck:	
	LDA $71	
    CMP #$01 ; check for damage animation
    BNE End
	LDA #!NumberOfEXTRAHitsYouCanTakeWhenSmall
	STA !Counter                                 ; one greater than the original defined number of hits
End:
    RTL
