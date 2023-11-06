;RAM specific LR scroll disable
;Highly based off of Smallhacker's L/R Hook patch, not compatible with it though
;By: Chdata/Fakescaper
; Mods by SJC

if read1($00FFD5) == $23
	sa1rom
endif

!Freeram = $0DE9		;Set this to freeram

org $00CDF6
	autoclean JML LRcheck
	NOP #4 ; added SJC

freecode
LRcheck:
	LDA !Freeram
	BEQ DisableLR
	;LDA $17
	;AND.b #$CF
	JML $00CDFE

DisableLR:
	JML $00CE49
	
;CODE_00CDF6:        A5 17         LDA RAM_ControllerB       ; \ Branch if anything besides L/R being held 
;CODE_00CDF8:        29 CF         AND.B #$CF                ;  | 
;CODE_00CDFA:        05 15         ORA RAM_ControllerA       ;  | 
;CODE_00CDFC:        D0 4B         BNE CODE_00CE49           ; / 
;CODE_00CDFE:        A5 17         LDA RAM_ControllerB       ; \ Branch if L/R not being held 
;CODE_00CE00:        29 30         AND.B #$30                ;  | 