!EnableCheckPointKill = 1 ; Currently set to only kill it when you're on tile for level 105, as an example.
!OverworldAuthorNames = 0 ; You'll need to add the optional stuff first

macro call_library(i)
        PHB
        LDA.b #<i>>>16
        PHA
        PLB
        JSL <i>
        PLB
    endmacro
	
init:
    if !OverworldAuthorNames
    jsl author_display_main
	endif
	
	LDX #$5D ; level_number. This will kill CP whenever you go back to OW
    LDA $1EA2|!addr,x ; 13B (hub) – DC = 5F. For anything > 24 subtract DC, don't go over 96 decimal
    AND #%10111111 ; format bmesudlr, m is midway
    STA $1EA2|!addr,x	
	
	LDX #$5F ; level_number. This will kill CP whenever you go back to OW
    LDA $1EA2|!addr,x ; 13B (hub) – DC = 5F. For anything > 24 subtract DC, don't go over 96 decimal
    AND #%10111111 ; format bmesudlr, m is midway
    STA $1EA2|!addr,x
    rtl

main:
    %call_library(OverworldSave_main)
	
    if !OverworldAuthorNames
    jsl author_display_main
	endif
	
ReturnToTitle:	        ; This lets you go back to title with L/R + select. (Alt., 15 : 20 is holding select, 16 : 10 is press start)
	LDA $17				
    AND #$30			; Holding both L and R
    CMP #$30
    BNE End
    LDA $16				;check if controller button is newly pressed.
    AND #$20			; 20 Select button
    CMP #$20
    BNE KillCheckpoint
    LDA #$02            ; 03 is instant title
    STA $0100           ; gamemode, title screen
	BRA End
	
KillCheckpoint:	        ; Carries over L+R check from above, but now
    if !EnableCheckPointKill
    LDA $18				;checks if X is pressed.
    AND #$40			 
    CMP #$40
    BNE End 
	REP #$30		; make sure you're in 16-bit A/X/Y
	jsl ow_tilepos_calc_here
	LDA $7ED000,x		; get level number
	SEP #$30		; back to 8-bit
	CMP #$29		; compare to translevel
	BNE End         ; This is all you need to find which level you're on
	LDA #$16
	STA $1DFC ; OW castle collapse sound
	LDX #$29 ; 105
	LDA $1EA2|!addr,x
    AND #%10111111
    STA $1EA2|!addr,x
    endif
    End:
    rtl
