; by Chdata/Fakescaper - ASMT 2009-10
; Mods by SJC

; Can still be hurt if big
; If FreeRAM set, will walk right through enemies usually

!CantDieInPit = 1   ; Set this to 1 if you want the toggleable option of surviving falling in pits (will be boosted out)
!FreeRAMDamage = $0EB7
!FreeRAMPit = $0EB8
!FreeRAMSmallDamage = $0E02

if read1($00FFD5) == $23
	sa1rom
else
	lorom
endif


org $00F606
autoclean JML DeathRoutineHijack

if !CantDieInPit = 1
org $00F5B2
autoclean JSL FellInAPit
endif

freecode

if !CantDieInPit = 1
FellInAPit:
	LDA !FreeRAMPit			;\ Skip the death routine if flag is set.
	BNE .Weee			;/
	JSL $00F60A
	RTL
.Weee
	LDA #$80			;Mario is shot back up
	STA $7D				; from pit
	RTL
endif

DeathRoutineHijack:
	LDA !FreeRAMDamage		;\ Skip the death routine if flag is set.
	BNE .NoDeath		;/
	;LDA !Trigger
	;BNE .HybridVanillaDeathRetry
	;LDA.b #$90			;\ Restore original code. #$90
	;STA $7D				;/
	;BRA .Death
;.HybridVanillaDeathRetry	
	LDA.b #$90			;\ Mario propelled up. Restore original code. #$90
	STA $7D				;/
.Death
	JML $00F60A			; Continue with the death routine.
.NoDeath
    LDA !FreeRAMSmallDamage
	BEQ Skip ; if $0EB8 set but not $0E02, skip
	INC $0E05 ; Increment this, for use with freeze Uber
	DEC $0E03 ; HP counter
    LDA #$04 ;  Here begins $00F5B7 recreation. damage SFX
	STA $1DF9 
    LDA #$7F ; flashing animation. If set above $7F, timer longer but won't flash for the first couple of seconds
	STA $1497
	;LDA #$2F ; actual freeze
	;STA $9D ; Lock animation and sprites 
    BRA Final ; necessary so doesn't go into grow animation
	Skip:
	JML $00F628
	Final:
	RTL